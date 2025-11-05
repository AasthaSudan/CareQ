import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<RoomModel> _rooms = [];
  bool isLoading = false;

  List<RoomModel> get rooms => _rooms;

  int get availableRooms =>
      _rooms.where((r) => r.status.toLowerCase() == 'available').length;

  int get occupiedRooms =>
      _rooms.where((r) => r.status.toLowerCase() == 'occupied').length;

  int get cleaningRooms =>
      _rooms.where((r) => r.status.toLowerCase() == 'cleaning').length;

  RoomProvider();

  Future<void> init() async {
    await _initializeRooms();
  }

  Future<void> _initializeRooms() async {
    isLoading = true;
    notifyListeners();

    try {
      final roomsSnapshot = await _firestore.collection('rooms').get();
      if (roomsSnapshot.docs.isEmpty) {
        // Create initial rooms if none exist
        for (int floor = 1; floor <= 2; floor++) {
          for (int room = 1; room <= 4; room++) {
            final roomNumber = '${floor}0$room';
            await _firestore.collection('rooms').doc(roomNumber).set({
              'id': roomNumber,
              'number': roomNumber,
              'floor': 'Floor $floor',
              'status': 'Available',
              'patientId': null,
              'patientName': null,
              'assignedTime': null,
              'type': 'General',
            });
          }
        }
      }
      await fetchRooms();
      _listenToRooms();
    } catch (e) {
      print('Error initializing rooms: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRooms() async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('rooms').get();
      _rooms = snapshot.docs
          .map((doc) => RoomModel.fromJson(doc.data()))
          .toList()
        ..sort((a, b) => a.number.compareTo(b.number));
    } catch (e) {
      print('Error fetching rooms: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _listenToRooms() {
    _firestore.collection('rooms').snapshots().listen((snapshot) {
      _rooms = snapshot.docs
          .map((doc) => RoomModel.fromJson(doc.data()))
          .toList()
        ..sort((a, b) => a.number.compareTo(b.number));
      isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error listening to rooms: $error');
    });
  }

  // Assign a room to a patient
  Future<void> assignRoom(String roomId, String patientId, String patientName) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'status': 'Occupied',
        'patientId': patientId,
        'patientName': patientName,
        'assignedTime': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error assigning room: $e');
      rethrow;
    }
  }

  // Discharge a patient and mark room as 'cleaning'
  Future<void> dischargePatient(String roomId) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'status': 'Cleaning',
        'patientId': null,
        'patientName': null,
      });
    } catch (e) {
      print('Error discharging patient: $e');
      rethrow;
    }
  }

  // Mark a room as available
  Future<void> markRoomAvailable(String roomId) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'status': 'Available',
        'assignedTime': null,
      });
    } catch (e) {
      print('Error marking room available: $e');
      rethrow;
    }
  }

  List<RoomModel> getAvailableRooms() {
    return _rooms.where((r) => r.status == 'Available').toList();
  }

  RoomModel? getRoomById(String id) {
    try {
      return _rooms.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add a new room to Firestore
  Future<void> addRoom(RoomModel room) async {
    try {
      final roomId = room.id.isEmpty ? room.number : room.id;
      final newRoom = RoomModel(
        id: roomId,
        number: room.number,
        floor: room.floor,
        status: room.status,
        patientId: room.patientId,
        patientName: room.patientName,
        assignedTime: room.assignedTime,
        type: room.type,
      );

      await _firestore.collection('rooms').doc(roomId).set(newRoom.toJson());
    } catch (e) {
      print('Error adding room: $e');
      rethrow;
    }
  }

  Future<void> assignPatientToRoom(String roomId, String patientId, String patientName) async {
    await assignRoom(roomId, patientId, patientName);
  }
}