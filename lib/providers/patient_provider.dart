import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/patient_model.dart';
import '../models/vital_signs.dart';
import '../utils/priority_calculator.dart';

class PatientProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  List<PatientModel> _patients = [];
  List<PatientModel> _queue = [];
  bool _loading = false;
  String? _errorMessage;

  List<PatientModel> get patients => _patients;
  List<PatientModel> get queue => _queue;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  int get totalPatients => _patients.length;

  int get averageWaitTime {
    if (_patients.isEmpty) return 0;
    final totalWaitTime = _patients.fold<int>(0, (sum, patient) {
      final registrationTime = patient.registrationTime;
      return sum + DateTime.now().difference(registrationTime).inMinutes;
    });
    return totalWaitTime ~/ _patients.length;
  }

  List<PatientModel> get criticalPatients =>
      _patients.where((patient) => patient.priority == 'critical').toList();
  List<PatientModel> get urgentPatients =>
      _patients.where((patient) => patient.priority == 'urgent').toList();
  List<PatientModel> get stablePatients =>
      _patients.where((patient) => patient.priority == 'stable').toList();
  List<PatientModel> get waitingPatients {
    return _patients.where((patient) => patient.room == null).toList();
  }

  // Fetch patients and calculate priority
  Future<void> fetchPatients() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('patients').get();
      _patients = snapshot.docs
          .map((doc) => PatientModel.fromMap(doc.data(), doc.id))
          .toList();

      // Update priority based on the symptoms and vitals
      _patients.forEach((patient) {
        final priority = PriorityCalculator.calculate(patient.symptomChecks, patient.vitals);
        patient.priority = priority;
      });

      // Sort patients based on the calculated priority
      _patients.sort((a, b) => PriorityCalculator.getColor(b.priority)
          .value
          .compareTo(PriorityCalculator.getColor(a.priority).value));

      // Update the queue with sorted list based on priority
      _queue = List.from(_patients);
    } catch (e) {
      _errorMessage = 'Error fetching patients: $e';
      debugPrint('Error fetching patients: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> assignRoom(String patientId, String roomId) async {
    final patientIndex = _patients.indexWhere((p) => p.id == patientId);
    if (patientIndex != -1) {
      _patients[patientIndex].room = roomId;
      await _firestore.collection('patients').doc(patientId).update({
        'room': roomId,
      });
      // Sort queue by priority after room assignment
      _queue.sort((a, b) => PriorityCalculator.getColor(b.priority)
          .value
          .compareTo(PriorityCalculator.getColor(a.priority).value));
      notifyListeners();
    }
  }

  Future<PatientModel?> registerPatient({
    required String name,
    required String gender,
    required int age,
    required String phone,
    required String address,
    required String emergencyLevel,
    required Map<String, bool> symptomChecks,  // Ensure this is a Map<String, bool>
    File? imageFile, required String symptoms, required VitalSigns vitals,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      String? photoUrl;

      // If there's an image, upload it
      if (imageFile != null) {
        final ref = _storage
            .ref()
            .child('patient_photos/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(imageFile);
        photoUrl = await ref.getDownloadURL();
      }

      final doc = _firestore.collection('patients').doc();
      final patient = PatientModel(
        id: doc.id,
        name: name,
        age: age,
        gender: gender,
        phone: phone,
        address: address,
        emergencyLevel: emergencyLevel,
        symptoms: symptoms, // Store symptoms as a string
        symptomChecks: symptomChecks,  // Pass Map<String, bool> here
        photoUrl: photoUrl,
        vitals: VitalSigns(spO2: null, pulse: null, temperature: null), // Initialize vitals
        reports: [],
        priority: 'stable', // Default priority
        createdAt: Timestamp.now().toDate(),
        registrationTime: Timestamp.now().toDate(),
        status: 'Pending', // Default status
      );

      await doc.set(patient.toMap());
      _patients.add(patient);
      _queue.add(patient);

      // Sort queue by priority
      _queue.sort((a, b) => PriorityCalculator.getColor(b.priority)
          .value
          .compareTo(PriorityCalculator.getColor(a.priority).value));

      _loading = false;
      notifyListeners();
      return patient;
    } catch (e) {
      _loading = false;
      notifyListeners();
      _errorMessage = 'Error registering patient: $e';
      debugPrint('Error registering patient: $e');
      return null;
    }
  }

  Future<List<String>?> uploadReport(File file, String patientId) async {
    try {
      final ref = _storage.ref().child(
          'patient_reports/$patientId/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await _firestore.collection('patients').doc(patientId).update({
        'reports': FieldValue.arrayUnion([url]),
      });

      final patientIndex = _patients.indexWhere((p) => p.id == patientId);
      if (patientIndex != -1) {
        final updatedPatient = _patients[patientIndex].copyWith(
          reports: [..._patients[patientIndex].reports, url],
        );
        _patients[patientIndex] = updatedPatient;
      }

      notifyListeners();
      return [url];
    } catch (e) {
      _errorMessage = 'Upload failed: $e';
      debugPrint('Upload failed: $e');
      return null;
    }
  }

  Future<void> updatePatient(String patientId, Map<String, dynamic> data) async {
    try {
      // Update the patient document in Firestore with the provided data
      await _firestore.collection('patients').doc(patientId).update(data);

      // Optionally, you can update the local _patients list here if needed
      final patientIndex = _patients.indexWhere((p) => p.id == patientId);
      if (patientIndex != -1) {
        _patients[patientIndex] = PatientModel.fromMap(data, patientId);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating patient: $e';
      debugPrint('Error updating patient: $e');
    }
  }

  void removeFromQueue(String patientId) {
    _queue.removeWhere((p) => p.id == patientId);
    notifyListeners();
  }

  Future<void> refreshQueue() async {
    await fetchPatients();
    _queue.sort((a, b) => PriorityCalculator.getColor(b.priority)
        .value
        .compareTo(PriorityCalculator.getColor(a.priority).value));  // Re-sort the queue based on updated priority
    notifyListeners();
  }
}
