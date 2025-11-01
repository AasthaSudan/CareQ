// lib/main.dart - Complete with Auth Navigation
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/room_provider.dart';
import 'screens/auth/login_screen.dart' hide AppTheme;
import 'screens/auth/sign_up_screen.dart' hide AppTheme;
import 'screens/dashboard/patient_dashboard.dart';
import 'screens/dashboard/doctor_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CareQApp());
}

class CareQApp extends StatelessWidget {
  const CareQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CareQ',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        routes: {
          // Removed '/welcome' and the WelcomeScreen route
          LoginScreen.routeName: (_) => const LoginScreen(),
          SignUpScreen.routeName: (_) => const SignUpScreen(),
          PatientDashboard.routeName: (_) => const PatientDashboard(),
          DoctorDashboard.routeName: (_) => const DoctorDashboard(),
          // Add other routes here
        },
      ),
    );
  }
}

// ============================================
// AUTH WRAPPER - Handles Navigation
// ============================================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Show loading while checking auth state
        if (auth.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryPurple,
              ),
            ),
          );
        }

        // Not logged in - show login screen
        if (!auth.loggedIn) {
          return const LoginScreen();
        }

        // Logged in - route based on role
        switch (auth.currentRole) {
          case 'patient':
          // return const PatientHome();
            return _buildPlaceholderDashboard(context, 'Patient Dashboard');
          case 'doctor':
          case 'admin':
          // return const AdminDashboard();
            return _buildPlaceholderDashboard(context, 'Doctor/Admin Dashboard');
          default:
            return const LoginScreen();
        }
      },
    );
  }

  // Temporary placeholder until you add actual dashboard screens
  Widget _buildPlaceholderDashboard(BuildContext context, String title) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient(),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Column(
                      children: [
                        Text(
                          'Welcome!',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Role: ${auth.currentRole ?? "Unknown"}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () async {
                    await Provider.of<AuthProvider>(context, listen: false).signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
