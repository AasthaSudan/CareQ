class AppConstants {
  // App
  static const String appName = "Premium Healthcare";

  // Firebase Collections
  static const String patientsCollection = "patients";
  static const String queueCollection = "queue";
  static const String roomsCollection = "rooms";
  static const String medicalRecordsCollection = "medicalRecords";

  // Default Values
  static const int defaultPainLevel = 5;
  static const int defaultRiskScore = 0;
  static const String defaultPriority = "green";

  // Queue
  static const int estimatedWaitTimePerPatient = 15; // in minutes

  // AI Priority
  static const Map<String, String> priorityLabels = {
    "green": "Low",
    "yellow": "Medium",
    "red": "High",
  };

  static const Map<String, String> priorityIcons = {
    "green": "🟢",
    "yellow": "🟡",
    "red": "🔴",
  };
}
