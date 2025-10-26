// lib/models/room_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Comprehensive Room Model for hospital room management
class Room {
  final String id;
  final String roomNumber;
  final String roomType; // ICU, General, Emergency, Private, Semi-Private
  final String? patientId;
  final String? patientName;
  final String? assignedDoctor;
  final bool isAvailable;
  final DateTime? assignedDate;
  final DateTime? expectedDischargeDate;
  final String? notes;
  final Map<String, dynamic> equipment; // Medical equipment in room
  final int capacity; // Number of beds
  final int currentOccupancy; // Current number of patients
  final String status; // available, occupied, maintenance, cleaning
  final DateTime? lastCleanedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Room({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    this.patientId,
    this.patientName,
    this.assignedDoctor,
    required this.isAvailable,
    this.assignedDate,
    this.expectedDischargeDate,
    this.notes,
    this.equipment = const {},
    this.capacity = 1,
    this.currentOccupancy = 0,
    this.status = 'available',
    this.lastCleanedAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert Room to Map for Firebase (legacy support)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'roomType': roomType,
      'patientId': patientId,
      'patientName': patientName,
      'assignedDoctor': assignedDoctor,
      'isAvailable': isAvailable,
      'assignedDate': assignedDate?.toIso8601String(),
      'expectedDischargeDate': expectedDischargeDate?.toIso8601String(),
      'notes': notes,
      'equipment': equipment,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'status': status,
      'lastCleanedAt': lastCleanedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'roomNumber': roomNumber,
      'roomType': roomType,
      'patientId': patientId,
      'patientName': patientName,
      'assignedDoctor': assignedDoctor,
      'isAvailable': isAvailable,
      'assignedDate': assignedDate != null
          ? Timestamp.fromDate(assignedDate!)
          : null,
      'expectedDischargeDate': expectedDischargeDate != null
          ? Timestamp.fromDate(expectedDischargeDate!)
          : null,
      'notes': notes,
      'equipment': equipment,
      'capacity': capacity,
      'currentOccupancy': currentOccupancy,
      'status': status,
      'lastCleanedAt': lastCleanedAt != null
          ? Timestamp.fromDate(lastCleanedAt!)
          : null,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create Room from Firebase Map (legacy support)
  factory Room.fromMap(Map<String, dynamic> map, String documentId) {
    return Room(
      id: documentId,
      roomNumber: map['roomNumber'] ?? '',
      roomType: map['roomType'] ?? 'General',
      patientId: map['patientId'],
      patientName: map['patientName'],
      assignedDoctor: map['assignedDoctor'],
      isAvailable: map['isAvailable'] ?? true,
      assignedDate: map['assignedDate'] != null
          ? (map['assignedDate'] is Timestamp
          ? (map['assignedDate'] as Timestamp).toDate()
          : DateTime.parse(map['assignedDate']))
          : null,
      expectedDischargeDate: map['expectedDischargeDate'] != null
          ? (map['expectedDischargeDate'] is Timestamp
          ? (map['expectedDischargeDate'] as Timestamp).toDate()
          : DateTime.parse(map['expectedDischargeDate']))
          : null,
      notes: map['notes'],
      equipment: Map<String, dynamic>.from(map['equipment'] ?? {}),
      capacity: map['capacity'] ?? 1,
      currentOccupancy: map['currentOccupancy'] ?? 0,
      status: map['status'] ?? 'available',
      lastCleanedAt: map['lastCleanedAt'] != null
          ? (map['lastCleanedAt'] is Timestamp
          ? (map['lastCleanedAt'] as Timestamp).toDate()
          : DateTime.parse(map['lastCleanedAt']))
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']))
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt']))
          : null,
    );
  }

  /// Create Room from Firestore Document
  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Room(
      id: doc.id,
      roomNumber: data['roomNumber'] ?? '',
      roomType: data['roomType'] ?? 'General',
      patientId: data['patientId'],
      patientName: data['patientName'],
      assignedDoctor: data['assignedDoctor'],
      isAvailable: data['isAvailable'] ?? true,
      assignedDate: data['assignedDate'] is Timestamp
          ? (data['assignedDate'] as Timestamp).toDate()
          : null,
      expectedDischargeDate: data['expectedDischargeDate'] is Timestamp
          ? (data['expectedDischargeDate'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
      equipment: Map<String, dynamic>.from(data['equipment'] ?? {}),
      capacity: data['capacity'] ?? 1,
      currentOccupancy: data['currentOccupancy'] ?? 0,
      status: data['status'] ?? 'available',
      lastCleanedAt: data['lastCleanedAt'] is Timestamp
          ? (data['lastCleanedAt'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create a copy with updated fields
  Room copyWith({
    String? id,
    String? roomNumber,
    String? roomType,
    String? patientId,
    String? patientName,
    String? assignedDoctor,
    bool? isAvailable,
    DateTime? assignedDate,
    DateTime? expectedDischargeDate,
    String? notes,
    Map<String, dynamic>? equipment,
    int? capacity,
    int? currentOccupancy,
    String? status,
    DateTime? lastCleanedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      roomType: roomType ?? this.roomType,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      assignedDoctor: assignedDoctor ?? this.assignedDoctor,
      isAvailable: isAvailable ?? this.isAvailable,
      assignedDate: assignedDate ?? this.assignedDate,
      expectedDischargeDate: expectedDischargeDate ?? this.expectedDischargeDate,
      notes: notes ?? this.notes,
      equipment: equipment ?? this.equipment,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      status: status ?? this.status,
      lastCleanedAt: lastCleanedAt ?? this.lastCleanedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==================== COMPUTED PROPERTIES ====================

  /// Check if room is occupied
  bool get isOccupied => !isAvailable || currentOccupancy > 0;

  /// Check if room is at full capacity
  bool get isAtCapacity => currentOccupancy >= capacity;

  /// Check if room has space for more patients
  bool get hasSpace => currentOccupancy < capacity && isAvailable;

  /// Get number of available beds
  int get availableBeds => capacity - currentOccupancy;

  /// Check if room has a patient assigned
  bool get hasPatient => patientId != null && patientId!.isNotEmpty;

  /// Check if room has doctor assigned
  bool get hasDoctor => assignedDoctor != null && assignedDoctor!.isNotEmpty;

  /// Check if room needs cleaning
  bool get needsCleaning {
    if (lastCleanedAt == null) return true;
    final hoursSinceCleaning = DateTime.now().difference(lastCleanedAt!).inHours;
    return hoursSinceCleaning > 24; // Needs cleaning if > 24 hours
  }

  /// Check if room is under maintenance
  bool get isUnderMaintenance => status == 'maintenance';

  /// Check if room is being cleaned
  bool get isBeingCleaned => status == 'cleaning';

  /// Check if room is critical care (ICU)
  bool get isCriticalCare => roomType.toLowerCase().contains('icu');

  /// Check if room is private
  bool get isPrivate => roomType.toLowerCase().contains('private') && capacity == 1;

  /// Check if room has equipment
  bool get hasEquipment => equipment.isNotEmpty;

  // ==================== STATUS HELPERS ====================

  /// Get human-readable status
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'occupied':
        return 'Occupied';
      case 'maintenance':
        return 'Under Maintenance';
      case 'cleaning':
        return 'Being Cleaned';
      default:
        return 'Unknown';
    }
  }

  /// Get status icon
  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'available':
        return '✅';
      case 'occupied':
        return '🛏️';
      case 'maintenance':
        return '🔧';
      case 'cleaning':
        return '🧹';
      default:
        return '📋';
    }
  }

  /// Get room type icon
  String get roomTypeIcon {
    String type = roomType.toLowerCase();
    if (type.contains('icu')) return '🚨';
    if (type.contains('emergency')) return '🚑';
    if (type.contains('private')) return '🏠';
    if (type.contains('general')) return '🏥';
    return '🛏️';
  }

  /// Get occupancy percentage
  double get occupancyPercentage {
    if (capacity == 0) return 0;
    return (currentOccupancy / capacity) * 100;
  }

  /// Get formatted occupancy string
  String get occupancyString => '$currentOccupancy / $capacity';

  // ==================== TIME-BASED METHODS ====================

  /// Get duration since room was assigned
  Duration? getAssignedDuration() {
    if (assignedDate == null) return null;
    return DateTime.now().difference(assignedDate!);
  }

  /// Get formatted assignment duration
  String getAssignedDurationString() {
    final duration = getAssignedDuration();
    if (duration == null) return 'Not assigned';

    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
  }

  /// Get time until expected discharge
  Duration? getTimeUntilDischarge() {
    if (expectedDischargeDate == null) return null;
    return expectedDischargeDate!.difference(DateTime.now());
  }

  /// Get formatted time until discharge
  String getTimeUntilDischargeString() {
    final duration = getTimeUntilDischarge();
    if (duration == null) return 'Not set';

    if (duration.isNegative) return 'Overdue';

    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inDays}d';
    }
  }

  /// Get time since last cleaning
  Duration? getTimeSinceCleaningDuration() {
    if (lastCleanedAt == null) return null;
    return DateTime.now().difference(lastCleanedAt!);
  }

  /// Get formatted time since cleaning
  String getTimeSinceCleaningString() {
    final duration = getTimeSinceCleaningDuration();
    if (duration == null) return 'Never cleaned';

    if (duration.inHours < 1) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  // ==================== EQUIPMENT METHODS ====================

  /// Check if specific equipment exists
  bool hasEquipmentType(String equipmentType) {
    return equipment.containsKey(equipmentType);
  }

  /// Get equipment count
  int get equipmentCount => equipment.length;

  /// Get equipment list as formatted string
  String getEquipmentListString() {
    if (equipment.isEmpty) return 'No equipment';
    return equipment.keys.join(', ');
  }

  // ==================== VALIDATION METHODS ====================

  /// Validate if room can accept a patient
  bool canAcceptPatient() {
    return isAvailable &&
        hasSpace &&
        status == 'available' &&
        !isUnderMaintenance &&
        !isBeingCleaned;
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    List<String> errors = [];

    if (!isAvailable) {
      errors.add('Room is not available');
    }
    if (isAtCapacity) {
      errors.add('Room is at full capacity');
    }
    if (isUnderMaintenance) {
      errors.add('Room is under maintenance');
    }
    if (isBeingCleaned) {
      errors.add('Room is being cleaned');
    }
    if (needsCleaning && isOccupied) {
      errors.add('Room needs cleaning');
    }

    return errors;
  }

  /// Check if room is ready for patient
  bool get isReady {
    return canAcceptPatient() && !needsCleaning;
  }

  @override
  String toString() {
    return 'Room(id: $id, roomNumber: $roomNumber, type: $roomType, '
        'status: $status, occupancy: $occupancyString, available: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ==================== ROOM TYPE ENUM ====================
/// Enum for room types (optional, for type safety)
enum RoomType {
  icu('ICU'),
  general('General'),
  emergency('Emergency'),
  private('Private'),
  semiPrivate('Semi-Private'),
  isolation('Isolation'),
  operating('Operating Room'),
  recovery('Recovery');

  final String label;
  const RoomType(this.label);
}

// ==================== ROOM STATUS ENUM ====================
/// Enum for room status (optional, for type safety)
enum RoomStatus {
  available('Available'),
  occupied('Occupied'),
  maintenance('Maintenance'),
  cleaning('Cleaning');

  final String label;
  const RoomStatus(this.label);
}