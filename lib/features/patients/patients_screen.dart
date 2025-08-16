import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final searchCtrl = TextEditingController();

  // Mock: 5 pacientes com alerts opcionais
  final List<Patient> patients = [
    Patient(
      name: 'Ana Souza',
      gender: 'Mulher',
      age: 36,
      tags: ['Alto Risco', 'Retorno'],
      alerts: ['Medicação pendente', 'Consulta hoje'],
    ),
    Patient(
      name: 'João Silva',
      gender: 'Homem',
      age: 45,
      tags: ['Retorno'],
      alerts: [],
    ),
    Patient(
      name: 'Marina Costa',
      gender: 'Mulher',
      age: 29,
      tags: ['Isolamento'],
      alerts: ['Exame atrasado'],
    ),
    Patient(
      name: 'Carlos Pereira',
      gender: 'Homem',
      age: 68,
      tags: ['Idoso', 'Diabético'],
      alerts: ['Risco de queda'],
    ),
    Patient(
      name: 'Beatriz Ramos',
      gender: 'Mulher',
      age: 54,
      tags: ['Alto Risco'],
      alerts: [],
    ),
  ];

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final filtered = patients.where((p) {
      final q = searchCtrl.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q)) ||
          p.alerts.any((t) => t.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        backgroundColor: cs.primary.withOpacity(0.08),
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.eco_rounded, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SearchField(
                  controller: searchCtrl,
                  hintText: 'Buscar pacientes...',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Configurações',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrir configurações (mock)')),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
        ),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final p = filtered[index];
          return _PatientCard(
            patient: p,
            onView: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PatientDetailScreen(patient: p),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navegar para tela de cadastro
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adicionar paciente (mock)')),
          );
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/* ===================== Models & Widgets ===================== */

class Patient {
  final String name;
  final String gender; // 'Homem' | 'Mulher'
  final int age;
  final List<String> tags;
  final List<String> alerts;
  Patient({
    required this.name,
    required this.gender,
    required this.age,
    required this.tags,
    this.alerts = const [],
  });
}

class _PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onView;
  const _PatientCard({required this.patient, required this.onView});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 3,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              cs.primary.withOpacity(0.02),
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.person_outline, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        patient.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${patient.gender} • ${patient.age} anos',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                const SizedBox(height: 12),

                // Alertas (se houver)
                if (patient.alerts.isNotEmpty) ...[
                  _SectionLabel('Alertas:'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: patient.alerts
                        .map((a) => _AlertChip(text: a))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Tags
                _SectionLabel('Tags:'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: patient.tags.isEmpty
                      ? [const _Chip(text: 'Sem tags')]
                      : patient.tags.map((t) => _Chip(text: t)).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),

            // Ação (olho)
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: cs.primary,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onView,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.remove_red_eye, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color? color;
  const _Chip({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = (color ?? cs.primary).withOpacity(0.15);
    final fg = (color ?? cs.primary).withOpacity(0.95);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AlertChip extends StatelessWidget {
  final String text;
  const _AlertChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = cs.error.withOpacity(0.12); // destaque suave
    final fg = cs.error;                   // texto com cor de erro
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.error.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black54),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  const _SearchField({
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
