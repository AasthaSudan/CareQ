import 'package:cloud_firestore/cloud_firestore.dart';

class Triage {
  final String id;
  final String patientId;
  final String priority;
  final Map<String, dynamic> vitals;
  final List<String> symptoms;
  final DateTime triageTime;
  final String? triageNotes;
  final double? aiConfidence;
  final double? riskScore;

  Triage({
    required this.id,
    required this.patientId,
    required this.priority,
    required this.vitals,
    required this.symptoms,
    required this.triageTime,
    this.triageNotes,
    this.aiConfidence,
    this.riskScore,
  });

  // Create Triage from Firestore document
  factory Triage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Triage(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      priority: data['priority'] ?? 'green',
      vitals: Map<String, dynamic>.from(data['vitals'] ?? {}),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      triageTime: (data['triageTime'] as Timestamp).toDate(),
      triageNotes: data['triageNotes'],
      aiConfidence: data['aiConfidence']?.toDouble(),
      riskScore: data['riskScore']?.toDouble(),
    );
  }

  // Convert Triage to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'priority': priority,
      'vitals': vitals,
      'symptoms': symptoms,
      'triageTime': Timestamp.fromDate(triageTime),
      'triageNotes': triageNotes,
      'aiConfidence': aiConfidence,
      'riskScore': riskScore,
    };
  }

  // Get vital sign value
  T? getVital<T>(String key) {
    return vitals[key] as T?;
  }

  // Check if vital is abnormal
  bool isVitalAbnormal(String key) {
    switch (key) {
      case 'pulse':
        int? pulse = getVital<int>('pulse');
        if (pulse == null) return false;
        return pulse < 60 || pulse > 100;

      case 'temperature':
        double? temp = getVital<double>('temperature');
        if (temp == null) return false;
        return temp < 97.0 || temp > 99.0;

      case 'oxygenLevel':
        int? oxygen = getVital<int>('oxygenLevel');
        if (oxygen == null) return false;
        return oxygen < 95;

      default:
        return false;
    }
  }

  // Get formatted vitals string
  String getVitalsString() {
    String bp = getVital<String>('bloodPressure') ?? '--/--';
    int pulse = getVital<int>('pulse') ?? 0;
    double temp = getVital<double>('temperature') ?? 0.0;
    int oxygen = getVital<int>('oxygenLevel') ?? 0;

    return 'BP: $bp | Pulse: $pulse | Temp: ${temp}°F | O2: $oxygen%';
  }

  // Copy with method
  Triage copyWith({
    String? id,
    String? patientId,
    String? priority,
    Map<String, dynamic>? vitals,
    List<String>? symptoms,
    DateTime? triageTime,
    String? triageNotes,
    double? aiConfidence,
    double? riskScore,
  }) {
    return Triage(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      priority: priority ?? this.priority,
      vitals: vitals ?? this.vitals,
      symptoms: symptoms ?? this.symptoms,
      triageTime: triageTime ?? this.triageTime,
      triageNotes: triageNotes ?? this.triageNotes,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      riskScore: riskScore ?? this.riskScore,
    );
  }
}
