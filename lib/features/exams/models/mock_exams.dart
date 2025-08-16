import 'dart:math';
import 'exam.dart';

final _rnd = Random(42);

final _names = <String>[
  'Hemograma (CBC)',
  'Glicemia',
  'Colesterol',
  'Raio‑X de Tórax',
  'PCR',
  'Ureia e Creatinina',
  'EAS (Urina)',
  'TSH',
  'ECG',
  'Ultrassom Abdome'
];

ExamStatus _randomStatus() {
  const values = ExamStatus.values;
  return values[_rnd.nextInt(values.length - 1)]; // evita "canceled" ser muito comum
}

List<Exam> getExamsForPatient(String patientId, {int count = 18}) {
  final now = DateTime.now();
  return List.generate(count, (i) {
    final name = _names[i % _names.length];
    // datas distribuídas ±60 dias do presente
    final deltaDays = _rnd.nextInt(120) - 60;
    final hour = 7 + _rnd.nextInt(10);
    final minute = [0, 15, 30, 45][_rnd.nextInt(4)];
    final date = now.add(Duration(days: deltaDays, hours: hour, minutes: minute));
    final st = _randomStatus();
    final available = st == ExamStatus.available;
    return Exam(
      id: 'exam_${i + 1}',
      patientId: patientId,
      name: name,
      date: date,
      status: st,
      location: ['Lab Central', 'Clínica Norte', 'Hospital São Verde'][_rnd.nextInt(3)],
      resultSummary: available ? 'Resultado dentro da normalidade.' : null,
    );
  });
}
