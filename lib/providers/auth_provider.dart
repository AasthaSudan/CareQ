import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = true; // start true while checking auth
  bool get loading => _loading;

  User? get currentUser => _auth.currentUser;

  String? _userName;
  String? _userRole;

  String? get userName => _userName;
  String? get userRole => _userRole;

  bool get loggedIn => currentUser != null;

  AuthProvider() {
    // Listen for login/logout and refresh role automatically
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Handle changes in authentication state
  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _userName = null;
      _userRole = null;
      _loading = false;
      notifyListeners();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      _userName = doc.data()?['name'];
      _userRole = doc.data()?['role'];
    } catch (e) {
      debugPrint('⚠️ Failed to fetch user data: $e');
    }

    _loading = false;
    notifyListeners();
  }

  // SIGN UP
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': DateTime.now(),
      });

      _userName = name;
      _userRole = role;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // SIGN IN
  Future<void> signIn(String email, String password) async {
    _loading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // User data will be fetched automatically by listener
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
    _userName = null;
    _userRole = null;
    notifyListeners();
  }
}
