import 'package:flutter/material.dart';
import 'event.dart';

/// Gera uma lista de eventos mock para a UI.
/// Em produção você trocará por seu repositório local/serviço.
List<TimelineEvent> mockEvents({required String patientId}) {
  final now = DateTime.now();
  final todayAt = (int h, int m) =>
      DateTime(now.year, now.month, now.day, h, m);

  final yesterday = now.subtract(const Duration(days: 1));
  final yAt = (int h, int m) =>
      DateTime(yesterday.year, yesterday.month, yesterday.day, h, m);

  final lastWeek = now.subtract(const Duration(days: 5));
  final lwAt = (int h, int m) =>
      DateTime(lastWeek.year, lastWeek.month, lastWeek.day, h, m);

  return [
    // Hoje
    TimelineEvent(
      id: "e1",
      title: "Próxima consulta",
      subtitle: "Hoje às 16:00 • Dr. Paulo",
      dateTime: todayAt(16, 00),
      type: EventType.consulta,
      status: EventStatus.agendado,
    ),
    TimelineEvent(
      id: "e2",
      title: "Tomar 100mg de Atorvastatina",
      subtitle: "Após o jantar",
      dateTime: todayAt(20, 00),
      type: EventType.medicacao,
      status: EventStatus.agendado,
    ),
    TimelineEvent(
      id: "e3",
      title: "Medição de pressão",
      subtitle: "Resultado: 12x8",
      dateTime: todayAt(14, 10),
      type: EventType.sinaisVitais,
      status: EventStatus.concluido,
    ),

    // Ontem
    TimelineEvent(
      id: "e4",
      title: "Exame de sangue",
      subtitle: "Coleta realizada",
      dateTime: yAt(9, 00),
      type: EventType.exame,
      status: EventStatus.concluido,
    ),
    TimelineEvent(
      id: "e5",
      title: "Sessão de fisioterapia",
      subtitle: "Clínica Movimente",
      dateTime: yAt(18, 30),
      type: EventType.terapia,
      status: EventStatus.concluido,
    ),

    // Semana passada
    TimelineEvent(
      id: "e6",
      title: "Ocorrência: Dor torácica (0–10: 6)",
      subtitle: "Duração ~15min, repouso melhorou",
      dateTime: lwAt(21, 05),
      type: EventType.ocorrencia,
      status: EventStatus.concluido,
    ),
    TimelineEvent(
      id: "e7",
      title: "Caminhada diária",
      subtitle: "30 min • Parque",
      dateTime: lwAt(7, 20),
      type: EventType.rotina,
      status: EventStatus.concluido,
    ),
  ];
}
