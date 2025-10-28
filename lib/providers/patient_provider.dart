import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';
import '../models/triage_model.dart';
import '../services/firebase.service.dart';

class PatientProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Patient> _patients = [];
  List<Triage> _triageRecords = [];
  bool _isLoading = false;
  String? _error;

  // ✅ Added current patient field and getter
  Patient? _currentPatient;
  Patient? get currentPatient => _currentPatient;

  void setCurrentPatient(Patient patient) {
    _currentPatient = patient;
    notifyListeners();
  }

  List<Patient> get patients => _patients;
  List<Triage> get triageRecords => _triageRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all patients from Firebase
  Future<void> fetchPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('patients').get();
      _patients = snapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _patients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a specific patient by ID
  Future<Patient?> getPatient(String patientId) async {
    try {
      // First check if patient is already in local list
      try {
        final existingPatient = _patients.firstWhere((p) => p.id == patientId);
        return existingPatient;
      } catch (e) {
        // Patient not found in local list, fetch from Firebase
      }

      // Fetch from Firebase
      final doc = await _firestore.collection('patients').doc(patientId).get();

      if (doc.exists) {
        return Patient.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Add a new patient to Firebase
  Future<String?> addPatient(Patient patient) async {
    try {
      final patientId = await _firebaseService.addPatient(patient);

      // Add to local list with the generated ID
      final newPatient = patient.copyWith(id: patientId);

      _patients.add(newPatient);
      notifyListeners();

      return patientId;
    } on FirebaseServiceException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Update an existing patient
  Future<bool> updatePatient(String patientId, Map<String, dynamic> updates) async {
    try {
      await _firebaseService.updatePatient(patientId, updates);

      // Update local list
      final index = _patients.indexWhere((p) => p.id == patientId);
      if (index != -1) {
        // Fetch updated patient data
        final updatedPatient = await getPatient(patientId);
        if (updatedPatient != null) {
          _patients[index] = updatedPatient;
        }
      }

      notifyListeners();
      return true;
    } on FirebaseServiceException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a patient
  Future<bool> deletePatient(String patientId) async {
    try {
      await _firestore.collection('patients').doc(patientId).delete();

      _patients.removeWhere((p) => p.id == patientId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Add a triage record for a patient
  Future<String?> addTriageRecord(Triage triage) async {
    try {
      final triageId = await _firebaseService.addTriage(triage);

      final newTriage = triage.copyWith(id: triageId);
      _triageRecords.add(newTriage);
      notifyListeners();

      return triageId;
    } on FirebaseServiceException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Fetch triage records for a specific patient
  Future<List<Triage>> getPatientTriageRecords(String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('triage')
          .where('patientId', isEqualTo: patientId)
          .orderBy('triageTime', descending: true)
          .get();

      return snapshot.docs.map((doc) => Triage.fromFirestore(doc)).toList();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Fetch all triage records
  Future<void> fetchAllTriageRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('triage')
          .orderBy('triageTime', descending: true)
          .get();

      _triageRecords = snapshot.docs.map((doc) => Triage.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _triageRecords = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Updated vitals method to use correct FirebaseService function
  Future<bool> updateVitals(String patientId, Map<String, dynamic> vitals) async {
    try {
      await _firebaseService.updatePatientVitals(patientId, vitals);

      final index = _patients.indexWhere((p) => p.id == patientId);
      if (index != -1) {
        final updatedPatient = await getPatient(patientId);
        if (updatedPatient != null) {
          _patients[index] = updatedPatient;
        }
      }

      notifyListeners();
      return true;
    } on FirebaseServiceException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<Patient> getPatientsByPriority(String priority) {
    return _patients.where((p) => p.priority == priority).toList();
  }

  List<Patient> getPatientsByStatus(String status) {
    return _patients.where((p) => p.status == status).toList();
  }

  List<Patient> searchPatients(String query) {
    if (query.isEmpty) return _patients;

    final lowerQuery = query.toLowerCase();
    return _patients
        .where((p) =>
    p.name.toLowerCase().contains(lowerQuery) ||
        p.contact.contains(query))
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([
      fetchPatients(),
      fetchAllTriageRecords(),
    ]);
  }
}
