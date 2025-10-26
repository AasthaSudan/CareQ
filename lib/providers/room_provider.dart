// lib/providers/room_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/room_model.dart';
import '../services/firebase.service.dart';

/// Provider for managing room state and operations
class RoomProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Room> _rooms = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Room>>? _roomsSubscription;

  // Getters
  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  int get totalRooms => _rooms.length;
  int get availableRoomsCount => _rooms.where((r) => r.isAvailable).length;
  int get occupiedRoomsCount => _rooms.where((r) => r.isOccupied).length;
  int get maintenanceRoomsCount => _rooms.where((r) => r.isUnderMaintenance).length;
  int get cleaningRoomsCount => _rooms.where((r) => r.isBeingCleaned).length;

  double get occupancyRate {
    if (totalRooms == 0) return 0;
    return (occupiedRoomsCount / totalRooms) * 100;
  }

  // Get rooms by type
  List<Room> getRoomsByType(String roomType) {
    return _rooms.where((r) => r.roomType == roomType).toList();
  }

  // Get available rooms
  List<Room> get availableRooms => _rooms.where((r) => r.isAvailable).toList();

  // Get occupied rooms
  List<Room> get occupiedRooms => _rooms.where((r) => r.isOccupied).toList();

  // Get rooms needing cleaning
  List<Room> get roomsNeedingCleaning => _rooms.where((r) => r.needsCleaning).toList();

  // Get room by ID
  Room? getRoomById(String roomId) {
    try {
      return _rooms.firstWhere((r) => r.id == roomId);
    } catch (e) {
      return null;
    }
  }

  // Get room by number
  Room? getRoomByNumber(String roomNumber) {
    try {
      return _rooms.firstWhere((r) => r.roomNumber == roomNumber);
    } catch (e) {
      return null;
    }
  }

  // ==================== CRUD OPERATIONS ====================

  /// Initialize and start listening to room updates
  Future<void> initialize() async {
    await fetchRooms();
  }

  /// Fetch rooms and listen to real-time updates
  Future<void> fetchRooms() async {
    try {
      _setLoading(true);
      _clearError();

      // Cancel existing subscription if any
      await _roomsSubscription?.cancel();

      // Listen to room stream
      _roomsSubscription = _firebaseService.getRoomsStream().listen(
            (rooms) {
          _rooms = rooms;
          _setLoading(false);
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to fetch rooms: ${error.toString()}');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Error initializing room stream: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// Add a new room
  Future<bool> addRoom(Room room) async {
    try {
      _setLoading(true);
      _clearError();

      final roomId = await _firebaseService.addRoom(room);

      _setLoading(false);
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to add room: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Update room information
  Future<bool> updateRoom(String roomId, Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _clearError();

      await _firebaseService.updateRoom(roomId, data);

      _setLoading(false);
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to update room: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Delete a room
  Future<bool> deleteRoom(String roomId) async {
    try {
      _setLoading(true);
      _clearError();

      // Check if room is occupied before deleting
      final room = getRoomById(roomId);
      if (room != null && room.isOccupied) {
        _setError('Cannot delete occupied room');
        _setLoading(false);
        return false;
      }

      await _firebaseService.deleteRoom(roomId);

      _setLoading(false);
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to delete room: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ==================== ROOM ASSIGNMENT ====================

  /// Assign patient to a room
  Future<bool> assignRoom({
    required String roomId,
    required String patientId,
    required String patientName,
    String? assignedDoctor,
    DateTime? expectedDischargeDate,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate room availability
      final room = getRoomById(roomId);
      if (room == null) {
        _setError('Room not found');
        _setLoading(false);
        return false;
      }

      if (!room.canAcceptPatient()) {
        final errors = room.getValidationErrors();
        _setError('Cannot assign room: ${errors.join(", ")}');
        _setLoading(false);
        return false;
      }

      // Update room with patient information
      final updateData = {
        'patientId': patientId,
        'patientName': patientName,
        'assignedDoctor': assignedDoctor,
        'isAvailable': false,
        'status': 'occupied',
        'currentOccupancy': room.currentOccupancy + 1,
        'assignedDate': FieldValue.serverTimestamp(),
        'expectedDischargeDate': expectedDischargeDate,
      };

      await _firebaseService.updateRoom(roomId, updateData);

      // Also update patient record with room assignment
      await _firebaseService.updatePatient(patientId, {
        'assignedRoom': room.roomNumber,
        'status': 'in-treatment',
      });

      _setLoading(false);
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to assign room: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Discharge patient from room
  Future<bool> dischargePatient({
    required String roomId,
    required String patientId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final room = getRoomById(roomId);
      if (room == null) {
        _setError('Room not found');
        _setLoading(false);
        return false;
      }

      // Calculate new occupancy
      final newOccupancy = (room.currentOccupancy - 1).clamp(0, room.capacity);

      // Update room - mark as needing cleaning
      final updateData = {
        'patientId': null,
        'patientName': null,
        'assignedDoctor': null,
        'isAvailable': newOccupancy == 0,
        'status': 'cleaning', // Mark for cleaning after discharge
        'currentOccupancy': newOccupancy,
        'assignedDate': null,
        'expectedDischargeDate': null,
      };

      await _firebaseService.updateRoom(roomId, updateData);

      // Update patient status
      await _firebaseService.updatePatient(patientId, {
        'assignedRoom': '',
        'status': 'discharged',
      });

      _setLoading(false);
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to discharge patient: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Transfer patient to another room
  Future<bool> transferPatient({
    required String fromRoomId,
    required String toRoomId,
    required String patientId,
    required String patientName,
    String? assignedDoctor,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Validate target room
      final toRoom = getRoomById(toRoomId);
      if (toRoom == null) {
        _setError('Target room not found');
        _setLoading(false);
        return false;
      }

      if (!toRoom.canAcceptPatient()) {
        final errors = toRoom.getValidationErrors();
        _setError('Cannot transfer to room: ${errors.join(", ")}');
        _setLoading(false);
        return false;
      }

      // Discharge from current room
      final dischargeSuccess = await dischargePatient(
        roomId: fromRoomId,
        patientId: patientId,
      );

      if (!dischargeSuccess) {
        return false;
      }

      // Assign to new room
      final assignSuccess = await assignRoom(
        roomId: toRoomId,
        patientId: patientId,
        patientName: patientName,
        assignedDoctor: assignedDoctor,
      );

      _setLoading(false);
      return assignSuccess;
    } catch (e) {
      _setError('Failed to transfer patient: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ==================== ROOM STATUS MANAGEMENT ====================

  /// Mark room as cleaned
  Future<bool> markRoomCleaned(String roomId) async {
    try {
      _setLoading(true);
      _clearError();

      final updateData = {
        'status': 'available',
        'isAvailable': true,
        'lastCleanedAt': FieldValue.serverTimestamp(),
      };

      await _firebaseService.updateRoom(roomId, updateData);

      _setLoading(false);
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to mark room as cleaned: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Mark room for maintenance
  Future<bool> markRoomForMaintenance(String roomId, String? notes) async {
    try {
      _setLoading(true);
      _clearError();

      final room = getRoomById(roomId);
      if (room != null && room.isOccupied) {
        _setError('Cannot put occupied room under maintenance');
        _setLoading(false);
        return false;
      }

      final updateData = {
        'status': 'maintenance',
        'isAvailable': false,
        'notes': notes,
      };

      await _firebaseService.updateRoom(roomId, updateData);

      _setLoading(false);
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to mark room for maintenance: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Complete room maintenance
  Future<bool> completeRoomMaintenance(String roomId) async {
    try {
      _setLoading(true);
      _clearError();

      final updateData = {
        'status': 'available',
        'isAvailable': true,
        'notes': null,
        'lastCleanedAt': FieldValue.serverTimestamp(),
      };

      await _firebaseService.updateRoom(roomId, updateData);

      _setLoading(false);
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to complete maintenance: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Update room equipment
  Future<bool> updateRoomEquipment(
      String roomId,
      Map<String, dynamic> equipment,
      ) async {
    try {
      _setLoading(true);
      _clearError();

      await _firebaseService.updateRoom(roomId, {'equipment': equipment});

      _setLoading(false);
      return true;
    } on FirebaseServiceException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to update equipment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ==================== SEARCH & FILTER ====================

  /// Search rooms by number or type
  List<Room> searchRooms(String query) {
    if (query.isEmpty) return _rooms;

    final lowerQuery = query.toLowerCase();
    return _rooms.where((room) {
      return room.roomNumber.toLowerCase().contains(lowerQuery) ||
          room.roomType.toLowerCase().contains(lowerQuery) ||
          (room.patientName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Filter rooms by status
  List<Room> filterByStatus(String status) {
    return _rooms.where((r) => r.status == status).toList();
  }

  /// Get rooms that need attention (cleaning, maintenance, overdue)
  List<Room> getRoomsNeedingAttention() {
    return _rooms.where((room) {
      return room.needsCleaning ||
          room.isUnderMaintenance ||
          room.isBeingCleaned ||
          (room.expectedDischargeDate != null &&
              room.expectedDischargeDate!.isBefore(DateTime.now()));
    }).toList();
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

  /// Clear error manually
  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _roomsSubscription?.cancel();
    super.dispose();
  }
}