import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Config
import 'config/theme.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_patient_screen.dart';
import 'screens/triage_assessment_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/rooms_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/ai_chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized before app runs
  runApp(const EmergencyTriageApp());
}

class EmergencyTriageApp extends StatelessWidget {
  const EmergencyTriageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Triage System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // theme.dart
      // darkTheme: AppTheme.darkTheme, // if dark theme added later

      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        // '/home': (context) => const HomeScreen(),
        // '/register-patient': (context) => const RegisterPatientScreen(),
        // '/triage': (context) => const TriageAssessmentScreen(),
        // '/queue': (context) => const QueueScreen(),
        // '/rooms': (context) => const RoomsScreen(),
        // '/statistics': (context) => const StatisticsScreen(),
        // '/ai-chat': (context) => const AiChatScreen(),
      },
    );
  }
}
