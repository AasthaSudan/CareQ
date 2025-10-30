// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/theme.dart';
import 'providers/patient_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/register_patient_screen.dart';
import 'screens/vital_signs_screen.dart';
import 'screens/ai_analysis_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/existing_patient_screen.dart';

// If you use the auto-generated Firebase options, import them here:
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CareQApp());
}

class CareQApp extends StatelessWidget {
  const CareQApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PatientProvider>(
      create: (_) => PatientProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CareQ',
        theme: AppTheme.lightTheme,
        initialRoute: WelcomeScreen.routeName,
        routes: {
          WelcomeScreen.routeName: (_) => const WelcomeScreen(),
          RegisterPatientScreen.routeName: (_) => const RegisterPatientScreen(),
          VitalSignsScreen.routeName: (_) => const VitalSignsScreen(),
          AIAnalysisScreen.routeName: (_) => const AIAnalysisScreen(),
          QueueScreen.routeName: (_) => const QueueScreen(),
          ExistingPatientScreen.routeName: (_) => const ExistingPatientScreen(),
        },
      ),
    );
  }
}
