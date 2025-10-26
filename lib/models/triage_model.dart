// lib/models/triage_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Streamlined Triage class for modern implementation
class Triage {
  final String id;
  final String patientId;
  final String priority; // red, yellow, green
  final Map<String, dynamic> vitals;
  final List<String> symptoms;
  final DateTime triageTime;
  final String? triageNotes;
  final String? assessmentResult; // emergency, urgent, stable
  final double? aiConfidence;
  final double? riskScore;
  final List<String>? riskFactors;
  final Map<String, double>? priorityProbabilities;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Triage({
    required this.id,
    required this.patientId,
    required this.priority,
    required this.vitals,
    required this.symptoms,
    required this.triageTime,
    this.triageNotes,
    this.assessmentResult,
    this.aiConfidence,
    this.riskScore,
    this.riskFactors,
    this.priorityProbabilities,
    this.createdAt,
    this.updatedAt,
  });

  // ==================== FIRESTORE METHODS ====================

  factory Triage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Triage(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      priority: data['priority'] ?? 'green',
      vitals: Map<String, dynamic>.from(data['vitals'] ?? {}),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      triageTime: data['triageTime'] is Timestamp
          ? (data['triageTime'] as Timestamp).toDate()
          : DateTime.now(),
      triageNotes: data['triageNotes'],
      assessmentResult: data['assessmentResult'],
      aiConfidence: data['aiConfidence']?.toDouble(),
      riskScore: data['riskScore']?.toDouble(),
      riskFactors: data['riskFactors'] != null
          ? List<String>.from(data['riskFactors'])
          : null,
      priorityProbabilities: data['priorityProbabilities'] != null
          ? Map<String, double>.from(data['priorityProbabilities'])
          : null,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'priority': priority,
      'vitals': vitals,
      'symptoms': symptoms,
      'triageTime': Timestamp.fromDate(triageTime),
      'triageNotes': triageNotes,
      'assessmentResult': assessmentResult,
      'aiConfidence': aiConfidence,
      'riskScore': riskScore,
      'riskFactors': riskFactors ?? [],
      'priorityProbabilities': priorityProbabilities ?? {},
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Triage copyWith({
    String? id,
    String? patientId,
    String? priority,
    Map<String, dynamic>? vitals,
    List<String>? symptoms,
    DateTime? triageTime,
    String? triageNotes,
    String? assessmentResult,
    double? aiConfidence,
    double? riskScore,
    List<String>? riskFactors,
    Map<String, double>? priorityProbabilities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Triage(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      priority: priority ?? this.priority,
      vitals: vitals ?? this.vitals,
      symptoms: symptoms ?? this.symptoms,
      triageTime: triageTime ?? this.triageTime,
      triageNotes: triageNotes ?? this.triageNotes,
      assessmentResult: assessmentResult ?? this.assessmentResult,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      riskScore: riskScore ?? this.riskScore,
      riskFactors: riskFactors ?? this.riskFactors,
      priorityProbabilities: priorityProbabilities ?? this.priorityProbabilities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==================== COMPUTED PROPERTIES ====================

  /// Check if has AI analysis
  bool get hasAIAnalysis => aiConfidence != null && riskScore != null;

  /// Check if critical
  bool get isCritical => priority == 'red';

  /// Check if urgent
  bool get isUrgent => priority == 'yellow';

  /// Check if stable
  bool get isStable => priority == 'green';

  /// Check if has vitals recorded
  bool get hasVitals => vitals.isNotEmpty;

  /// Check if has symptoms recorded
  bool get hasSymptoms => symptoms.isNotEmpty;

  /// Check if has risk factors
  bool get hasRiskFactors => riskFactors != null && riskFactors!.isNotEmpty;

  /// Check if has notes
  bool get hasNotes => triageNotes != null && triageNotes!.isNotEmpty;

  // ==================== VITALS HELPERS ====================

  /// Get specific vital value
  T? getVital<T>(String key) {
    return vitals[key] as T?;
  }

  /// Get blood pressure
  String? get bloodPressure => getVital<String>('bloodPressure');

  /// Get pulse
  int? get pulse => getVital<int>('pulse');

  /// Get temperature
  double? get temperature => getVital<double>('temperature');

  /// Get oxygen level
  int? get oxygenLevel => getVital<int>('oxygenLevel');

  /// Check if vital is abnormal
  bool isVitalAbnormal(String key) {
    switch (key) {
      case 'pulse':
        if (pulse == null) return false;
        return pulse! < 60 || pulse! > 100;

      case 'temperature':
        if (temperature == null) return false;
        return temperature! < 97.0 || temperature! > 99.0;

      case 'oxygenLevel':
        if (oxygenLevel == null) return false;
        return oxygenLevel! < 95;

      case 'bloodPressure':
        if (bloodPressure == null || !bloodPressure!.contains('/')) return false;
        List<String> parts = bloodPressure!.split('/');
        int systolic = int.tryParse(parts[0]) ?? 120;
        int diastolic = int.tryParse(parts[1]) ?? 80;
        return systolic < 90 || systolic > 140 || diastolic < 60 || diastolic > 90;

      default:
        return false;
    }
  }

  /// Check if any vital is abnormal
  bool get hasAbnormalVitals {
    if (!hasVitals) return false;
    return isVitalAbnormal('pulse') ||
        isVitalAbnormal('temperature') ||
        isVitalAbnormal('oxygenLevel') ||
        isVitalAbnormal('bloodPressure');
  }

  /// Get formatted vitals string
  String getVitalsString() {
    if (!hasVitals) return 'No vitals recorded';

    String bp = bloodPressure ?? '--/--';
    int p = pulse ?? 0;
    double temp = temperature ?? 0.0;
    int oxygen = oxygenLevel ?? 0;

    return 'BP: $bp | Pulse: $p bpm | Temp: $temp°F | O2: $oxygen%';
  }

  // ==================== AI ANALYSIS HELPERS ====================

  /// Get AI confidence as percentage string
  String get aiConfidenceString {
    if (aiConfidence == null) return 'N/A';
    return '${aiConfidence!.toStringAsFixed(1)}%';
  }

  /// Get risk score as string
  String get riskScoreString {
    if (riskScore == null) return 'N/A';
    return riskScore!.toStringAsFixed(1);
  }

  /// Get risk level based on score
  String get riskLevel {
    if (riskScore == null) return 'Unknown';
    if (riskScore! >= 80) return 'Very High';
    if (riskScore! >= 60) return 'High';
    if (riskScore! >= 40) return 'Moderate';
    if (riskScore! >= 20) return 'Low';
    return 'Very Low';
  }

  /// Get highest probability priority
  String? get aiRecommendedPriority {
    if (priorityProbabilities == null || priorityProbabilities!.isEmpty) {
      return null;
    }

    String? highestPriority;
    double highestProb = 0;

    priorityProbabilities!.forEach((priority, probability) {
      if (probability > highestProb) {
        highestProb = probability;
        highestPriority = priority;
      }
    });

    return highestPriority;
  }

  /// Check if AI and manual priorities match
  bool get prioritiesMatch {
    if (aiRecommendedPriority == null) return true;
    return priority == aiRecommendedPriority;
  }

  // ==================== TIME CALCULATIONS ====================

  /// Get time since triage
  Duration getTimeSinceTriage() {
    return DateTime.now().difference(triageTime);
  }

  /// Get formatted time since triage
  String getTimeSinceTriageString() {
    Duration time = getTimeSinceTriage();
    if (time.inMinutes < 60) {
      return '${time.inMinutes} min ago';
    } else {
      int hours = time.inHours;
      int minutes = time.inMinutes % 60;
      return '${hours}h ${minutes}m ago';
    }
  }

  /// Check if triage is recent (within last hour)
  bool get isRecentTriage => getTimeSinceTriage().inHours < 1;

  // ==================== DISPLAY HELPERS ====================

  /// Get priority icon
  String get priorityIcon {
    switch (priority.toLowerCase()) {
      case 'red':
        return '🚨';
      case 'yellow':
        return '⚠️';
      case 'green':
        return '✓';
      default:
        return '?';
    }
  }

  /// Get priority label
  String get priorityLabel {
    switch (priority.toLowerCase()) {
      case 'red':
        return 'CRITICAL';
      case 'yellow':
        return 'URGENT';
      case 'green':
        return 'NON-URGENT';
      default:
        return 'UNKNOWN';
    }
  }

  /// Get assessment icon
  String get assessmentIcon {
    if (assessmentResult == null) return '📋';
    switch (assessmentResult!.toLowerCase()) {
      case 'emergency':
        return '🚑';
      case 'urgent':
        return '⏰';
      case 'stable':
        return '✅';
      default:
        return '📋';
    }
  }

  /// Get assessment label
  String get assessmentLabel {
    if (assessmentResult == null) return 'Not Assessed';
    switch (assessmentResult!.toLowerCase()) {
      case 'emergency':
        return 'EMERGENCY';
      case 'urgent':
        return 'URGENT';
      case 'stable':
        return 'STABLE';
      default:
        return 'UNKNOWN';
    }
  }

  // ==================== VALIDATION ====================

  /// Validate triage data
  bool isValid() {
    return patientId.isNotEmpty &&
        priority.isNotEmpty &&
        vitals.isNotEmpty;
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    List<String> errors = [];

    if (patientId.isEmpty) errors.add('Patient ID is required');
    if (priority.isEmpty) errors.add('Priority is required');
    if (!hasVitals) errors.add('Vitals are required');

    return errors;
  }

  // ==================== LEGACY COMPATIBILITY ====================

  /// Convert to TriageModel (for legacy compatibility)
  TriageModel toTriageModel() {
    return TriageModel(
      id: id,
      patientId: patientId,
      triageLevel: priority,
      priority: priority,
      vitals: vitals,
      symptoms: symptoms,
      symptomsSeverity: {},
      assessmentResult: assessmentResult ??
          (priority == 'red'
              ? 'emergency'
              : priority == 'yellow'
              ? 'urgent'
              : 'stable'),
      triageTime: triageTime,
      triageNotes: triageNotes,
      aiConfidence: aiConfidence,
      riskScore: riskScore,
      riskFactors: riskFactors,
      priorityProbabilities: priorityProbabilities,
    );
  }

  /// Create from TriageModel
  factory Triage.fromTriageModel(TriageModel model) {
    return Triage(
      id: model.id,
      patientId: model.patientId,
      priority: model.priority,
      vitals: model.vitals,
      symptoms: model.symptoms,
      triageTime: model.triageTime ?? DateTime.now(),
      triageNotes: model.triageNotes,
      assessmentResult: model.assessmentResult,
      aiConfidence: model.aiConfidence,
      riskScore: model.riskScore,
      riskFactors: model.riskFactors,
      priorityProbabilities: model.priorityProbabilities,
    );
  }

  @override
  String toString() {
    return 'Triage(id: $id, patientId: $patientId, priority: $priority, '
        'hasAI: $hasAIAnalysis, confidence: $aiConfidenceString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Triage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ==================== LEGACY TRIAGE MODEL ====================
/// Legacy Triage Model for backward compatibility
class TriageModel {
  String id;
  String patientId;
  String triageLevel;
  String priority;
  Map<String, dynamic> symptomsSeverity;
  Map<String, dynamic> vitals;
  List<String> symptoms;
  String assessmentResult;
  DateTime? triageTime;
  String? triageNotes;
  double? aiConfidence;
  double? riskScore;
  List<String>? riskFactors;
  Map<String, double>? priorityProbabilities;

  TriageModel({
    this.id = '',
    required this.patientId,
    required this.triageLevel,
    String? priority,
    this.symptomsSeverity = const {},
    this.vitals = const {},
    this.symptoms = const [],
    required this.assessmentResult,
    DateTime? triageTime,
    this.triageNotes,
    this.aiConfidence,
    this.riskScore,
    this.riskFactors,
    this.priorityProbabilities,
  })  : priority = priority ?? triageLevel,
        triageTime = triageTime ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'triageLevel': triageLevel,
      'priority': priority,
      'symptomsSeverity': symptomsSeverity,
      'vitals': vitals,
      'symptoms': symptoms,
      'assessmentResult': assessmentResult,
      'triageTime': triageTime?.toIso8601String(),
      'triageNotes': triageNotes,
      'aiConfidence': aiConfidence,
      'riskScore': riskScore,
      'riskFactors': riskFactors,
      'priorityProbabilities': priorityProbabilities,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'triageLevel': triageLevel,
      'priority': priority,
      'symptomsSeverity': symptomsSeverity,
      'vitals': vitals,
      'symptoms': symptoms,
      'assessmentResult': assessmentResult,
      'triageTime': triageTime != null
          ? Timestamp.fromDate(triageTime!)
          : FieldValue.serverTimestamp(),
      'triageNotes': triageNotes,
      'aiConfidence': aiConfidence,
      'riskScore': riskScore,
      'riskFactors': riskFactors ?? [],
      'priorityProbabilities': priorityProbabilities ?? {},
    };
  }

  factory TriageModel.fromMap(Map<String, dynamic> map) {
    return TriageModel(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      triageLevel: map['triageLevel'] ?? map['priority'] ?? 'green',
      priority: map['priority'] ?? map['triageLevel'] ?? 'green',
      symptomsSeverity: Map<String, dynamic>.from(map['symptomsSeverity'] ?? {}),
      vitals: Map<String, dynamic>.from(map['vitals'] ?? {}),
      symptoms: List<String>.from(map['symptoms'] ?? []),
      assessmentResult: map['assessmentResult'] ?? 'stable',
      triageTime: map['triageTime'] != null
          ? DateTime.parse(map['triageTime'])
          : DateTime.now(),
      triageNotes: map['triageNotes'],
      aiConfidence: map['aiConfidence']?.toDouble(),
      riskScore: map['riskScore']?.toDouble(),
      riskFactors: map['riskFactors'] != null
          ? List<String>.from(map['riskFactors'])
          : null,
      priorityProbabilities: map['priorityProbabilities'] != null
          ? Map<String, double>.from(map['priorityProbabilities'])
          : null,
    );
  }

  factory TriageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return TriageModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      triageLevel: data['triageLevel'] ?? data['priority'] ?? 'green',
      priority: data['priority'] ?? data['triageLevel'] ?? 'green',
      symptomsSeverity: Map<String, dynamic>.from(data['symptomsSeverity'] ?? {}),
      vitals: Map<String, dynamic>.from(data['vitals'] ?? {}),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      assessmentResult: data['assessmentResult'] ?? 'stable',
      triageTime: data['triageTime'] is Timestamp
          ? (data['triageTime'] as Timestamp).toDate()
          : DateTime.now(),
      triageNotes: data['triageNotes'],
      aiConfidence: data['aiConfidence']?.toDouble(),
      riskScore: data['riskScore']?.toDouble(),
      riskFactors: data['riskFactors'] != null
          ? List<String>.from(data['riskFactors'])
          : null,
      priorityProbabilities: data['priorityProbabilities'] != null
          ? Map<String, double>.from(data['priorityProbabilities'])
          : null,
    );
  }

  TriageModel copyWith({
    String? id,
    String? patientId,
    String? triageLevel,
    String? priority,
    Map<String, dynamic>? symptomsSeverity,
    Map<String, dynamic>? vitals,
    List<String>? symptoms,
    String? assessmentResult,
    DateTime? triageTime,
    String? triageNotes,
    double? aiConfidence,
    double? riskScore,
    List<String>? riskFactors,
    Map<String, double>? priorityProbabilities,
  }) {
    return TriageModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      triageLevel: triageLevel ?? this.triageLevel,
      priority: priority ?? this.priority,
      symptomsSeverity: symptomsSeverity ?? this.symptomsSeverity,
      vitals: vitals ?? this.vitals,
      symptoms: symptoms ?? this.symptoms,
      assessmentResult: assessmentResult ?? this.assessmentResult,
      triageTime: triageTime ?? this.triageTime,
      triageNotes: triageNotes ?? this.triageNotes,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      riskScore: riskScore ?? this.riskScore,
      riskFactors: riskFactors ?? this.riskFactors,
      priorityProbabilities: priorityProbabilities ?? this.priorityProbabilities,
    );
  }

  T? getVital<T>(String key) => vitals[key] as T?;

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
      case 'bloodPressure':
        String? bp = getVital<String>('bloodPressure');
        if (bp == null || !bp.contains('/')) return false;
        List<String> parts = bp.split('/');
        int systolic = int.tryParse(parts[0]) ?? 120;
        int diastolic = int.tryParse(parts[1]) ?? 80;
        return systolic < 90 || systolic > 140 || diastolic < 60 || diastolic > 90;
      default:
        return false;
    }
  }

  String getVitalsString() {
    String bp = getVital<String>('bloodPressure') ?? '--/--';
    int pulse = getVital<int>('pulse') ?? 0;
    double temp = getVital<double>('temperature') ?? 0.0;
    int oxygen = getVital<int>('oxygenLevel') ?? 0;
    return 'BP: $bp | Pulse: $pulse bpm | Temp: $temp°F | O2: $oxygen%';
  }

  bool get isCritical => priority == 'red' || triageLevel == 'red';
  bool get isUrgent => priority == 'yellow' || triageLevel == 'yellow';
  bool get isStable => priority == 'green' || triageLevel == 'green';
  bool get hasAIAnalysis => aiConfidence != null && riskScore != null;

  String get priorityIcon {
    switch (priority.toLowerCase()) {
      case 'red': return '🚨';
      case 'yellow': return '⚠️';
      case 'green': return '✓';
      default: return '?';
    }
  }

  String get priorityLabel {
    switch (priority.toLowerCase()) {
      case 'red': return 'CRITICAL';
      case 'yellow': return 'URGENT';
      case 'green': return 'NON-URGENT';
      default: return 'UNKNOWN';
    }
  }

  String get assessmentIcon {
    switch (assessmentResult.toLowerCase()) {
      case 'emergency': return '🚑';
      case 'urgent': return '⏰';
      case 'stable': return '✅';
      default: return '📋';
    }
  }

  String get aiConfidenceString {
    if (aiConfidence == null) return 'N/A';
    return '${aiConfidence!.toStringAsFixed(1)}%';
  }

  String get riskScoreString {
    if (riskScore == null) return 'N/A';
    return riskScore!.toStringAsFixed(1);
  }

  Duration getTimeSinceTriage() {
    if (triageTime == null) return Duration.zero;
    return DateTime.now().difference(triageTime!);
  }

  String getTimeSinceTriageString() {
    Duration time = getTimeSinceTriage();
    if (time.inMinutes < 60) {
      return '${time.inMinutes} min ago';
    } else {
      int hours = time.inHours;
      int minutes = time.inMinutes % 60;
      return '${hours}h ${minutes}m ago';
    }
  }

  @override
  String toString() {
    return 'TriageModel(id: $id, patientId: $patientId, priority: $priority, '
        'assessment: $assessmentResult, aiConfidence: $aiConfidenceString)';
  }
}