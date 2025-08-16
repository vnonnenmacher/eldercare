import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final TimelineEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWarning = event.type == EventType.ocorrencia;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isWarning ? Colors.red.withOpacity(.35) : Colors.black12,
        ),
      ),
      color: isWarning
          ? Colors.red.withOpacity(.05)
          : const Color(0xFFF2F7F3), // verde bem claro
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: event.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Leading(type: event.type),
              const SizedBox(width: 12),
              Expanded(
                child: _Texts(event: event),
              ),
              const SizedBox(width: 8),
              _StatusChip(status: event.status),
              const SizedBox(width: 4),
              _More(onPressed: event.onMore),
            ],
          ),
        ),
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  final EventType type;
  const _Leading({required this.type});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFDDE9E0),
      child: Icon(iconForEventType(type), size: 22, color: const Color(0xFF2F6B3B)),
    );
  }
}

class _Texts extends StatelessWidget {
  final TimelineEvent event;
  const _Texts({required this.event});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(event.title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        if (event.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(event.subtitle!, style: t.bodyMedium?.copyWith(color: Colors.black54)),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.black45),
            const SizedBox(width: 6),
            Text(_formatDateTime(event.dateTime),
                style: t.bodySmall?.copyWith(color: Colors.black54)),
          ],
        ),
      ],
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _formatDateTime(DateTime dt) {
    final d = _two(dt.day);
    final m = _two(dt.month);
    final y = dt.year.toString();
    final h = _two(dt.hour);
    final k = _two(dt.minute);
    return "$d/$m/$y • $h:$k";
  }
}

class _StatusChip extends StatelessWidget {
  final EventStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    switch (status) {
      case EventStatus.agendado:
        bg = Colors.amber.withOpacity(.15);
        break;
      case EventStatus.emAndamento:
        bg = Colors.blue.withOpacity(.15);
        break;
      case EventStatus.concluido:
        bg = Colors.green.withOpacity(.15);
        break;
      case EventStatus.cancelado:
        bg = Colors.red.withOpacity(.15);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(shortStatus(status),
          style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );
  }
}

class _More extends StatelessWidget {
  final VoidCallback? onPressed;
  const _More({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: onPressed ?? () {},
      splashRadius: 20,
    );
  }
}
