import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  bool get loading => _loading;

  User? get currentUser => _auth.currentUser;

  String? _userName;
  String? get userName => _userName;

  bool get loggedIn => currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _userName = null;
      _loading = false;
      notifyListeners();
      return;
    }
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      _userName = doc.data()?['name'] ?? user.email?.split('@')[0];
    } catch (e) {
      debugPrint('Failed to fetch user data: $e');
      _userName = user.email?.split('@')[0];
    }
    _loading = false;
    notifyListeners();
  }

  // SIGN UP
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
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
        'role': 'patient',
        'createdAt': DateTime.now(),
      });
      _userName = name;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }


  Future<void> signIn(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userName = null;
    notifyListeners();
  }
}
