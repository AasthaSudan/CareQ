import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String contact;
  final String chiefComplaint;
  final DateTime checkInTime;
  final String status;
  final String? assignedRoom;
  final String? priority;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    required this.chiefComplaint,
    required this.checkInTime,
    required this.status,
    this.assignedRoom,
    this.priority,
  });

  // Create Patient from Firestore document
  factory Patient.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Patient(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? 'Other',
      contact: data['contact'] ?? '',
      chiefComplaint: data['chiefComplaint'] ?? '',
      checkInTime: (data['checkInTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'waiting',
      assignedRoom: data['assignedRoom'],
      priority: data['priority'],
    );
  }

  // Convert Patient to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'contact': contact,
      'chiefComplaint': chiefComplaint,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'status': status,
      'assignedRoom': assignedRoom,
      'priority': priority,
    };
  }

  // Copy with method for updates
  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? contact,
    String? chiefComplaint,
    DateTime? checkInTime,
    String? status,
    String? assignedRoom,
    String? priority,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      contact: contact ?? this.contact,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      checkInTime: checkInTime ?? this.checkInTime,
      status: status ?? this.status,
      assignedRoom: assignedRoom ?? this.assignedRoom,
      priority: priority ?? this.priority,
    );
  }

  // Calculate wait time
  Duration getWaitTime() {
    return DateTime.now().difference(checkInTime);
  }

  // Format wait time as string
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
}