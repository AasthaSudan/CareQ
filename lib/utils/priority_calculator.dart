import 'package:flutter/material.dart';
import '../models/vital_signs.dart';
import '../theme.dart';

class PriorityCalculator {
  static String calculate(Map<String, bool> symptoms, VitalSigns vitals) {
    // Critical conditions
    if (symptoms['chest_pain'] == true ||
        symptoms['difficulty_breathing'] == true ||
        symptoms['severe_bleeding'] == true ||
        symptoms['unconscious'] == true ||
        (vitals.spO2 != null && vitals.spO2! < 90) ||
        (vitals.pulse != null && (vitals.pulse! > 130 || vitals.pulse! < 40))) {
      return 'critical';
    }

    // Urgent conditions
    if (symptoms['high_fever'] == true ||
        symptoms['severe_pain'] == true ||
        (vitals.pulse != null && vitals.pulse! > 110) ||
        (vitals.temperature != null && vitals.temperature! > 103) ||
        (vitals.spO2 != null && vitals.spO2! < 94)) {
      return 'urgent';
    }

    // Stable
    return 'stable';
  }

  static Color getColor(String priority) {
    switch (priority) {
      case 'critical':
        return AppTheme.critical;
      case 'urgent':
        return AppTheme.urgent;
      case 'stable':
        return AppTheme.stable;
      default:
        return Colors.grey;
    }
  }

  static String getLabel(String priority) {
    return priority[0].toUpperCase() + priority.substring(1);
  }
}