import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String roomName;
  final String roomNumber;
  final String status;
  final String? assignedPatientId;
  final String? assignedPatientName;
  final DateTime? assignedTime;
  final String specialty;

  Room({
    required this.id,
    required this.roomName,
    required this.roomNumber,
    required this.status,
    this.assignedPatientId,
    this.assignedPatientName,
    this.assignedTime,
    required this.specialty,
  });

  // Create Room from Firestore document
  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Room(
      id: doc.id,
      roomName: data['roomName'] ?? '',
      roomNumber: data['roomNumber'] ?? '',
      status: data['status'] ?? 'available',
      assignedPatientId: data['assignedPatientId'],
      assignedPatientName: data['assignedPatientName'],
      assignedTime: data['assignedTime'] != null
          ? (data['assignedTime'] as Timestamp).toDate()
          : null,
      specialty: data['specialty'] ?? 'general',
    );
  }

  // Convert Room to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'roomName': roomName,
      'roomNumber': roomNumber,
      'status': status,
      'assignedPatientId': assignedPatientId,
      'assignedPatientName': assignedPatientName,
      'assignedTime': assignedTime != null
          ? Timestamp.fromDate(assignedTime!)
          : null,
      'specialty': specialty,
    };
  }

  // Check if room is available
  bool get isAvailable => status == 'available';

  // Get occupancy duration
  Duration? getOccupancyDuration() {
    if (assignedTime == null) return null;
    return DateTime.now().difference(assignedTime!);
  }

  // Get formatted occupancy time
  String getOccupancyTimeString() {
    Duration? duration = getOccupancyDuration();
    if (duration == null) return '--';

    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min';
    } else {
      int hours = duration.inHours;
      int minutes = duration.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }
  }

  // Copy with method
  Room copyWith({
    String? id,
    String? roomName,
    String? roomNumber,
    String? status,
    String? assignedPatientId,
    String? assignedPatientName,
    DateTime? assignedTime,
    String? specialty,
  }) {
    return Room(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      roomNumber: roomNumber ?? this.roomNumber,
      status: status ?? this.status,
      assignedPatientId: assignedPatientId ?? this.assignedPatientId,
      assignedPatientName: assignedPatientName ?? this.assignedPatientName,
      assignedTime: assignedTime ?? this.assignedTime,
      specialty: specialty ?? this.specialty,
    );
  }
}