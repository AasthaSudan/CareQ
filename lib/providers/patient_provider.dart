import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/patient_model.dart';

class PatientProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  List<PatientModel> _patients = [];
  List<PatientModel> _queue = [];
  bool _loading = false;

  List<PatientModel> get patients => _patients;
  List<PatientModel> get queue => _queue;
  bool get loading => _loading;

  /// Fetch all patients from Firestore
  Future<void> fetchPatients() async {
    _loading = true;
    notifyListeners();

    final snapshot = await _firestore.collection('patients').get();
    _patients = snapshot.docs
        .map((doc) => PatientModel.fromMap(doc.data(), doc.id))
        .toList();

    _loading = false;
    notifyListeners();
  }

  /// Register a new patient and store in Firestore
  Future<PatientModel?> registerPatient({
    required String name,
    required String gender,
    required int age,
    required String phone,
    required String address,
    required String emergencyLevel,
    required String symptoms,
    File? imageFile,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      String? photoUrl;

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
        symptoms: symptoms,
        photoUrl: photoUrl,
        vitals: {},
        reports: [],
        createdAt: Timestamp.now(),
      );

      await doc.set(patient.toMap());
      _patients.add(patient);
      _queue.add(patient);

      _loading = false;
      notifyListeners();
      return patient;
    } catch (e) {
      debugPrint('Error registering patient: $e');
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  /// Upload a report file and link it to the patient
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
      debugPrint('Upload failed: $e');
      return null;
    }
  }

  /// Remove a patient from the queue
  void removeFromQueue(String patientId) {
    _queue.removeWhere((p) => p.id == patientId);
    notifyListeners();
  }

  /// Refresh queue list
  Future<void> refreshQueue() async {
    await fetchPatients();
    _queue = List.from(_patients);
    notifyListeners();
  }
}
