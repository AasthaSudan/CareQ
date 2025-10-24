import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Stream to listen to user's auth state (Login / Logout)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get currently logged in user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Sign Up with Email & Password
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Update Display Name
      await userCredential.user!.updateDisplayName(fullName);

      return "Account created successfully!";
    } on FirebaseAuthException catch (e) {
      return _handleAuthErrors(e);
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  /// Login with Email & Password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return "Login successful";
    } on FirebaseAuthException catch (e) {
      return _handleAuthErrors(e);
    } catch (e) {
      return "Something went wrong. Try again";
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Delete Account (Optional)
  Future<String?> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser!.delete();
      return "Account deleted successfully.";
    } on FirebaseAuthException catch (e) {
      return _handleAuthErrors(e);
    }
  }

  /// Error Handling Function
  String _handleAuthErrors(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "Invalid email format.";
      case 'email-already-in-use':
        return "Email already exists. Try login.";
      case 'weak-password':
        return "Password is too weak. Use 6+ characters.";
      case 'user-not-found':
        return "No account found with this email.";
      case 'wrong-password':
        return "Wrong password. Try again.";
      case 'user-disabled':
        return "This account has been disabled.";
      default:
        return "Auth error: ${e.message}";
    }
  }
}
