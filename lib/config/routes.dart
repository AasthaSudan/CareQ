import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/new_patient_registration_screen.dart';
import '../screens/existing_patient_search_screen.dart';
import '../screens/document_upload_screen.dart';
import '../screens/symptoms_recorder_screen.dart';
import '../screens/ai_analysis_screen.dart';
import '../screens/patient_queue_status_screen.dart';
import '../screens/room_assignment_screen.dart';
import '../screens/discharge_summary_screen.dart';
import '../screens/welcome_screen.dart';


class AppRoutes {
  static const String splash = '/';
  static const String patientTypeSelection = '/patient-type';
  static const String newPatient = '/new-patient';
  static const String existingPatient = '/existing-patient';
  static const String documentUpload = '/document-upload';
  static const String vitalSigns = '/vital-signs';
  static const String symptoms = '/symptoms';
  static const String aiAnalysis = '/ai-analysis';
  static const String queueStatus = '/queue-status';
  static const String roomAssignment = '/room-assignment';
  static const String dischargeSummary = '/discharge-summary';
  static const String patientDashboard = '/patient-dashboard';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    patientTypeSelection: (_) => const WelcomeScreen(),
    newPatient: (_) => const NewPatientRegistrationScreen(),
    existingPatient: (_) => const ExistingPatientSearchScreen(),
    documentUpload: (_) => const DocumentUploadScreen(),
    vitalSigns: (_) => const VitalSignsScreen(),
    symptoms: (_) => const SymptomsRecorderScreen(),
    aiAnalysis: (_) => const AIAnalysisScreen(vitals: {},),
    queueStatus: (_) => const PatientQueueStatusScreen(),
    roomAssignment: (_) => const RoomAssignmentScreen(),
    dischargeSummary: (_) => const DischargeSummaryScreen(),
    patientDashboard: (_) => const PatientQueueStatusScreen(),
  };
}
