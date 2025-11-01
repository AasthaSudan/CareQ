import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String address;
  final String emergencyLevel;
  final String symptoms;
  final String? photoUrl;
  final Map<String, dynamic> vitals;
  final List<String> reports;
  final Timestamp createdAt;

  PatientModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
    required this.emergencyLevel,
    required this.symptoms,
    required this.photoUrl,
    required this.vitals,
    required this.reports,
    required this.createdAt,
  });

  /// Create a modified copy of the patient
  PatientModel copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? address,
    String? emergencyLevel,
    String? symptoms,
    String? photoUrl,
    Map<String, dynamic>? vitals,
    List<String>? reports,
    Timestamp? createdAt,
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
      photoUrl: photoUrl ?? this.photoUrl,
      vitals: vitals ?? this.vitals,
      reports: reports ?? this.reports,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert patient data to Firestore map
  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'gender': gender,
    'phone': phone,
    'address': address,
    'emergencyLevel': emergencyLevel,
    'symptoms': symptoms,
    'photoUrl': photoUrl,
    'vitals': vitals,
    'reports': reports,
    'createdAt': createdAt,
  };

  /// Create PatientModel from Firestore document
  factory PatientModel.fromMap(Map<String, dynamic> map, String id) {
    return PatientModel(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      emergencyLevel: map['emergencyLevel'] ?? 'Low',
      symptoms: map['symptoms'] ?? '',
      photoUrl: map['photoUrl'],
      vitals: Map<String, dynamic>.from(map['vitals'] ?? {}),
      reports: List<String>.from(map['reports'] ?? []),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }
}
