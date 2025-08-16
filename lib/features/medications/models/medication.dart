class Medication {
  final String id;
  String name;
  String dose;        // ex: "100 mg"
  String schedule;    // ex: "A cada 8h" ou "Diariamente às 09:00"
  bool active;

  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.schedule,
    this.active = true,
  });
}
