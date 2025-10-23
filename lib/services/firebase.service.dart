import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.model.dart';
import '../models/triage.model.dart';
import '../models/room_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== PATIENT OPERATIONS ====================

  // Add new patient
  Future<String> addPatient(Patient patient) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('patients')
          .add(patient.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding patient: $e');
      rethrow;
    }
  }

  // Update patient
  Future<void> updatePatient(String patientId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('patients').doc(patientId).update(data);
    } catch (e) {
      print('Error updating patient: $e');
      rethrow;
    }
  }

  // Get patient by ID
  Future<Patient?> getPatient(String patientId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('patients')
          .doc(patientId)
          .get();

      if (doc.exists) {
        return Patient.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting patient: $e');
      return null;
    }
  }

  // Get all patients stream
  Stream<List<Patient>> getPatientsStream() {
    return _firestore
        .collection('patients')
        .orderBy('checkInTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Patient.fromFirestore(doc))
        .toList());
  }

  // ==================== TRIAGE OPERATIONS ====================

  // Add triage record
  Future<String> addTriage(Triage triage) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('triage')
          .add(triage.toFirestore());

      // Update patient with priority
      await updatePatient(triage.patientId, {'priority': triage.priority});

      return docRef.id;
    } catch (e) {
      print('Error adding triage: $e');
      rethrow;
    }
  }

  // Get triage by patient ID
  Future<Triage?> getTriageByPatient(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('triage')
          .where('patientId', isEqualTo: patientId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Triage.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting triage: $e');
      return null;
    }
  }

  // Get queue stream (waiting patients with triage data)
  Stream<List<Map<String, dynamic>>> getQueueStream() {
    return _firestore
        .collection('patients')
        .where('status', isEqualTo: 'waiting')
        .snapshots()
        .asyncMap((patientSnapshot) async {
      List<Map<String, dynamic>> queueData = [];

      for (var patientDoc in patientSnapshot.docs) {
        Patient patient = Patient.fromFirestore(patientDoc);

        // Get triage data for this patient
        Triage? triage = await getTriageByPatient(patient.id);

        if (triage != null) {
          queueData.add({
            'patient': patient,
            'triage': triage,
          });
        }
      }

      // Sort by priority (red > yellow > green), then by check-in time
      queueData.sort((a, b) {
        int priorityOrder(String priority) {
          switch (priority) {
            case 'red':
              return 0;
            case 'yellow':
              return 1;
            case 'green':
              return 2;
            default:
              return 3;
          }
        }

        Triage triageA = a['triage'] as Triage;
        Triage triageB = b['triage'] as Triage;

        int priorityCompare = priorityOrder(triageA.priority)
            .compareTo(priorityOrder(triageB.priority));

        if (priorityCompare != 0) return priorityCompare;

        // If same priority, sort by check-in time
        Patient patientA = a['patient'] as Patient;
        Patient patientB = b['patient'] as Patient;
        return patientA.checkInTime.compareTo(patientB.checkInTime);
      });

      return queueData;
    });
  }

  // ==================== ROOM OPERATIONS ====================

  // Add new room
  Future<String> addRoom(Room room) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('rooms')
          .add(room.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding room: $e');
      rethrow;
    }
  }

  // Update room
  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update(data);
    } catch (e) {
      print('Error updating room: $e');
      rethrow;
    }
  }

  // Get all rooms stream
  Stream<List<Room>> getRoomsStream() {
    return _firestore
        .collection('rooms')
        .orderBy('roomNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Room.fromFirestore(doc))
        .toList());
  }

  // Assign patient to room
  Future<void> assignRoom(String patientId, String patientName, String roomId) async {
    try {
      // Update room
      await updateRoom(roomId, {
        'status': 'occupied',
        'assignedPatientId': patientId,
        'assignedPatientName': patientName,
        'assignedTime': FieldValue.serverTimestamp(),
      });

      // Update patient
      await updatePatient(patientId, {
        'status': 'in-treatment',
        'assignedRoom': roomId,
      });
    } catch (e) {
      print('Error assigning room: $e');
      rethrow;
    }
  }

  // Discharge patient from room
  Future<void> dischargePatient(String patientId, String roomId) async {
    try {
      // Update patient
      await updatePatient(patientId, {
        'status': 'discharged',
      });

      // Clear room
      await updateRoom(roomId, {
        'status': 'available',
        'assignedPatientId': null,
        'assignedPatientName': null,
        'assignedTime': null,
      });
    } catch (e) {
      print('Error discharging patient: $e');
      rethrow;
    }
  }

  // ==================== STATISTICS ====================

  // Get statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      // Get all patients
      QuerySnapshot patientsSnapshot = await _firestore
          .collection('patients')
          .get();

      int total = patientsSnapshot.docs.length;
      int waiting = 0;
      int inTreatment = 0;
      int discharged = 0;

      for (var doc in patientsSnapshot.docs) {
        String status = doc.get('status') ?? 'waiting';
        if (status == 'waiting') waiting++;
        if (status == 'in-treatment') inTreatment++;
        if (status == 'discharged') discharged++;
      }

      // Get triage counts
      QuerySnapshot triageSnapshot = await _firestore
          .collection('triage')
          .get();

      int critical = 0;
      int urgent = 0;
      int nonUrgent = 0;

      for (var doc in triageSnapshot.docs) {
        String priority = doc.get('priority') ?? 'green';
        if (priority == 'red') critical++;
        if (priority == 'yellow') urgent++;
        if (priority == 'green') nonUrgent++;
      }

      // Get room counts
      QuerySnapshot roomsSnapshot = await _firestore
          .collection('rooms')
          .get();

      int totalRooms = roomsSnapshot.docs.length;
      int occupiedRooms = roomsSnapshot.docs
          .where((doc) => doc.get('status') == 'occupied')
          .length;

      return {
        'totalPatients': total,
        'waiting': waiting,
        'inTreatment': inTreatment,
        'discharged': discharged,
        'critical': critical,
        'urgent': urgent,
        'nonUrgent': nonUrgent,
        'totalRooms': totalRooms,
        'occupiedRooms': occupiedRooms,
        'availableRooms': totalRooms - occupiedRooms,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  // ==================== UTILITIES ====================

  // Initialize demo rooms
  Future<void> initializeRooms() async {
    try {
      QuerySnapshot existing = await _firestore.collection('rooms').get();
      if (existing.docs.isNotEmpty) {
        print('Rooms already initialized');
        return;
      }

      List<Map<String, dynamic>> rooms = [
        {
          'roomName': 'Emergency Room 1',
          'roomNumber': 'ER-01',
          'status': 'available',
          'specialty': 'general',
        },
        {
          'roomName': 'Emergency Room 2',
          'roomNumber': 'ER-02',
          'status': 'available',
          'specialty': 'general',
        },
        {
          'roomName': 'Cardiac Unit 1',
          'roomNumber': 'CU-01',
          'status': 'available',
          'specialty': 'cardiac',
        },
        {
          'roomName': 'Trauma Room 1',
          'roomNumber': 'TR-01',
          'status': 'available',
          'specialty': 'trauma',
        },
        {
          'roomName': 'Observation Room 1',
          'roomNumber': 'OB-01',
          'status': 'available',
          'specialty': 'observation',
        },
        {
          'roomName': 'Observation Room 2',
          'roomNumber': 'OB-02',
          'status': 'available',
          'specialty': 'observation',
        },
        {
          'roomName': 'Pediatric Room 1',
          'roomNumber': 'PD-01',
          'status': 'available',
          'specialty': 'pediatric',
        },
        {
          'roomName': 'Pediatric Room 2',
          'roomNumber': 'PD-02',
          'status': 'available',
          'specialty': 'pediatric',
        },
      ];

      for (var room in rooms) {
        await _firestore.collection('rooms').add(room);
      }

      print('Rooms initialized successfully');
    } catch (e) {
      print('Error initializing rooms: $e');
    }
  }
}