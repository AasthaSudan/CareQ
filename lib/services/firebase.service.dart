// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/patient_model.dart';
import '../models/triage_model.dart';
import '../models/room_model.dart';

/// Custom exception for Firebase operations
class FirebaseServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  FirebaseServiceException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'FirebaseServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection names as constants
  static const String _patientsCollection = 'patients';
  static const String _triageCollection = 'triage';
  static const String _roomsCollection = 'rooms';

  // ==================== AUTHENTICATION ====================

  /// Authenticate user with email and password
  ///
  /// Throws [FirebaseServiceException] on authentication failure
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseServiceException(
        _getAuthErrorMessage(e.code),
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in: $e');
      }
      throw FirebaseServiceException(
        'An unexpected error occurred during sign in',
        originalError: e,
      );
    }
  }

  /// Sign in anonymously (for quick patient registration)
  ///
  /// Throws [FirebaseServiceException] on authentication failure
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseServiceException(
        'Failed to sign in anonymously: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in anonymously: $e');
      }
      throw FirebaseServiceException(
        'An unexpected error occurred during anonymous sign in',
        originalError: e,
      );
    }
  }

  /// Sign out user
  ///
  /// Throws [FirebaseServiceException] on sign out failure
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      throw FirebaseServiceException(
        'Failed to sign out',
        originalError: e,
      );
    }
  }

  /// Get current user
  ///
  /// Returns null if no user is signed in
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== PATIENT OPERATIONS ====================

  /// Add new patient and return generated ID
  ///
  /// Throws [FirebaseServiceException] on operation failure
  Future<String> addPatient(Patient patient) async {
    try {
      final docRef = await _firestore
          .collection(_patientsCollection)
          .add(patient.toFirestore());

      if (kDebugMode) {
        print('Patient added with ID: ${docRef.id}');
      }

      return docRef.id;
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to add patient: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error adding patient: $e');
      }
      throw FirebaseServiceException(
        'An unexpected error occurred while adding patient',
        originalError: e,
      );
    }
  }

  /// Update patient data
  ///
  /// Throws [FirebaseServiceException] on operation failure
  Future<void> updatePatient(String patientId, Map<String, dynamic> data) async {
    try {
      if (patientId.isEmpty) {
        throw FirebaseServiceException('Patient ID cannot be empty');
      }

      // Add timestamp for tracking
      final updateData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_patientsCollection)
          .doc(patientId)
          .update(updateData);

      if (kDebugMode) {
        print('Patient updated: $patientId');
      }
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to update patient: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating patient: $e');
      }
      rethrow;
    }
  }

  /// Get patient data by ID
  ///
  /// Returns null if patient not found
  /// Throws [FirebaseServiceException] on operation failure
  Future<Patient?> getPatient(String patientId) async {
    try {
      if (patientId.isEmpty) {
        throw FirebaseServiceException('Patient ID cannot be empty');
      }

      final doc = await _firestore
          .collection(_patientsCollection)
          .doc(patientId)
          .get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('Patient not found: $patientId');
        }
        return null;
      }

      return Patient.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to get patient: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting patient: $e');
      }
      throw FirebaseServiceException(
        'An unexpected error occurred while fetching patient',
        originalError: e,
      );
    }
  }

  /// Get all patients stream
  Stream<List<Patient>> getPatientsStream() {
    return _firestore
        .collection(_patientsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Patient.fromFirestore(doc))
        .toList());
  }

  /// Delete patient by ID
  ///
  /// Throws [FirebaseServiceException] on operation failure
  Future<void> deletePatient(String patientId) async {
    try {
      if (patientId.isEmpty) {
        throw FirebaseServiceException('Patient ID cannot be empty');
      }

      await _firestore
          .collection(_patientsCollection)
          .doc(patientId)
          .delete();

      if (kDebugMode) {
        print('Patient deleted: $patientId');
      }
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to delete patient: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  // ==================== TRIAGE OPERATIONS ====================

  /// Add new triage record and return generated ID
  ///
  /// Throws [FirebaseServiceException] on operation failure
  Future<String> addTriage(Triage triage) async {
    try {
      final triageData = {
        ...triage.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection(_triageCollection)
          .add(triageData);

      if (kDebugMode) {
        print('Triage added with ID: ${docRef.id}');
      }

      return docRef.id;
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to add triage: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error adding triage: $e');
      }
      throw FirebaseServiceException(
        'An unexpected error occurred while adding triage',
        originalError: e,
      );
    }
  }

  /// Get all triage records stream (queue)
  ///
  /// Returns stream of triage records ordered by priority
  Stream<List<Triage>> getQueueStream() {
    return _firestore
        .collection(_triageCollection)
        .orderBy('priority', descending: true)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Triage.fromFirestore(doc))
        .toList())
        .handleError((error) {
      if (kDebugMode) {
        print('Error in queue stream: $error');
      }
    });
  }

  /// Get triage by ID
  ///
  /// Returns null if triage not found
  /// Throws [FirebaseServiceException] on operation failure
  Future<Triage?> getTriage(String triageId) async {
    try {
      if (triageId.isEmpty) {
        throw FirebaseServiceException('Triage ID cannot be empty');
      }

      final doc = await _firestore
          .collection(_triageCollection)
          .doc(triageId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return Triage.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to get triage: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Get triage records for a specific patient
  ///
  /// Returns list of triage records ordered by most recent first
  Future<List<Triage>> getTriageByPatient(String patientId) async {
    try {
      if (patientId.isEmpty) {
        throw FirebaseServiceException('Patient ID cannot be empty');
      }

      final snapshot = await _firestore
          .collection(_triageCollection)
          .where('patientId', isEqualTo: patientId)
          .orderBy('triageTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Triage.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to get triage records: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Update triage record
  ///
  /// Throws [FirebaseServiceException] on operation failure
  Future<void> updateTriage(String triageId, Map<String, dynamic> data) async {
    try {
      if (triageId.isEmpty) {
        throw FirebaseServiceException('Triage ID cannot be empty');
      }

      final updateData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_triageCollection)
          .doc(triageId)
          .update(updateData);

      if (kDebugMode) {
        print('Triage updated: $triageId');
      }
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to update triage: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Delete triage record
  ///
  /// Throws [FirebaseServiceException] on operation failure
  Future<void> deleteTriage(String triageId) async {
    try {
      if (triageId.isEmpty) {
        throw FirebaseServiceException('Triage ID cannot be empty');
      }

      await _firestore
          .collection(_triageCollection)
          .doc(triageId)
          .delete();

      if (kDebugMode) {
        print('Triage deleted: $triageId');
      }
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to delete triage: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  // ==================== ROOM OPERATIONS ====================

  /// Add new room
  ///
  /// Throws [FirebaseServiceException] on operation failure
  Future<String> addRoom(Room room) async {
    try {
      final roomData = {
        ...room.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection(_roomsCollection)
          .add(roomData);

      if (kDebugMode) {
        print('Room added with ID: ${docRef.id}');
      }

      return docRef.id;
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to add room: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error adding room: $e');
      }
      throw FirebaseServiceException(
        'An unexpected error occurred while adding room',
        originalError: e,
      );
    }
  }

  /// Update room
  ///
  /// Throws [FirebaseServiceException] on operation failure
  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    try {
      if (roomId.isEmpty) {
        throw FirebaseServiceException('Room ID cannot be empty');
      }

      final updateData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_roomsCollection)
          .doc(roomId)
          .update(updateData);

      if (kDebugMode) {
        print('Room updated: $roomId');
      }
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to update room: ${e.message}',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating room: $e');
      }
      rethrow;
    }
  }

  /// Get room by ID
  ///
  /// Returns null if room not found
  /// Throws [FirebaseServiceException] on operation failure
  Future<Room?> getRoom(String roomId) async {
    try {
      if (roomId.isEmpty) {
        throw FirebaseServiceException('Room ID cannot be empty');
      }

      final doc = await _firestore
          .collection(_roomsCollection)
          .doc(roomId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return Room.fromMap(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to get room: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Get all rooms stream
  Stream<List<Room>> getRoomsStream() {
    return _firestore
        .collection(_roomsCollection)
        .orderBy('roomNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Room.fromMap(doc.data(), doc.id))
        .toList())
        .handleError((error) {
      if (kDebugMode) {
        print('Error in rooms stream: $error');
      }
    });
  }

  /// Delete room
  ///
  /// Throws [FirebaseServiceException] on operation failure
  Future<void> deleteRoom(String roomId) async {
    try {
      if (roomId.isEmpty) {
        throw FirebaseServiceException('Room ID cannot be empty');
      }

      await _firestore
          .collection(_roomsCollection)
          .doc(roomId)
          .delete();

      if (kDebugMode) {
        print('Room deleted: $roomId');
      }
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to delete room: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  // ==================== STORAGE OPERATIONS ====================

  /// Upload file to Firebase Storage
  ///
  /// Returns download URL of uploaded file
  /// Throws [FirebaseServiceException] on operation failure
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      if (kDebugMode) {
        print('File uploaded: $path');
      }

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to upload file: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  /// Delete file from Firebase Storage
  ///
  /// Throws [FirebaseServiceException] on operation failure
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();

      if (kDebugMode) {
        print('File deleted: $path');
      }
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to delete file: ${e.message}',
        code: e.code,
        originalError: e,
      );
    }
  }

  // ==================== HELPER METHODS ====================

  /// Get user-friendly error message for Firebase Auth errors
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}