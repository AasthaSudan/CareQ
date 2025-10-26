// lib/models/patient_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Streamlined Patient class for modern implementation
class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String contact;
  final String? phone;
  final String? address;
  final String chiefComplaint;
  final DateTime checkInTime;
  final String status; // waiting | in-treatment | discharged
  final String priority; // red | yellow | green
  final String? assignedRoom;
  final String? assignedDoctor;
  final Map<String, dynamic> vitals;
  final List<String> symptoms;
  final Map<String, dynamic> aiAnalysis;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    this.phone,
    this.address,
    required this.chiefComplaint,
    required this.checkInTime,
    this.status = 'waiting',
    this.priority = 'green',
    this.assignedRoom,
    this.assignedDoctor,
    this.vitals = const {},
    this.symptoms = const [],
    this.aiAnalysis = const {},
    this.createdAt,
    this.updatedAt,
  });

  // ==================== FIRESTORE METHODS ====================

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Patient(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? 'Other',
      contact: data['contact'] ?? data['phone'] ?? '',
      phone: data['phone'],
      address: data['address'],
      chiefComplaint: data['chiefComplaint'] ?? '',
      checkInTime: data['checkInTime'] is Timestamp
          ? (data['checkInTime'] as Timestamp).toDate()
          : DateTime.now(),
      status: data['status'] ?? 'waiting',
      priority: data['priority'] ?? 'green',
      assignedRoom: data['assignedRoom'],
      assignedDoctor: data['assignedDoctor'],
      vitals: Map<String, dynamic>.from(data['vitals'] ?? {}),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      aiAnalysis: Map<String, dynamic>.from(data['aiAnalysis'] ?? {}),
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
      'name': name,
      'age': age,
      'gender': gender,
      'contact': contact,
      'phone': phone ?? contact,
      'address': address,
      'chiefComplaint': chiefComplaint,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'status': status,
      'priority': priority,
      'assignedRoom': assignedRoom,
      'assignedDoctor': assignedDoctor,
      'vitals': vitals,
      'symptoms': symptoms,
      'aiAnalysis': aiAnalysis,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? contact,
    String? phone,
    String? address,
    String? chiefComplaint,
    DateTime? checkInTime,
    String? status,
    String? priority,
    String? assignedRoom,
    String? assignedDoctor,
    Map<String, dynamic>? vitals,
    List<String>? symptoms,
    Map<String, dynamic>? aiAnalysis,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      contact: contact ?? this.contact,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      checkInTime: checkInTime ?? this.checkInTime,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedRoom: assignedRoom ?? this.assignedRoom,
      assignedDoctor: assignedDoctor ?? this.assignedDoctor,
      vitals: vitals ?? this.vitals,
      symptoms: symptoms ?? this.symptoms,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==================== COMPUTED PROPERTIES ====================

  /// Check if patient has room assigned
  bool get hasRoom => assignedRoom != null && assignedRoom!.isNotEmpty;

  /// Check if patient has doctor assigned
  bool get hasDoctor => assignedDoctor != null && assignedDoctor!.isNotEmpty;

  /// Check if patient has vitals recorded
  bool get hasVitals => vitals.isNotEmpty;

  /// Check if patient has symptoms recorded
  bool get hasSymptoms => symptoms.isNotEmpty;

  /// Check if patient has AI analysis
  bool get hasAIAnalysis => aiAnalysis.isNotEmpty;

  /// Check if patient is critical
  bool get isCritical => priority == 'red';

  /// Check if patient is urgent
  bool get isUrgent => priority == 'yellow';

  /// Check if patient is non-urgent
  bool get isNonUrgent => priority == 'green';

  /// Check if patient is waiting
  bool get isWaiting => status == 'waiting';

  /// Check if patient is in treatment
  bool get isInTreatment => status == 'in-treatment';

  /// Check if patient is discharged
  bool get isDischarged => status == 'discharged';

  // ==================== TIME CALCULATIONS ====================

  /// Get wait time duration
  Duration getWaitTime() {
    return DateTime.now().difference(checkInTime);
  }

  /// Get formatted wait time
  String getWaitTimeString() {
    Duration wait = getWaitTime();
    if (wait.inMinutes < 60) {
      return '${wait.inMinutes} min';
    } else {
      int hours = wait.inHours;
      int minutes = wait.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }
  }

  /// Check if patient has been waiting too long (over 2 hours)
  bool get isWaitingTooLong => getWaitTime().inHours >= 2;

  // ==================== DISPLAY HELPERS ====================

  /// Get priority icon
  String get priorityIcon {
    switch (priority) {
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
    switch (priority) {
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

  /// Get status icon
  String get statusIcon {
    switch (status) {
      case 'waiting':
        return '⏳';
      case 'in-treatment':
        return '🏥';
      case 'discharged':
        return '✅';
      default:
        return '📋';
    }
  }

  /// Get status label
  String get statusLabel {
    switch (status) {
      case 'waiting':
        return 'Waiting';
      case 'in-treatment':
        return 'In Treatment';
      case 'discharged':
        return 'Discharged';
      default:
        return 'Unknown';
    }
  }

  /// Get patient display name with age
  String get displayName => '$name ($age)';

  /// Get formatted contact info
  String get formattedContact {
    if (phone != null && phone != contact) {
      return '$contact / $phone';
    }
    return contact;
  }

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

  /// Get formatted vitals string
  String getVitalsString() {
    if (!hasVitals) return 'No vitals recorded';

    String bp = bloodPressure ?? '--/--';
    int p = pulse ?? 0;
    double temp = temperature ?? 0.0;
    int oxygen = oxygenLevel ?? 0;

    return 'BP: $bp | Pulse: $p bpm | Temp: $temp°F | O2: $oxygen%';
  }

  /// Check if any vital is abnormal
  bool get hasAbnormalVitals {
    if (!hasVitals) return false;

    // Check pulse
    if (pulse != null && (pulse! < 60 || pulse! > 100)) return true;

    // Check temperature
    if (temperature != null && (temperature! < 97.0 || temperature! > 99.0)) {
      return true;
    }

    // Check oxygen
    if (oxygenLevel != null && oxygenLevel! < 95) return true;

    // Check blood pressure
    if (bloodPressure != null && bloodPressure!.contains('/')) {
      List<String> parts = bloodPressure!.split('/');
      int systolic = int.tryParse(parts[0]) ?? 120;
      int diastolic = int.tryParse(parts[1]) ?? 80;
      if (systolic < 90 || systolic > 140 || diastolic < 60 || diastolic > 90) {
        return true;
      }
    }

    return false;
  }

  // ==================== AI ANALYSIS HELPERS ====================

  /// Get AI confidence score
  double? get aiConfidence => aiAnalysis['confidence']?.toDouble();

  /// Get AI risk score
  double? get aiRiskScore => aiAnalysis['riskScore']?.toDouble();

  /// Get AI recommended priority
  String? get aiRecommendedPriority => aiAnalysis['recommendedPriority'] as String?;

  /// Get AI notes
  String? get aiNotes => aiAnalysis['notes'] as String?;

  /// Get formatted AI confidence string
  String get aiConfidenceString {
    if (aiConfidence == null) return 'N/A';
    return '${aiConfidence!.toStringAsFixed(1)}%';
  }

  // ==================== VALIDATION ====================

  /// Validate patient data
  bool isValid() {
    return name.isNotEmpty &&
        age > 0 &&
        contact.isNotEmpty &&
        chiefComplaint.isNotEmpty;
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    List<String> errors = [];

    if (name.isEmpty) errors.add('Name is required');
    if (age <= 0) errors.add('Valid age is required');
    if (contact.isEmpty) errors.add('Contact is required');
    if (chiefComplaint.isEmpty) errors.add('Chief complaint is required');

    return errors;
  }

  // ==================== LEGACY COMPATIBILITY ====================

  /// Convert to PatientModel (for legacy compatibility)
  PatientModel toPatientModel() {
    return PatientModel(
      id: id,
      name: name,
      age: age,
      gender: gender,
      phone: phone ?? contact,
      contact: contact,
      address: address ?? '',
      chiefComplaint: chiefComplaint,
      checkInTime: checkInTime,
      status: status,
      priority: priority,
      assignedRoom: assignedRoom ?? '',
      assignedDoctor: assignedDoctor ?? '',
      vitals: vitals,
      symptoms: symptoms,
      aiAnalysis: aiAnalysis,
    );
  }

  /// Create from PatientModel
  factory Patient.fromPatientModel(PatientModel model) {
    return Patient(
      id: model.id,
      name: model.name,
      age: model.age,
      gender: model.gender ?? 'Other',
      contact: model.contact ?? model.phone,
      phone: model.phone,
      address: model.address,
      chiefComplaint: model.chiefComplaint ?? '',
      checkInTime: model.checkInTime ?? DateTime.now(),
      status: model.status,
      priority: model.priority,
      assignedRoom: model.assignedRoom.isEmpty ? null : model.assignedRoom,
      assignedDoctor: model.assignedDoctor.isEmpty ? null : model.assignedDoctor,
      vitals: model.vitals,
      symptoms: model.symptoms,
      aiAnalysis: model.aiAnalysis,
    );
  }

  @override
  String toString() {
    return 'Patient(id: $id, name: $name, age: $age, priority: $priority, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ==================== LEGACY PATIENT MODEL ====================
/// Legacy Patient Model for backward compatibility
class PatientModel {
  String id;
  String name;
  int age;
  String? gender;
  String phone;
  String address;
  String? contact;
  String? chiefComplaint;
  DateTime? checkInTime;
  String status;
  Map<String, dynamic> vitals;
  List<String> symptoms;
  String priority;
  String assignedDoctor;
  String assignedRoom;
  Map<String, String> medicalRecords;
  Map<String, dynamic> dischargeSummary;
  Map<String, dynamic> aiAnalysis;

  PatientModel({
    required this.id,
    required this.name,
    required this.age,
    this.gender,
    required this.phone,
    required this.address,
    this.contact,
    this.chiefComplaint,
    DateTime? checkInTime,
    this.status = 'waiting',
    this.vitals = const {},
    this.symptoms = const [],
    this.priority = 'green',
    this.assignedDoctor = '',
    this.assignedRoom = '',
    this.medicalRecords = const {},
    this.dischargeSummary = const {},
    this.aiAnalysis = const {},
  }) : checkInTime = checkInTime ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'contact': contact ?? phone,
      'address': address,
      'chiefComplaint': chiefComplaint,
      'checkInTime': checkInTime != null
          ? Timestamp.fromDate(checkInTime!)
          : FieldValue.serverTimestamp(),
      'status': status,
      'vitals': vitals,
      'symptoms': symptoms,
      'priority': priority,
      'assignedDoctor': assignedDoctor,
      'assignedRoom': assignedRoom,
      'medicalRecords': medicalRecords,
      'dischargeSummary': dischargeSummary,
      'aiAnalysis': aiAnalysis,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'contact': contact ?? phone,
      'phone': phone,
      'address': address,
      'chiefComplaint': chiefComplaint,
      'checkInTime': checkInTime != null
          ? Timestamp.fromDate(checkInTime!)
          : FieldValue.serverTimestamp(),
      'status': status,
      'vitals': vitals,
      'symptoms': symptoms,
      'priority': priority,
      'assignedDoctor': assignedDoctor,
      'assignedRoom': assignedRoom,
      'medicalRecords': medicalRecords,
      'dischargeSummary': dischargeSummary,
      'aiAnalysis': aiAnalysis,
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'],
      phone: map['phone'] ?? map['contact'] ?? '',
      contact: map['contact'] ?? map['phone'],
      address: map['address'] ?? '',
      chiefComplaint: map['chiefComplaint'],
      checkInTime: map['checkInTime'] is Timestamp
          ? (map['checkInTime'] as Timestamp).toDate()
          : DateTime.now(),
      status: map['status'] ?? 'waiting',
      vitals: Map<String, dynamic>.from(map['vitals'] ?? {}),
      symptoms: List<String>.from(map['symptoms'] ?? []),
      priority: map['priority'] ?? 'green',
      assignedDoctor: map['assignedDoctor'] ?? '',
      assignedRoom: map['assignedRoom'] ?? '',
      medicalRecords: Map<String, String>.from(map['medicalRecords'] ?? {}),
      dischargeSummary: Map<String, dynamic>.from(map['dischargeSummary'] ?? {}),
      aiAnalysis: Map<String, dynamic>.from(map['aiAnalysis'] ?? {}),
    );
  }

  factory PatientModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PatientModel(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'],
      phone: data['phone'] ?? data['contact'] ?? '',
      contact: data['contact'] ?? data['phone'],
      address: data['address'] ?? '',
      chiefComplaint: data['chiefComplaint'],
      checkInTime: data['checkInTime'] is Timestamp
          ? (data['checkInTime'] as Timestamp).toDate()
          : DateTime.now(),
      status: data['status'] ?? 'waiting',
      vitals: Map<String, dynamic>.from(data['vitals'] ?? {}),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      priority: data['priority'] ?? 'green',
      assignedDoctor: data['assignedDoctor'] ?? '',
      assignedRoom: data['assignedRoom'] ?? '',
      medicalRecords: Map<String, String>.from(data['medicalRecords'] ?? {}),
      dischargeSummary: Map<String, dynamic>.from(data['dischargeSummary'] ?? {}),
      aiAnalysis: Map<String, dynamic>.from(data['aiAnalysis'] ?? {}),
    );
  }

  PatientModel copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? contact,
    String? address,
    String? chiefComplaint,
    DateTime? checkInTime,
    String? status,
    Map<String, dynamic>? vitals,
    List<String>? symptoms,
    String? priority,
    String? assignedDoctor,
    String? assignedRoom,
    Map<String, String>? medicalRecords,
    Map<String, dynamic>? dischargeSummary,
    Map<String, dynamic>? aiAnalysis,
  }) {
    return PatientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      checkInTime: checkInTime ?? this.checkInTime,
      status: status ?? this.status,
      vitals: vitals ?? this.vitals,
      symptoms: symptoms ?? this.symptoms,
      priority: priority ?? this.priority,
      assignedDoctor: assignedDoctor ?? this.assignedDoctor,
      assignedRoom: assignedRoom ?? this.assignedRoom,
      medicalRecords: medicalRecords ?? this.medicalRecords,
      dischargeSummary: dischargeSummary ?? this.dischargeSummary,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
    );
  }

  Duration getWaitTime() {
    if (checkInTime == null) return Duration.zero;
    return DateTime.now().difference(checkInTime!);
  }

  String getWaitTimeString() {
    Duration wait = getWaitTime();
    if (wait.inMinutes < 60) {
      return '${wait.inMinutes} min';
    } else {
      int hours = wait.inHours;
      int minutes = wait.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }
  }

  bool get isCritical => priority == 'red';
  bool get isUrgent => priority == 'yellow';
  bool get isNonUrgent => priority == 'green';
  bool get hasVitals => vitals.isNotEmpty;
  bool get hasSymptoms => symptoms.isNotEmpty;
  bool get hasAIAnalysis => aiAnalysis.isNotEmpty;
  bool get hasRoom => assignedRoom.isNotEmpty;
  bool get hasDoctor => assignedDoctor.isNotEmpty;

  String get priorityIcon {
    switch (priority) {
      case 'red': return '🚨';
      case 'yellow': return '⚠️';
      case 'green': return '✓';
      default: return '?';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'red': return 'CRITICAL';
      case 'yellow': return 'URGENT';
      case 'green': return 'NON-URGENT';
      default: return 'UNKNOWN';
    }
  }

  String get statusIcon {
    switch (status) {
      case 'waiting': return '⏳';
      case 'in-treatment': return '🏥';
      case 'discharged': return '✅';
      default: return '📋';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'waiting': return 'Waiting';
      case 'in-treatment': return 'In Treatment';
      case 'discharged': return 'Discharged';
      default: return 'Unknown';
    }
  }

  @override
  String toString() {
    return 'PatientModel(id: $id, name: $name, age: $age, priority: $priority, status: $status)';
  }
}