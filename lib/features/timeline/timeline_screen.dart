import 'package:flutter/material.dart';
import 'models/event.dart';
import 'models/mock_events.dart';
import 'widgets/event_card.dart';

class TimelineScreen extends StatefulWidget {
  final String? patientId;
  final String? patientName;

  const TimelineScreen({super.key, this.patientId, this.patientName});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  late List<TimelineEvent> _all;
  final Set<EventType> _activeFilters = {}; // nenhum = mostra tudo
  String _search = "";

  @override
  void initState() {
    super.initState();
    // Mock local — troque por seu provedor quando for integrar
    _all = mockEvents(patientId: widget.patientId ?? "demo");
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilters(_all, _activeFilters, _search);
    final groups = _groupByDay(filtered);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName == null
            ? "Linha do tempo"
            : "Linha do tempo · ${widget.patientName}"),
        centerTitle: false,
        backgroundColor: const Color(0xFFE8F1EA),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7FAF8),
      floatingActionButton: FloatingActionButton(
        onPressed: () {/* ação de criar novo evento (somente UI) */},
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Busca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: "Buscar por título, local…",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFEFF5F1),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Filtros por tipo (chips roláveis)
          _FiltersBar(
            active: _activeFilters,
            onToggle: (t) => setState(() {
              if (_activeFilters.contains(t)) {
                _activeFilters.remove(t);
              } else {
                _activeFilters.add(t);
              }
            }),
          ),
          const SizedBox(height: 8),
          // Lista agrupada
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: groups.length,
              itemBuilder: (_, i) {
                final g = groups[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GroupHeader(label: g.label),
                    const SizedBox(height: 8),
                    ...g.items.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EventCard(event: e),
                    )),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- helpers ---

  List<_Group> _groupByDay(List<TimelineEvent> items) {
    final now = DateTime.now();
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final today = items.where((e) => sameDay(e.dateTime, now)).toList();
    final yesterday = items.where((e) =>
        sameDay(e.dateTime, now.subtract(const Duration(days: 1)))).toList();
    final earlier = items.where((e) =>
        !sameDay(e.dateTime, now) &&
        !sameDay(e.dateTime, now.subtract(const Duration(days: 1)))).toList();

    String headerFor(DateTime d) {
      final months = [
        "jan", "fev", "mar", "abr", "mai", "jun",
        "jul", "ago", "set", "out", "nov", "dez"
      ];
      final dd = d.day.toString().padLeft(2, '0');
      final mm = months[d.month - 1];
      return "$dd de $mm";
    }

    // Ordena por horário decrescente dentro de cada grupo
    int cmp(TimelineEvent a, TimelineEvent b) =>
        b.dateTime.compareTo(a.dateTime);
    today.sort(cmp);
    yesterday.sort(cmp);
    earlier.sort(cmp);

    final groups = <_Group>[];
    if (today.isNotEmpty) {
      groups.add(_Group("Hoje • ${headerFor(now)}", today));
    }
    if (yesterday.isNotEmpty) {
      groups.add(_Group("Ontem • ${headerFor(now.subtract(const Duration(days: 1)))}", yesterday));
    }
    if (earlier.isNotEmpty) {
      groups.add(_Group("Mais antigos", earlier));
    }
    return groups;
  }

  List<TimelineEvent> _applyFilters(
      List<TimelineEvent> base, Set<EventType> active, String search) {
    Iterable<TimelineEvent> res = base;

    if (active.isNotEmpty) {
      res = res.where((e) => active.contains(e.type));
    }
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      res = res.where((e) =>
          e.title.toLowerCase().contains(q) ||
          (e.subtitle ?? "").toLowerCase().contains(q));
    }
    // Exemplo: você pode decidir ordenar por data sempre
    final list = res.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }
}

class _Group {
  final String label;
  final List<TimelineEvent> items;
  _Group(this.label, this.items);
}

class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2F6B3B),
            ),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  final Set<EventType> active;
  final ValueChanged<EventType> onToggle;
  const _FiltersBar({required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final all = EventType.values;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final t = all[i];
          final selected = active.contains(t);
          return FilterChip(
            selected: selected,
            label: Text(labelForEventType(t)),
            avatar: Icon(iconForEventType(t), size: 16),
            onSelected: (_) => onToggle(t),
            selectedColor: const Color(0xFFDDE9E0),
            showCheckmark: false,
            side: BorderSide(
              color: selected ? const Color(0xFF2F6B3B) : Colors.black26,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: all.length,
      ),
    );
  }
}
