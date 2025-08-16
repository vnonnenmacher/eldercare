import 'package:flutter/material.dart';

/// Tipos possíveis de evento na linha do tempo.
/// (Você pode acrescentar mais quando precisar)
enum EventType {
  consulta,            // Consulta
  exame,               // Realização de exame
  terapia,             // Sessão de terapia complementar
  medicacao,           // Tomada de medicação
  sinaisVitais,        // Sinais vitais
  rotina,              // Rotinas (ex.: hidratação, caminhada)
  ocorrencia,          // Ocorrência (ex.: queda, dor forte)
}

enum EventStatus {
  agendado,     // futuro
  emAndamento,  // ocorrendo
  concluido,    // finalizado
  cancelado,
}

/// Modelo base de um evento exibido na linha do tempo.
class TimelineEvent {
  final String id;
  final String title;             // Ex.: "Consulta de retorno", "Tomar 100mg"
  final String? subtitle;         // Ex.: "Dra. Carla", "Clínica São Lucas"
  final DateTime dateTime;        // Data/hora do evento
  final EventType type;
  final EventStatus status;

  /// Campo opcional para ações rápidas (apenas UI)
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  TimelineEvent({
    required this.id,
    required this.title,
    this.subtitle,
    required this.dateTime,
    required this.type,
    required this.status,
    this.onTap,
    this.onMore,
  });
}

/// Mapeamento de ícones por tipo (Material Icons).
IconData iconForEventType(EventType t) {
  switch (t) {
    case EventType.consulta:
      return Icons.event;
    case EventType.exame:
      return Icons.biotech;
    case EventType.terapia:
      return Icons.self_improvement;
    case EventType.medicacao:
      return Icons.medication_rounded;
    case EventType.sinaisVitais:
      return Icons.monitor_heart;
    case EventType.rotina:
      return Icons.checklist;
    case EventType.ocorrencia:
      return Icons.report_gmailerrorred;
  }
}

/// Rótulo amigável em pt-BR
String labelForEventType(EventType t) {
  switch (t) {
    case EventType.consulta:
      return "Consulta";
    case EventType.exame:
      return "Exame";
    case EventType.terapia:
      return "Terapia";
    case EventType.medicacao:
      return "Medicação";
    case EventType.sinaisVitais:
      return "Sinais vitais";
    case EventType.rotina:
      return "Rotina";
    case EventType.ocorrencia:
      return "Ocorrência";
  }
}

/// Chip de status curto
String shortStatus(EventStatus s) {
  switch (s) {
    case EventStatus.agendado:
      return "Agendado";
    case EventStatus.emAndamento:
      return "Em andamento";
    case EventStatus.concluido:
      return "Concluído";
    case EventStatus.cancelado:
      return "Cancelado";
  }
}
