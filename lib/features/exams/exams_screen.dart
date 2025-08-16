import 'package:flutter/material.dart';
import 'models/exam.dart';
import 'models/mock_exams.dart';

enum ExamsView { byExam, byDate }

class ExamsScreen extends StatefulWidget {
  final String patientId;
  final String? patientName;
  const ExamsScreen({super.key, required this.patientId, this.patientName});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  late final List<Exam> _all; // foto dos dados
  ExamsView _view = ExamsView.byExam;

  @override
  void initState() {
    super.initState();
    _all = getExamsForPatient(widget.patientId)..sort((a, b) => b.date.compareTo(a.date));
  }

  // ---- agrupamentos ----
  Map<String, List<Exam>> _groupByExam() {
    final map = <String, List<Exam>>{};
    for (final e in _all) {
      map.putIfAbsent(e.name, () => []).add(e);
    }
    // ordena cada lista por data desc
    for (final list in map.values) {
      list.sort((a, b) => b.date.compareTo(a.date));
    }
    return map;
  }

  Map<DateTime, List<Exam>> _groupByDay() {
    DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
    final map = <DateTime, List<Exam>>{};
    for (final e in _all) {
      final key = dayOnly(e.date);
      map.putIfAbsent(key, () => []).add(e);
    }
    // ordena os exames do dia por horário
    for (final list in map.values) {
      list.sort((a, b) => b.date.compareTo(a.date));
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.patientName == null ? 'Exames' : 'Exames · ${widget.patientName}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<ExamsView>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: ExamsView.byExam,
                  icon: Icon(Icons.biotech_outlined),
                  label: Text('Por exame'),
                ),
                ButtonSegment(
                  value: ExamsView.byDate,
                  icon: Icon(Icons.calendar_month),
                  label: Text('Por data'),
                ),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: _view == ExamsView.byExam
                ? _ByExamList(groups: _groupByExam())
                : _ByDateList(groups: _groupByDay()),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// POR EXAME
/// =======================
class _ByExamList extends StatelessWidget {
  final Map<String, List<Exam>> groups;
  const _ByExamList({required this.groups});

  @override
  Widget build(BuildContext context) {
    final names = groups.keys.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: names.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final name = names[i];
        final list = groups[name]!;
        final latest = list.first; // já está ordenado desc no agrupamento
        return _ExamGroupCard(name: name, latest: latest, count: list.length);
      },
    );
  }
}

class _ExamGroupCard extends StatelessWidget {
  final String name;
  final Exam latest;
  final int count;
  const _ExamGroupCard({required this.name, required this.latest, required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.biotech),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name, style: Theme.of(context).textTheme.titleMedium),
                      ),
                      _QtyPill(count: count),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Realizado por último em ${formatShortDate(latest.date)}',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (latest.location != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 16),
                        const SizedBox(width: 6),
                        Text(latest.location!),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  final int count;
  const _QtyPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$count'),
    );
  }
}

/// =======================
/// POR DATA
/// =======================
class _ByDateList extends StatelessWidget {
  final Map<DateTime, List<Exam>> groups;
  const _ByDateList({required this.groups});

  @override
  Widget build(BuildContext context) {
    // ordena dias do mais recente para o mais antigo
    final days = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: days.length,
      itemBuilder: (_, i) {
        final day = days[i];
        final list = groups[day]!;
        return _DaySection(day: day, exams: list);
      },
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<Exam> exams;
  const _DaySection({required this.day, required this.exams});

  String _header(DateTime d) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
    // se quiser mostrar "Hoje/Ontem", pode ajustar aqui.
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do dia
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: cs.primary),
                const SizedBox(width: 8),
                Text(_header(day), style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          // Lista de exames do dia
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            itemCount: exams.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _SmallExamTile(exam: exams[i]),
          ),
        ],
      ),
    );
  }
}

class _SmallExamTile extends StatelessWidget {
  final Exam exam;
  const _SmallExamTile({required this.exam});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final time = '${exam.date.hour.toString().padLeft(2, '0')}:${exam.date.minute.toString().padLeft(2, '0')}';
    final label = exam.status == ExamStatus.available
      ? 'Resultado Disponível'
      : statusLabel(exam.status);

    return Material(
      color: Theme.of(context).cardColor,
      elevation: 0.5,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // clique futuro para tela de detalhes
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outlineVariant),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.biotech, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exam.name, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14),
                        const SizedBox(width: 4),
                        Text(time),
                        if (exam.location != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.place, size: 14),
                          const SizedBox(width: 4),
                          Flexible(child: Text(exam.location!, overflow: TextOverflow.ellipsis)),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(label),
                side: BorderSide(color: statusColor(context, exam.status).withOpacity(.25)),
                backgroundColor: statusColor(context, exam.status).withOpacity(.10),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
