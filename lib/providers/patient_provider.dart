import 'package:flutter/foundation.dart';
import '../models/patient_model.dart';
import '../models/triage_model.dart';
import '../services/firebase.service.dart';

class PatientProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  Patient? _currentPatient;
  Triage? _currentTriage;
  List<Map<String, dynamic>> _queueData = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Patient? get currentPatient => _currentPatient;
  Triage? get currentTriage => _currentTriage;
  List<Map<String, dynamic>> get queueData => _queueData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Register new patient
  Future<String?> registerPatient(Patient patient) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String patientId = await _firebaseService.addPatient(patient);
      _currentPatient = patient.copyWith(id: patientId);
      _isLoading = false;
      notifyListeners();
      return patientId;
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // Add triage record
  Future<bool> addTriageRecord(Triage triage) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String triageId = await _firebaseService.addTriage(triage);
      _currentTriage = triage.copyWith(id: triageId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // Fetch queue data
  Future<void> fetchQueueData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Using stream subscription
      _firebaseService.getQueueStream().listen((data) {
        _queueData = data.cast<Map<String, dynamic>>();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _handleError(e);
    }
  }

  // Clear current patient and triage
  void clearCurrentPatient() {
    _currentPatient = null;
    _currentTriage = null;
    notifyListeners();
  }

  // Handle errors and update state
  void _handleError(dynamic error) {
    _error = error.toString();
    _isLoading = false;
    notifyListeners();
    if (kDebugMode) {
      print("Error: $error");
    }
  }
}
