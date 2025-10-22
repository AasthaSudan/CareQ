class AppConstants {
  // App Info
  static const String appName = 'Emergency Triage';
  static const String appVersion = '1.0.0';

  // Firebase (Add your config later)
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY'; // Add later

  // Symptoms List
  static const List<Map<String, String>> symptoms = [
    {'id': 'chest_pain', 'label': 'Chest Pain', 'icon': '💔'},
    {'id': 'difficulty_breathing', 'label': 'Difficulty Breathing', 'icon': '😮‍💨'},
    {'id': 'severe_bleeding', 'label': 'Severe Bleeding', 'icon': '🩸'},
    {'id': 'unconscious', 'label': 'Unconscious/Unresponsive', 'icon': '😵'},
    {'id': 'high_fever', 'label': 'High Fever (>103°F)', 'icon': '🌡️'},
    {'id': 'severe_pain', 'label': 'Severe Pain', 'icon': '😣'},
    {'id': 'vomiting', 'label': 'Persistent Vomiting', 'icon': '🤮'},
    {'id': 'stroke_symptoms', 'label': 'Stroke Symptoms', 'icon': '🧠'},
    {'id': 'severe_head_injury', 'label': 'Severe Head Injury', 'icon': '🤕'},
    {'id': 'seizures', 'label': 'Seizures', 'icon': '⚡'},
    {'id': 'severe_allergic_reaction', 'label': 'Severe Allergic Reaction', 'icon': '🐝'},
    {'id': 'dehydration', 'label': 'Severe Dehydration', 'icon': '💧'},
  ];

  // Priority Levels
  static const Map<String, Map<String, dynamic>> priorities = {
    'red': {
      'label': 'CRITICAL',
      'description': 'Immediate attention required',
      'color': 0xFFEF5350,
      'icon': '🚨',
    },
    'yellow': {
      'label': 'URGENT',
      'description': 'Needs prompt attention',
      'color': 0xFFFFA726,
      'icon': '⚠️',
    },
    'green': {
      'label': 'NON-URGENT',
      'description': 'Can wait',
      'color': 0xFF66BB6A,
      'icon': '✓',
    },
  };

  // Patient Status
  static const List<String> patientStatuses = [
    'waiting',
    'in-assessment',
    'in-treatment',
    'discharged',
  ];

  // Room Specialties
  static const List<String> roomSpecialties = [
    'general',
    'cardiac',
    'trauma',
    'pediatric',
    'observation',
  ];

  // Vital Signs Normal Ranges
  static const Map<String, Map<String, dynamic>> vitalRanges = {
    'pulse': {
      'normal': [60, 100],
      'unit': 'bpm',
    },
    'temperature': {
      'normal': [97.0, 99.0],
      'unit': '°F',
    },
    'oxygen': {
      'normal': [95, 100],
      'unit': '%',
    },
    'systolic_bp': {
      'normal': [90, 120],
      'unit': 'mmHg',
    },
    'diastolic_bp': {
      'normal': [60, 80],
      'unit': 'mmHg',
    },
  };

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Messages
  static const String noInternetMessage = 'No internet connection. Data will sync when online.';
  static const String errorMessage = 'Something went wrong. Please try again.';
  static const String successMessage = 'Operation completed successfully!';
}