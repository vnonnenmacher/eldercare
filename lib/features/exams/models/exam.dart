import 'package:flutter/material.dart';

enum ExamStatus { scheduled, collected, processing, available, canceled }

class Exam {
  final String id;
  final String patientId;
  final String name;           // e.g., "CBC", "Chest X-ray"
  final DateTime date;         // when it happened / is scheduled
  final ExamStatus status;
  final String? location;      // optional lab / clinic
  final String? resultSummary; // short text when available

  const Exam({
    required this.id,
    required this.patientId,
    required this.name,
    required this.date,
    required this.status,
    this.location,
    this.resultSummary,
  });
}

// Small helpers for UI
String formatShortDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}

String statusLabel(ExamStatus s) {
  switch (s) {
    case ExamStatus.scheduled:  return 'Agendado';
    case ExamStatus.collected:  return 'Coletado';
    case ExamStatus.processing: return 'Processando';
    case ExamStatus.available:  return 'Disponível';
    case ExamStatus.canceled:   return 'Cancelado';
  }
}

Color statusColor(BuildContext context, ExamStatus s) {
  final c = Theme.of(context).colorScheme;
  switch (s) {
    case ExamStatus.scheduled:  return c.secondary;
    case ExamStatus.collected:  return c.tertiary;
    case ExamStatus.processing: return c.primary;
    case ExamStatus.available:  return Colors.green;
    case ExamStatus.canceled:   return Colors.red;
  }
}
