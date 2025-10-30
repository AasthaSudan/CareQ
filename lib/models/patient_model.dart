// lib/models/patient_model.dart
class PatientModel {
  final String id;
  final String name;
  final String gender;
  final int? age;
  final String? phone;
  final String? address;
  final String? symptoms;
  final String? emergencyLevel;
  final Map<String, dynamic>? vitals;
  final List<String>? reports;

  PatientModel({
    required this.id,
    required this.name,
    required this.gender,
    this.age,
    this.phone,
    this.address,
    this.symptoms,
    this.emergencyLevel,
    this.vitals,
    this.reports,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map, String id) {
    return PatientModel(
      id: id,
      name: map['name'] ?? '',
      gender: map['gender'] ?? 'N/A',
      age: map['age'] != null ? (map['age'] as num).toInt() : null,
      phone: map['phone'],
      address: map['address'],
      symptoms: map['symptoms'],
      emergencyLevel: map['emergencyLevel'],
      vitals: map['vitals'] != null ? Map<String, dynamic>.from(map['vitals']) : null,
      reports: map['reports'] != null ? List<String>.from(map['reports']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      if (age != null) 'age': age,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (symptoms != null) 'symptoms': symptoms,
      if (emergencyLevel != null) 'emergencyLevel': emergencyLevel,
      if (vitals != null) 'vitals': vitals,
      if (reports != null) 'reports': reports,
    };
  }
}
