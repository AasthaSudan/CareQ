// lib/providers/stats_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/firebase.service.dart';
import '../models/patient_model.dart';
import '../models/triage_model.dart';
import '../models/room_model.dart';

/// Provider for managing hospital statistics and analytics
class StatsProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // Stream subscriptions
  StreamSubscription<List<Patient>>? _patientsSubscription;
  StreamSubscription<List<Triage>>? _triageSubscription;
  StreamSubscription<List<Room>>? _roomsSubscription;

  // Raw data
  List<Patient> _patients = [];
  List<Triage> _triageRecords = [];
  List<Room> _rooms = [];

  // State
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;

  // Getters for state
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  // ==================== PATIENT STATISTICS ====================

  int get totalPatients => _patients.length;

  int get waitingPatients =>
      _patients.where((p) => p.status == 'waiting').length;

  int get inTreatmentPatients =>
      _patients.where((p) => p.status == 'in-treatment').length;

  int get dischargedPatients =>
      _patients.where((p) => p.status == 'discharged').length;

  int get criticalPatients =>
      _patients.where((p) => p.priority == 'red').length;

  int get urgentPatients =>
      _patients.where((p) => p.priority == 'yellow').length;

  int get nonUrgentPatients =>
      _patients.where((p) => p.priority == 'green').length;

  // Patient breakdown by priority
  Map<String, int> get patientsByPriority => {
    'red': criticalPatients,
    'yellow': urgentPatients,
    'green': nonUrgentPatients,
  };

  // Patient breakdown by status
  Map<String, int> get patientsByStatus => {
    'waiting': waitingPatients,
    'in-treatment': inTreatmentPatients,
    'discharged': dischargedPatients,
  };

  // Average wait time
  Duration get averageWaitTime {
    if (_patients.isEmpty) return Duration.zero;

    final waitingPts = _patients.where((p) => p.status == 'waiting');
    if (waitingPts.isEmpty) return Duration.zero;

    final totalMinutes = waitingPts
        .map((p) => p.getWaitTime().inMinutes)
        .reduce((a, b) => a + b);

    return Duration(minutes: (totalMinutes / waitingPts.length).round());
  }

  String get averageWaitTimeString {
    final duration = averageWaitTime;
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }

  // Longest wait time
  Duration get longestWaitTime {
    if (_patients.isEmpty) return Duration.zero;

    final waitingPts = _patients.where((p) => p.status == 'waiting');
    if (waitingPts.isEmpty) return Duration.zero;

    return waitingPts
        .map((p) => p.getWaitTime())
        .reduce((a, b) => a > b ? a : b);
  }

  // Patients with doctor assigned
  int get patientsWithDoctor =>
      _patients.where((p) => p.hasDoctor).length;

  // Patients with room assigned
  int get patientsWithRoom =>
      _patients.where((p) => p.hasRoom).length;

  // Patients with AI analysis
  int get patientsWithAIAnalysis =>
      _patients.where((p) => p.hasAIAnalysis).length;

  // ==================== TRIAGE STATISTICS ====================

  int get totalTriageRecords => _triageRecords.length;

  int get criticalTriage =>
      _triageRecords.where((t) => t.priority == 'red').length;

  int get urgentTriage =>
      _triageRecords.where((t) => t.priority == 'yellow').length;

  int get stableTriage =>
      _triageRecords.where((t) => t.priority == 'green').length;

  // Triage breakdown by priority
  Map<String, int> get triageByPriority => {
    'red': criticalTriage,
    'yellow': urgentTriage,
    'green': stableTriage,
  };

  // Triage with AI analysis
  int get triageWithAI =>
      _triageRecords.where((t) => t.hasAIAnalysis).length;

  // Average AI confidence
  double get averageAIConfidence {
    final triageWithAI = _triageRecords.where((t) => t.aiConfidence != null);
    if (triageWithAI.isEmpty) return 0;

    final total = triageWithAI
        .map((t) => t.aiConfidence!)
        .reduce((a, b) => a + b);

    return total / triageWithAI.length;
  }

  // Average risk score
  double get averageRiskScore {
    final triageWithRisk = _triageRecords.where((t) => t.riskScore != null);
    if (triageWithRisk.isEmpty) return 0;

    final total = triageWithRisk
        .map((t) => t.riskScore!)
        .reduce((a, b) => a + b);

    return total / triageWithRisk.length;
  }

  // ==================== ROOM STATISTICS ====================

  int get totalRooms => _rooms.length;

  int get availableRooms =>
      _rooms.where((r) => r.isAvailable).length;

  int get occupiedRooms =>
      _rooms.where((r) => r.isOccupied).length;

  int get maintenanceRooms =>
      _rooms.where((r) => r.isUnderMaintenance).length;

  int get cleaningRooms =>
      _rooms.where((r) => r.isBeingCleaned).length;

  int get roomsNeedingCleaning =>
      _rooms.where((r) => r.needsCleaning).length;

  // Room breakdown by status
  Map<String, int> get roomsByStatus => {
    'available': availableRooms,
    'occupied': occupiedRooms,
    'maintenance': maintenanceRooms,
    'cleaning': cleaningRooms,
  };

  // Occupancy rate
  double get occupancyRate {
    if (totalRooms == 0) return 0;
    return (occupiedRooms / totalRooms) * 100;
  }

  // Total bed capacity
  int get totalBedCapacity =>
      _rooms.fold(0, (sum, room) => sum + room.capacity);

  // Total occupied beds
  int get totalOccupiedBeds =>
      _rooms.fold(0, (sum, room) => sum + room.currentOccupancy);

  // Bed occupancy rate
  double get bedOccupancyRate {
    if (totalBedCapacity == 0) return 0;
    return (totalOccupiedBeds / totalBedCapacity) * 100;
  }

  // Room breakdown by type
  Map<String, int> get roomsByType {
    final Map<String, int> typeCount = {};
    for (var room in _rooms) {
      typeCount[room.roomType] = (typeCount[room.roomType] ?? 0) + 1;
    }
    return typeCount;
  }

  // ICU rooms
  int get icuRooms =>
      _rooms.where((r) => r.isCriticalCare).length;

  int get availableIcuRooms =>
      _rooms.where((r) => r.isCriticalCare && r.isAvailable).length;

  // ==================== PERFORMANCE METRICS ====================

  // Patient throughput (discharged today)
  int get patientsThroughputToday {
    final today = DateTime.now();
    return _patients.where((p) {
      if (p.status != 'discharged') return false;
      // You might want to track discharge date separately
      return true; // Placeholder
    }).length;
  }

  // Average treatment duration (for discharged patients)
  Duration get averageTreatmentDuration {
    final treated = _patients.where((p) =>
    p.status == 'discharged');

    if (treated.isEmpty) return Duration.zero;

    // This is a simplified calculation
    // In reality, you'd want to track actual discharge time
    final totalHours = treated.length * 4; // Assuming 4 hours average
    return Duration(hours: (totalHours / treated.length).round());
  }

  // Critical patients needing immediate attention
  List<Patient> get criticalPatientsWaiting {
    return _patients
        .where((p) => p.priority == 'red' && p.status == 'waiting')
        .toList();
  }

  int get criticalPatientsWaitingCount => criticalPatientsWaiting.length;

  // Patients waiting over threshold (e.g., 2 hours)
  List<Patient> get patientsWaitingTooLong {
    return _patients.where((p) {
      if (p.status != 'waiting') return false;
      return p.getWaitTime().inHours >= 2;
    }).toList();
  }

  int get patientsWaitingTooLongCount => patientsWaitingTooLong.length;

  // ==================== ALERTS & NOTIFICATIONS ====================

  // Get all active alerts
  List<String> get activeAlerts {
    List<String> alerts = [];

    if (criticalPatientsWaitingCount > 0) {
      alerts.add('$criticalPatientsWaitingCount critical patient(s) waiting');
    }

    if (patientsWaitingTooLongCount > 0) {
      alerts.add('$patientsWaitingTooLongCount patient(s) waiting over 2 hours');
    }

    if (availableRooms == 0) {
      alerts.add('No rooms available');
    }

    if (roomsNeedingCleaning > 5) {
      alerts.add('$roomsNeedingCleaning rooms need cleaning');
    }

    if (occupancyRate > 90) {
      alerts.add('High occupancy rate: ${occupancyRate.toStringAsFixed(1)}%');
    }

    return alerts;
  }

  bool get hasAlerts => activeAlerts.isNotEmpty;

  int get alertCount => activeAlerts.length;

  // ==================== COMPREHENSIVE STATISTICS MAP ====================

  Map<String, dynamic> get comprehensiveStats => {
    // Patient stats
    'totalPatients': totalPatients,
    'waitingPatients': waitingPatients,
    'inTreatmentPatients': inTreatmentPatients,
    'dischargedPatients': dischargedPatients,
    'criticalPatients': criticalPatients,
    'urgentPatients': urgentPatients,
    'nonUrgentPatients': nonUrgentPatients,
    'averageWaitTime': averageWaitTimeString,
    'patientsWithDoctor': patientsWithDoctor,
    'patientsWithRoom': patientsWithRoom,

    // Triage stats
    'totalTriageRecords': totalTriageRecords,
    'triageWithAI': triageWithAI,
    'averageAIConfidence': averageAIConfidence.toStringAsFixed(1),
    'averageRiskScore': averageRiskScore.toStringAsFixed(1),

    // Room stats
    'totalRooms': totalRooms,
    'availableRooms': availableRooms,
    'occupiedRooms': occupiedRooms,
    'occupancyRate': occupancyRate.toStringAsFixed(1),
    'totalBedCapacity': totalBedCapacity,
    'totalOccupiedBeds': totalOccupiedBeds,
    'bedOccupancyRate': bedOccupancyRate.toStringAsFixed(1),
    'icuRooms': icuRooms,
    'availableIcuRooms': availableIcuRooms,

    // Alerts
    'alertCount': alertCount,
    'criticalPatientsWaiting': criticalPatientsWaitingCount,
    'patientsWaitingTooLong': patientsWaitingTooLongCount,
  };

  // Legacy method for backward compatibility
  Map<String, int> get statistics => {
    'totalPatients': totalPatients,
    'waitingPatients': waitingPatients,
    'inTreatmentPatients': inTreatmentPatients,
    'dischargedPatients': dischargedPatients,
    'criticalPatients': criticalPatients,
    'totalRooms': totalRooms,
    'availableRooms': availableRooms,
    'occupiedRooms': occupiedRooms,
  };

  // ==================== INITIALIZATION & DATA FETCHING ====================

  /// Initialize statistics with real-time updates
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();

      // Listen to patients stream
      _patientsSubscription = _firebaseService.getPatientsStream().listen(
            (patients) {
          _patients = patients;
          _updateTimestamp();
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to fetch patients: ${error.toString()}');
        },
      );

      // Listen to triage stream
      _triageSubscription = _firebaseService.getQueueStream().listen(
            (triageRecords) {
          _triageRecords = triageRecords;
          _updateTimestamp();
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to fetch triage: ${error.toString()}');
        },
      );

      // Listen to rooms stream
      _roomsSubscription = _firebaseService.getRoomsStream().listen(
            (rooms) {
          _rooms = rooms;
          _updateTimestamp();
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to fetch rooms: ${error.toString()}');
        },
      );

      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize statistics: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Fetch statistics (one-time fetch without streams)
  Future<void> fetchStatistics() async {
    try {
      _setLoading(true);
      _clearError();

      // Fetch patients
      final patientsSnapshot = await _firebaseService.getPatientsStream().first;
      _patients = patientsSnapshot;

      // Fetch triage
      final triageSnapshot = await _firebaseService.getQueueStream().first;
      _triageRecords = triageSnapshot;

      // Fetch rooms
      final roomsSnapshot = await _firebaseService.getRoomsStream().first;
      _rooms = roomsSnapshot;

      _updateTimestamp();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to fetch statistics: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Refresh statistics
  Future<void> refresh() async {
    await fetchStatistics();
  }

  // ==================== TIME-BASED ANALYTICS ====================

  /// Get patients admitted today
  List<Patient> get patientsAdmittedToday {
    final today = DateTime.now();
    return _patients.where((p) {
      return p.checkInTime.year == today.year &&
          p.checkInTime.month == today.month &&
          p.checkInTime.day == today.day;
    }).toList();
  }

  int get patientsAdmittedTodayCount => patientsAdmittedToday.length;

  /// Get patients by hour of day (for peak time analysis)
  Map<int, int> getPatientsAdmittedByHour() {
    Map<int, int> hourlyCount = {};
    for (int i = 0; i < 24; i++) {
      hourlyCount[i] = 0;
    }

    for (var patient in patientsAdmittedToday) {
      hourlyCount[patient.checkInTime.hour] =
          (hourlyCount[patient.checkInTime.hour] ?? 0) + 1;
        }

    return hourlyCount;
  }

  // ==================== EXPORT & REPORTING ====================

  /// Generate summary report
  Map<String, dynamic> generateSummaryReport() {
    return {
      'generatedAt': DateTime.now().toIso8601String(),
      'patients': patientsByStatus,
      'patientsByPriority': patientsByPriority,
      'triage': triageByPriority,
      'rooms': roomsByStatus,
      'occupancyRate': occupancyRate,
      'averageWaitTime': averageWaitTimeString,
      'alerts': activeAlerts,
      'patientsAdmittedToday': patientsAdmittedTodayCount,
    };
  }

  // ==================== HELPER METHODS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _updateTimestamp() {
    _lastUpdated = DateTime.now();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Get formatted last updated string
  String get lastUpdatedString {
    if (_lastUpdated == null) return 'Never';

    final now = DateTime.now();
    final diff = now.difference(_lastUpdated!);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _patientsSubscription?.cancel();
    _triageSubscription?.cancel();
    _roomsSubscription?.cancel();
    super.dispose();
  }
}