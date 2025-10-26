import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload document to Firebase Storage
  Future<String> uploadDocument(File file, String patientId, String documentName) async {
    try {
      final ref = _storage.ref().child('patients/$patientId/documents/$documentName');
      await ref.putFile(file);
      final documentUrl = await ref.getDownloadURL();
      return documentUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Get document URL
  Future<String?> getDocumentUrl(String patientId, String documentName) async {
    try {
      final ref = _storage.ref().child('patients/$patientId/documents/$documentName');
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Delete document
  Future<void> deleteDocument(String patientId, String documentName) async {
    try {
      final ref = _storage.ref().child('patients/$patientId/documents/$documentName');
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }
}
