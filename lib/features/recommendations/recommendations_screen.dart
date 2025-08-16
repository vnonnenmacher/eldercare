import 'package:flutter/material.dart';

/// ======= MODELO =======
class Recommendation {
  final String id;
  final String from;        // quem recomendou (ex.: "Dr. Maria Souza", "Elder")
  final String message;     // texto da recomendação
  final DateTime createdAt; // quando foi dada

  Recommendation({
    required this.id,
    required this.from,
    required this.message,
    required this.createdAt,
  });
}

/// ======= MOCK simples por paciente =======
/// Gera uma lista determinística a partir do patientId (semente)
List<Recommendation> mockRecommendations(String patientId) {
  final base = DateTime.now();
  // use o tamanho do id como "semente" para mudar um pouco os horários
  final k = patientId.length;
  return [
    Recommendation(
      id: 'r1',
      from: 'Elder (IA)',
      message: 'Aumente a ingestão de água hoje. Meta: 6–8 copos.',
      createdAt: base.subtract(Duration(hours: 2 + (k % 3))),
    ),
    Recommendation(
      id: 'r2',
      from: 'Dr. João Henrique',
      message:
          'Tomar a medicação de pressão pela manhã, sempre antes do café.',
      createdAt: base.subtract(Duration(days: 1, hours: 1 + (k % 2))),
    ),
    Recommendation(
      id: 'r3',
      from: 'Enf. Camila',
      message:
          'Registrar a dor à noite (0–10) para acompanharmos a tendência.',
      createdAt: base.subtract(Duration(days: 3, hours: 3)),
    ),
    Recommendation(
      id: 'r4',
      from: 'Elder (IA)',
      message:
          'Considere caminhar 20–30 minutos à tarde, ritmo confortável.',
      createdAt: base.subtract(Duration(days: 7, hours: 5)),
    ),
  ];
}

/// ======= TELA =======
class RecommendationsScreen extends StatefulWidget {
  final String patientId;
  final String? patientName;

  const RecommendationsScreen({
    super.key,
    required this.patientId,
    this.patientName,
  });

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late List<Recommendation> _items;

  @override
  void initState() {
    super.initState();
    _items = mockRecommendations(widget.patientId);
  }

  void _deleteAt(int index) {
    final removed = _items[index];
    setState(() => _items.removeAt(index));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recomendação removida'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() => _items.insert(index, removed));
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    // dd/MM HH:mm – sem depender de intl
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)} ${two(dt.hour)}:${two(dt.minute)}';
    // se quiser relativo (ex.: "há 2h"), podemos ajustar depois
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName == null
            ? 'Recomendações'
            : 'Recomendações — ${widget.patientName}'),
        backgroundColor: cs.primary.withOpacity(0.08),
        elevation: 0,
      ),
      body: _items.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final rec = _items[index];
                return Dismissible(
                  key: ValueKey(rec.id),
                  direction: DismissDirection.endToStart,
                  background: const _DismissBg(),
                  onDismissed: (_) => _deleteAt(index),
                  child: _RecommendationCard(
                    from: rec.from,
                    message: rec.message,
                    dateLabel: _formatDate(rec.createdAt),
                    onDelete: () => _deleteAt(index),
                  ),
                );
              },
            ),
    );
  }
}

/// ======= WIDGETS =======

class _RecommendationCard extends StatelessWidget {
  final String from;
  final String message;
  final String dateLabel;
  final VoidCallback onDelete;

  const _RecommendationCard({
    required this.from,
    required this.message,
    required this.dateLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, cs.primary.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AvatarFromName(name: from),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho (quem + data)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          from,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateLabel,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Excluir',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.redAccent.withOpacity(0.9),
                    ),
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

class _AvatarFromName extends StatelessWidget {
  final String name;
  const _AvatarFromName({required this.name});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 20,
      backgroundColor: cs.primary.withOpacity(0.18),
      child: Text(
        _initials,
        style: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DismissBg extends StatelessWidget {
  const _DismissBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.recommend_outlined, color: cs.primary, size: 48),
            const SizedBox(height: 10),
            Text(
              'Sem recomendações',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Quando houverem recomendações de profissionais ou do Elder, elas aparecerão aqui.',
              textAlign: TextAlign.center,
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
