// lib/providers/patient_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/patient_model.dart';
import 'package:path/path.dart' as p;

class PatientProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Local cache of patients (small)
  final List<PatientModel> _patients = [];
  final List<PatientModel> _queue = [];
  bool _loading = false;

  bool get loading => _loading;
  List<PatientModel> get patients => List.unmodifiable(_patients);
  List<PatientModel> get queue => List.unmodifiable(_queue);

  PatientProvider() {
    // Optionally fetch initial data
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    _loading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('patients').orderBy('name').get();
      _patients.clear();
      for (final doc in snapshot.docs) {
        _patients.add(PatientModel.fromMap(doc.data(), doc.id));
      }
      // Build queue as all patients for demo; adapt logic as needed
      _queue
        ..clear()
        ..addAll(_patients);
    } catch (e) {
      debugPrint('fetchPatients error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<PatientModel?> registerPatient({
    required String name,
    required String gender,
    int? age,
    String? phone,
    String? address,
    String? symptoms,
    String? emergencyLevel,
  }) async {
    final data = {
      'name': name,
      'gender': gender,
      'age': age,
      'phone': phone,
      'address': address,
      'symptoms': symptoms,
      'emergencyLevel': emergencyLevel,
      'createdAt': FieldValue.serverTimestamp(),
    };
    try {
      final docRef = await _firestore.collection('patients').add(data);
      final doc = await docRef.get();
      final pModel = PatientModel.fromMap(doc.data()!, doc.id);
      _patients.add(pModel);
      _queue.add(pModel);
      notifyListeners();
      return pModel;
    } catch (e) {
      debugPrint('registerPatient error: $e');
      return null;
    }
  }

  Future<bool> addVitals(String patientId, Map<String, dynamic> vitals) async {
    try {
      await _firestore.collection('patients').doc(patientId).update({'vitals': vitals});
      // update local caches
      final idx = _patients.indexWhere((p) => p.id == patientId);
      if (idx >= 0) {
        final map = _patients[idx].toMap();
        map['vitals'] = vitals;
        _patients[idx] = PatientModel.fromMap(map, patientId);
      }
      final qIdx = _queue.indexWhere((p) => p.id == patientId);
      if (qIdx >= 0) {
        final map = _queue[qIdx].toMap();
        map['vitals'] = vitals;
        _queue[qIdx] = PatientModel.fromMap(map, patientId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('addVitals error: $e');
      return false;
    }
  }

  Future<List<String>?> uploadReport(File file, String patientId) async {
    try {
      final filename = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
      final ref = _storage.ref().child('reports/$patientId/$filename');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();

      await _firestore.collection('patients').doc(patientId).update({
        'reports': FieldValue.arrayUnion([url]),
      });

      // update local copy
      await fetchPatients();
      return [url];
    } catch (e) {
      debugPrint('uploadReport error: $e');
      return null;
    }
  }

  Future<void> refreshQueue() async {
    await fetchPatients();
  }

  Future<void> removeFromQueue(String patientId) async {
    _queue.removeWhere((p) => p.id == patientId);
    notifyListeners();
  }
}
