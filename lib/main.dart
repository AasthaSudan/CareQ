import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'providers/patient_provider.dart'; // Make sure you import the patient provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PatientProvider>(
      create: (context) => PatientProvider(), // Provide the PatientProvider here
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Emergency Triage',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/splash', // Always start with SplashScreen
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/welcome': (context) => const WelcomeScreen(),
        },
      ),
    );
  }
}
