import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ======= MODELO =======
class Medication {
  final String id;
  String name;
  String dose;        // "100 mg"
  String schedule;    // "A cada 8 horas" | "Diariamente às 09:00"
  bool active;

  DateTime? lastDoseAt;   // quando foi tomada por último
  bool lastDoseTaken;     // se a última dose foi tomada
  DateTime? nextDoseAt;   // próxima dose prevista

  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.schedule,
    this.active = true,
    this.lastDoseAt,
    this.lastDoseTaken = false,
    this.nextDoseAt,
  });
}

enum MedicationView { daily, weekly }

class MedicationsScreen extends StatefulWidget {
  final String patientId;      // recebido do Patient Detail
  final String? patientName;   // opcional para título

  const MedicationsScreen({
    super.key,
    required this.patientId,
    this.patientName,
  });

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  MedicationView _view = MedicationView.daily;

  // Semana (segunda-feira como início)
  DateTime _weekStart = _startOfWeek(DateTime.now());
  static DateTime _startOfWeek(DateTime d) {
    final weekday = d.weekday; // 1=Mon .. 7=Sun
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: weekday - 1));
  }
  String get _weekLabel {
    final s = _weekStart;
    final e = s.add(const Duration(days: 6));
    const mons = ['jan','fev','mar','abr','mai','jun','jul','ago','set','out','nov','dez'];
    return '${s.day} ${mons[s.month-1]} a ${e.day} ${mons[e.month-1]}';
  }
  void _prevWeek() => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() => setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  final List<Medication> _meds = [
    Medication(
      id: '1',
      name: 'Aspirina',
      dose: '100 mg',
      schedule: 'A cada 8 horas',
      lastDoseAt: DateTime.now().subtract(const Duration(hours: 6)),
      lastDoseTaken: true,
    ),
    Medication(
      id: '2',
      name: 'Vitamina D',
      dose: '2000 UI',
      schedule: 'Diariamente às 09:00',
      lastDoseAt: DateTime.now().subtract(const Duration(hours: 11)),
      lastDoseTaken: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    for (final m in _meds) {
      m.nextDoseAt ??= _computeNextDose(m);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.patientName == null
        ? 'Medicações'
        : 'Medicações — ${widget.patientName}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Exportar tabela de medicações',
            icon: const Icon(Icons.ios_share),
            onPressed: _exportSchedule,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedication,
        tooltip: 'Adicionar medicação',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<MedicationView>(
                segments: const [
                  ButtonSegment(
                    value: MedicationView.daily,
                    label: Text('Diária'),
                    icon: Icon(Icons.calendar_today),
                  ),
                  ButtonSegment(
                    value: MedicationView.weekly,
                    label: Text('Semanal'),
                    icon: Icon(Icons.view_week),
                  ),
                ],
                selected: {_view},
                onSelectionChanged: (s) => setState(() => _view = s.first),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _view == MedicationView.daily
                    ? _DailyList(
                        meds: _meds,
                        onEdit: _editMedication,
                        onDelete: _removeMedication,
                        onMarkTaken: _markTaken,
                        formatNext: _formatNext,
                        formatLast: _formatLast,
                      )
                    : _WeeklyWeekView(
                        meds: _meds,
                        weekStart: _weekStart,
                        weekLabel: _weekLabel,
                        onPrevWeek: _prevWeek,
                        onNextWeek: _nextWeek,
                        onMarkTaken: _markTaken,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------ actions ------------
  void _addMedication() async {
    final newMed = await showModalBottomSheet<Medication>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MedicationForm(),
    );
    if (newMed != null) {
      newMed.nextDoseAt = _computeNextDose(newMed);
      setState(() => _meds.add(newMed));
    }
  }

  void _editMedication(Medication med) async {
    final updated = await showModalBottomSheet<Medication>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MedicationForm(existing: med),
    );
    if (updated != null) {
      updated.nextDoseAt = _computeNextDose(updated);
      setState(() {
        final i = _meds.indexWhere((m) => m.id == updated.id);
        if (i >= 0) _meds[i] = updated;
      });
    }
  }

  void _removeMedication(Medication med) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover medicação'),
        content: Text('Deseja remover "${med.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
        ],
      ),
    );
    if (ok == true) setState(() => _meds.removeWhere((m) => m.id == med.id));
  }

  void _exportSchedule() async {
    final buffer = StringBuffer('nome,dose,horario,ativo,patient_id,ultima_dose,proxima_dose\n');
    for (final m in _meds) {
      buffer.writeln('${m.name},${m.dose},${m.schedule},${m.active ? "sim" : "não"},'
          '${widget.patientId},${m.lastDoseAt?.toIso8601String() ?? ""},${m.nextDoseAt?.toIso8601String() ?? ""}');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tabela copiada (CSV).')),
    );
  }

  void _markTaken(Medication m) {
    setState(() {
      m.lastDoseAt = DateTime.now();
      m.lastDoseTaken = true;
      m.nextDoseAt = _computeNextDose(m);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registrado: ${m.name} tomada agora.')),
    );
  }

  // ------------ helpers de tempo ------------

  DateTime? _computeNextDose(Medication m) {
    final now = DateTime.now();

    // Padrão 1: "A cada X horas"
    final cad = RegExp(r'A cada (\d+)\s*horas', caseSensitive: false);
    final cadaMatch = cad.firstMatch(m.schedule);
    if (cadaMatch != null) {
      final h = int.tryParse(cadaMatch.group(1)!);
      if (h != null) {
        final base = m.lastDoseAt ?? now;
        final next = base.add(Duration(hours: h));
        return next.isAfter(now) ? next : now.add(Duration(hours: h));
      }
    }

    // Padrão 2: "Diariamente às HH:MM"
    final dia = RegExp(r'Diariamente às (\d{2}):(\d{2})', caseSensitive: false);
    final diaMatch = dia.firstMatch(m.schedule);
    if (diaMatch != null) {
      final hh = int.parse(diaMatch.group(1)!);
      final mm = int.parse(diaMatch.group(2)!);
      var candidate = DateTime(now.year, now.month, now.day, hh, mm);
      if (!candidate.isAfter(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return candidate;
    }

    // fallback: 8 horas
    return (m.lastDoseAt ?? now).add(const Duration(hours: 8));
  }

  String _formatNext(Medication m) {
    final n = m.nextDoseAt ?? _computeNextDose(m);
    if (n == null) return '—';
    final diff = n.difference(DateTime.now());
    if (diff.inMinutes <= 0) {
      return 'agora';
    } else if (diff.inHours >= 1) {
      final h = diff.inHours;
      final mnt = diff.inMinutes % 60;
      return 'em ${h}h ${mnt}m';
    } else {
      return 'em ${diff.inMinutes}m';
    }
  }

  String _formatLast(Medication m) {
    final d = m.lastDoseAt;
    if (d == null) return 'Nunca registrada';
    final today = DateTime.now();
    final isToday = DateTime(d.year, d.month, d.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays == 0;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${isToday ? "Hoje" : "Ontem"} às $hh:$mm';
  }
}

/// ======= LISTA DIÁRIA =======
class _DailyList extends StatelessWidget {
  final List<Medication> meds;
  final void Function(Medication) onEdit;
  final void Function(Medication) onDelete;
  final void Function(Medication) onMarkTaken;
  final String Function(Medication) formatNext;
  final String Function(Medication) formatLast;

  const _DailyList({
    required this.meds,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkTaken,
    required this.formatNext,
    required this.formatLast,
  });

  @override
  Widget build(BuildContext context) {
    if (meds.isEmpty) return const Center(child: Text('Nenhuma medicação cadastrada.'));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: meds.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final m = meds[i];
        return _MedicationCard(
          med: m,
          onEdit: () => onEdit(m),
          onDelete: () => onDelete(m),
          onMarkTaken: () => onMarkTaken(m),
          nextLabel: formatNext(m),
          lastLabel: formatLast(m),
        );
      },
    );
  }
}

/// ======= CARD DIÁRIO =======
class _MedicationCard extends StatelessWidget {
  final Medication med;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkTaken;
  final String nextLabel;
  final String lastLabel;

  const _MedicationCard({
    required this.med,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkTaken,
    required this.nextLabel,
    required this.lastLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColor = med.lastDoseTaken ? Colors.green[700] : Colors.red[700];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
      ),
      color: const Color(0xFFF4F8F2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha 1: título e ações
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.add_box_rounded, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${med.name} ${med.dose}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary.withOpacity(0.95),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: 'Remover',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Linha 2: próxima e última dose
            Padding(
              padding: const EdgeInsets.only(left: 36), // alinhar com ícone
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próxima dose $nextLabel',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Última dose $lastLabel — ${med.lastDoseTaken ? "Tomado" : "Não tomado"}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Linha 3: botão Registrar tomada
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onMarkTaken,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Registrar tomada'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======= ABA SEMANAL: 1 CARD POR DIA =======
class _WeeklyWeekView extends StatelessWidget {
  final List<Medication> meds;
  final DateTime weekStart; // segunda-feira
  final String weekLabel;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final void Function(Medication) onMarkTaken;

  const _WeeklyWeekView({
    required this.meds,
    required this.weekStart,
    required this.weekLabel,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.onMarkTaken,
  });

  // --------- Regras de geração local (mock) ---------
  List<_DoseEntry> _dosesForDay(DateTime day) {
    final entries = <_DoseEntry>[];
    for (final m in meds) {
      // 1) "Diariamente às HH:MM"
      final daily = RegExp(r'Diariamente às (\d{2}):(\d{2})', caseSensitive: false)
          .firstMatch(m.schedule);
      if (daily != null) {
        final hh = int.parse(daily.group(1)!);
        final mm = int.parse(daily.group(2)!);
        entries.add(_DoseEntry(m, DateTime(day.year, day.month, day.day, hh, mm)));
        continue;
      }

      // 2) "A cada X horas" (âncora às 08:00)
      final cada = RegExp(r'A cada (\d+)\s*horas', caseSensitive: false)
          .firstMatch(m.schedule);
      if (cada != null) {
        final h = int.tryParse(cada.group(1)!);
        if (h != null && h > 0) {
          var t = DateTime(day.year, day.month, day.day, 8, 0);
          while (t.day == day.day) {
            entries.add(_DoseEntry(m, t));
            t = t.add(Duration(hours: h));
          }
        }
        continue;
      }

      // fallback: 08:00
      entries.add(_DoseEntry(m, DateTime(day.year, day.month, day.day, 8, 0)));
    }

    entries.sort((a, b) => a.time.compareTo(b.time));
    return entries;
  }

  String _weekdayName(int weekday) {
    const names = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return names[weekday - 1];
  }

  String _fmtHM(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  bool _isPastDay(DateTime day) {
    final now = DateTime.now();
    final d = DateTime(day.year, day.month, day.day);
    final today = DateTime(now.year, now.month, now.day);
    return d.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        // Cabeçalho: << 11–17 ago >>
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(onPressed: onPrevWeek, icon: const Icon(Icons.chevron_left)),
              Expanded(
                child: Center(
                  child: Text(
                    weekLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              IconButton(onPressed: onNextWeek, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ),
        const SizedBox(height: 4),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemBuilder: (_, i) {
              final day = days[i];
              final doses = _dosesForDay(day);
              final pastDay = _isPastDay(day);

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
                ),
                color: const Color(0xFFF4F8F2),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho do dia
                      Row(
                        children: [
                          Icon(Icons.event_note, color: cs.primary),
                          const SizedBox(width: 8),
                          Text(
                            '${_weekdayName(day.weekday)}, ${day.day}/${day.month}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (doses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0, bottom: 8),
                          child: Text('Sem medicações', style: Theme.of(context).textTheme.bodyMedium),
                        )
                      else
                        ...doses.map((d) => Padding(
                              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
                              child: Row(
                                children: [
                                  const SizedBox(width: 28),
                                  Text(_fmtHM(d.time),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          )),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text('${d.med.name} ${d.med.dose}',
                                        style: Theme.of(context).textTheme.bodyMedium),
                                  ),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: pastDay ? null : () => onMarkTaken(d.med),
                                    icon: Icon(pastDay ? Icons.done_all : Icons.check, size: 16),
                                    label: Text(pastDay ? 'Administrado' : 'Registrar'),
                                  ),
                                ],
                              ),
                            )),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: days.length,
          ),
        ),
      ],
    );
  }
}

class _DoseEntry {
  final Medication med;
  final DateTime time;
  _DoseEntry(this.med, this.time);
}

/// ======= FORM BOTTOM SHEET =======
class _MedicationForm extends StatefulWidget {
  final Medication? existing;
  const _MedicationForm({this.existing});

  @override
  State<_MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<_MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _doseCtrl;
  late TextEditingController _scheduleCtrl;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _doseCtrl = TextEditingController(text: widget.existing?.dose ?? '');
    _scheduleCtrl = TextEditingController(text: widget.existing?.schedule ?? '');
    _active = widget.existing?.active ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _scheduleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(editing ? Icons.edit_outlined : Icons.add_circle_outline),
                  const SizedBox(width: 8),
                  Text(editing ? 'Editar medicação' : 'Adicionar medicação',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome', hintText: 'Ex: Aspirina'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doseCtrl,
                decoration: const InputDecoration(labelText: 'Dose', hintText: 'Ex: 100 mg'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a dose' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _scheduleCtrl,
                decoration: const InputDecoration(labelText: 'Horário / Frequência', hintText: 'Ex: A cada 8 horas'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o horário' : null,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                title: const Text('Ativa'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: _save, child: Text(editing ? 'Salvar' : 'Adicionar'))),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final e = widget.existing;
    final med = Medication(
      id: e?.id ?? Random().nextInt(1 << 32).toString(),
      name: _nameCtrl.text.trim(),
      dose: _doseCtrl.text.trim(),
      schedule: _scheduleCtrl.text.trim(),
      active: _active,
      lastDoseAt: e?.lastDoseAt,
      lastDoseTaken: e?.lastDoseTaken ?? false,
      nextDoseAt: e?.nextDoseAt,
    );
    Navigator.pop(context, med);
  }
}
