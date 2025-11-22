import 'package:care_q/models/vital_signs.dart';

class PatientModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String address;
  final String emergencyLevel;
  final String symptoms;
  final Map<String, bool> symptomChecks;
  final VitalSigns vitals;
  final List<String> reports;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime registrationTime;
  final String status;
  String? room;
  String priority;

  PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
    required this.emergencyLevel,
    required this.symptoms,
    required this.symptomChecks,
    required this.vitals,
    required this.reports,
    this.photoUrl,
    required this.createdAt,
    required this.registrationTime,
    required this.status,
    this.room,
    required this.priority,
  });

  PatientModel copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? address,
    String? emergencyLevel,
    String? symptoms,
    Map<String, bool>? symptomChecks,
    VitalSigns? vitals,
    List<String>? reports,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? registrationTime,
    String? status,
    String? room,
    String? priority,
  }) {
    return PatientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      emergencyLevel: emergencyLevel ?? this.emergencyLevel,
      symptoms: symptoms ?? this.symptoms,
      symptomChecks: symptomChecks ?? this.symptomChecks,
      vitals: vitals ?? this.vitals,
      reports: reports ?? this.reports,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      registrationTime: registrationTime ?? this.registrationTime,
      status: status ?? this.status,
      room: room ?? this.room,
      priority: priority ?? this.priority,
    );
  }

  factory PatientModel.fromMap(Map<String, dynamic> map, String id) {
    return PatientModel(
      id: id,
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      phone: map['phone'],
      address: map['address'],
      emergencyLevel: map['emergencyLevel'],
      symptoms: map['symptoms'],
      symptomChecks: Map<String, bool>.from(map['symptomChecks']),
      vitals: VitalSigns.fromMap(map['vitals']),
      reports: List<String>.from(map['reports'] ?? []),
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'].toDate(),
      registrationTime: map['registrationTime']?.toDate(),
      status: map['status'],
      room: map['room'],
      priority: map['priority'] ?? 'stable',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'address': address,
      'emergencyLevel': emergencyLevel,
      'symptoms': symptoms,
      'symptomChecks': symptomChecks,
      'vitals': vitals.toMap(),
      'reports': reports,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'registrationTime': registrationTime,
      'status': status,
      'room': room,
      'priority': priority,
    };
  }
}
