import 'package:flutter/material.dart';
import 'patients_screen.dart' show Patient;
import '../medications/medications_screen.dart';
import '../timeline/timeline_screen.dart';
import '../exams/exams_screen.dart';
import '../recommendations/recommendations_screen.dart';
import '../contacts/contacts_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  int currentIndex = 1; // 0=Medicações, 1=Home, 2=Linha do tempo

  // Gera um "id" temporário baseado no nome do paciente
  String _patientKey(Patient p) =>
      p.name.trim().toLowerCase().replaceAll(' ', '-');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final patient = widget.patient;
    final patientKey = _patientKey(patient);

    return Scaffold(
      endDrawer: _SideBurgerMenu(
        patient: patient,
        patientKey: patientKey,
      ),

      appBar: AppBar(
        title: Text(patient.name),
        backgroundColor: cs.primary.withOpacity(0.08),
        elevation: 0,
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HeaderCardCompact(patient: patient),
          const SizedBox(height: 16),

          _HorizontalCardsSection(children: const [
            _MiniInfoCard(
              title: 'Próxima consulta',
              subtitle: 'Hoje às 16:00',
              icon: Icons.event_note,
            ),
            _MiniInfoCard(
              title: 'Medicação',
              subtitle: 'Tomar 100mg às 18:00',
              icon: Icons.vaccines_outlined,
            ),
          ]),

          const SizedBox(height: 16),

          _AIInteractionCard(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fale com o Elder — mock')),
            ),
          ),

          const SizedBox(height: 16),

          const _ListCard(
            title: 'Lembretes de hoje',
            items: [
              'Hidratação: 6 copos d’água',
              'Medição de pressão às 14:00',
              'Registrar dor (0–10) às 20:00',
            ],
            leading: Icons.check_circle_outline,
          ),
          const SizedBox(height: 16),

          const _ListCard(
            title: 'Sugestões automáticas',
            items: [
              'Parabéns! Passos consistentes nos últimos 3 dias',
              'Considere ir dormir 20min mais cedo hoje',
            ],
            leading: Icons.lightbulb_outline,
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          setState(() => currentIndex = i);
          if (i == 0) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MedicationsScreen(
                  patientId: patientKey,
                  patientName: patient.name,
                ),
              ),
            );
          } else if (i == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TimelineScreen(
                  patientId: patientKey,
                  patientName: patient.name,
                ),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Medicações',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Linha do tempo',
          ),
        ],
      ),
    );
  }
}

/* ===================== Drawer (menu burger direito) ===================== */

class _SideBurgerMenu extends StatelessWidget {
  final Patient patient;
  final String patientKey;
  const _SideBurgerMenu({
    required this.patient,
    required this.patientKey,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: Icon(Icons.timeline, color: cs.primary),
              title: const Text('Linha do tempo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Linha do tempo (em breve)')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.medication, color: cs.primary),
              title: const Text('Medicações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MedicationsScreen(
                      patientId: patientKey,
                      patientName: patient.name,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.biotech_outlined),
              title: const Text('Exames'),
              subtitle: const Text('Ver todos os exames'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExamsScreen(
                      patientId: patientKey,         // <-- use your real patient id var
                      patientName: patient.name,     // <-- if you have it
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.recommend_outlined, color: cs.primary),
              title: const Text('Recomendações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecommendationsScreen(
                      patientId: patientKey,
                      patientName: patient.name,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contacts_outlined, color: cs.primary),
              title: const Text('Contatos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ContactsScreen(
                      patientId: patientKey,
                      patientName: patient.name,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: cs.primary),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configurações (em breve)')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== UI PARTS ===================== */

class _HeaderCardCompact extends StatelessWidget {
  final Patient patient;
  const _HeaderCardCompact({required this.patient});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: cs.primary.withOpacity(0.06),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.primary.withOpacity(0.18),
              child: Icon(Icons.person, color: cs.primary, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              patient.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              '${patient.gender} • ${patient.age} anos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: patient.tags.isEmpty
                  ? [const _TagChip(text: 'Sem tags')]
                  : patient.tags.map((t) => _TagChip(text: t)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalCardsSection extends StatelessWidget {
  final List<Widget> children;
  const _HorizontalCardsSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemBuilder: (context, i) {
          return SizedBox(width: 240, child: children[i]);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: children.length,
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _MiniInfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lightGreen = cs.primary.withOpacity(0.10);

    return Material(
      elevation: 1.5,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: lightGreen,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: cs.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIInteractionCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AIInteractionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, cs.primary.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Fale com o Elder',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),
            InkResponse(
              onTap: onTap,
              radius: 52,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mic_none, color: Colors.white, size: 34),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque para falar',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData leading;
  const _ListCard({
    required this.title,
    required this.items,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, cs.primary.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 12),
            for (final it in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(leading, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(it, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  const _TagChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.primary.withOpacity(0.95),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
