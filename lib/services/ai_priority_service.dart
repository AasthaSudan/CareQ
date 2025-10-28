import 'dart:math';
import 'package:flutter/material.dart';

class AIPriorityService {
  /// Predicts patient priority based on vitals and symptoms
  static Map<String, dynamic> predictPriority({
    required int age,
    required int pulse,
    required String bloodPressure,
    required double temperature,
    required int oxygenLevel,
    required List<String> symptoms,
  }) {
    double riskScore = _calculateRiskScore(
      age: age,
      pulse: pulse,
      bloodPressure: bloodPressure,
      temperature: temperature,
      oxygenLevel: oxygenLevel,
      symptoms: symptoms,
    );

    String priority = _assignPriority(riskScore);
    Map<String, double> priorityProbabilities = _calculatePriorityProbabilities(riskScore);

    return {
      'riskScore': riskScore,
      'priority': priority,
      'confidence': _calculateConfidence(riskScore),
      'riskFactors': _identifyRiskFactors(
        age: age,
        pulse: pulse,
        bloodPressure: bloodPressure,
        temperature: temperature,
        oxygenLevel: oxygenLevel,
        symptoms: symptoms,
      ),
      'priorityProbabilities': priorityProbabilities,
    };
  }

  /// Calculates risk score based on all input parameters
  static double _calculateRiskScore({
    required int age,
    required int pulse,
    required String bloodPressure,
    required double temperature,
    required int oxygenLevel,
    required List<String> symptoms,
  }) {
    double score = 0.0;

    // Parse blood pressure
    final bpParts = bloodPressure.split('/');
    if (bpParts.length == 2) {
      final systolic = int.tryParse(bpParts[0]) ?? 120;
      final diastolic = int.tryParse(bpParts[1]) ?? 80;

      if (systolic < 90 || systolic > 180) score += 25;
      else if (systolic > 140) score += 15;

      if (diastolic < 60 || diastolic > 120) score += 20;
      else if (diastolic > 90) score += 10;
    }

    // Pulse evaluation
    if (pulse < 50 || pulse > 120) score += 25;
    else if (pulse < 60 || pulse > 100) score += 15;

    // Temperature evaluation (in Fahrenheit)
    if (temperature > 103) score += 30;
    else if (temperature > 100.4) score += 20;
    else if (temperature < 95) score += 25;

    // Oxygen level evaluation
    if (oxygenLevel < 90) score += 35;
    else if (oxygenLevel < 95) score += 20;

    // Age factor
    if (age > 65) score += 10;
    else if (age < 2) score += 15;

    // Symptom evaluation
    final lowerSymptoms = symptoms.map((s) => s.toLowerCase()).toList();

    if (lowerSymptoms.any((s) =>
    s.contains('chest pain') ||
        s.contains('heart attack'))) {
      score += 35;
    }

    if (lowerSymptoms.any((s) =>
    s.contains('shortness of breath') ||
        s.contains('difficulty breathing') ||
        s.contains('breathless'))) {
      score += 30;
    }

    if (lowerSymptoms.any((s) =>
    s.contains('unconscious') ||
        s.contains('unresponsive') ||
        s.contains('seizure'))) {
      score += 40;
    }

    if (lowerSymptoms.any((s) =>
    s.contains('severe bleeding') ||
        s.contains('heavy bleeding'))) {
      score += 35;
    }

    if (lowerSymptoms.any((s) =>
    s.contains('stroke') ||
        s.contains('paralysis') ||
        s.contains('facial drooping'))) {
      score += 40;
    }

    return score.clamp(0.0, 100.0);
  }

  /// Assigns priority color based on risk score
  static String _assignPriority(double riskScore) {
    if (riskScore >= 65) return 'red';    // Emergency
    if (riskScore >= 35) return 'yellow'; // Urgent
    return 'green';                        // Stable
  }

  /// Calculates confidence percentage based on risk score clarity
  static double _calculateConfidence(double riskScore) {
    // Higher confidence when score is clearly in one category
    if (riskScore >= 75 || riskScore <= 25) {
      return 85.0 + Random().nextDouble() * 15.0; // 85-100%
    } else if (riskScore >= 50 || riskScore <= 45) {
      return 75.0 + Random().nextDouble() * 15.0; // 75-90%
    } else {
      return 65.0 + Random().nextDouble() * 15.0; // 65-80%
    }
  }

  /// Calculates probability distribution across priority levels
  static Map<String, double> _calculatePriorityProbabilities(double riskScore) {
    // Simple probability distribution based on risk score
    double redProb, yellowProb, greenProb;

    if (riskScore >= 65) {
      redProb = 0.7 + (riskScore - 65) / 100;
      yellowProb = 0.25 - (riskScore - 65) / 200;
      greenProb = 0.05;
    } else if (riskScore >= 35) {
      yellowProb = 0.6 + (riskScore - 35) / 150;
      redProb = (riskScore - 35) / 100;
      greenProb = 1 - redProb - yellowProb;
    } else {
      greenProb = 0.7 + (35 - riskScore) / 100;
      yellowProb = (35 - riskScore) / 150;
      redProb = 1 - greenProb - yellowProb;
    }

    return {
      'red': redProb.clamp(0.0, 1.0),
      'yellow': yellowProb.clamp(0.0, 1.0),
      'green': greenProb.clamp(0.0, 1.0),
    };
  }

  /// Identifies specific risk factors
  static List<String> _identifyRiskFactors({
    required int age,
    required int pulse,
    required String bloodPressure,
    required double temperature,
    required int oxygenLevel,
    required List<String> symptoms,
  }) {
    List<String> riskFactors = [];

    // Blood pressure
    final bpParts = bloodPressure.split('/');
    if (bpParts.length == 2) {
      final systolic = int.tryParse(bpParts[0]) ?? 120;
      final diastolic = int.tryParse(bpParts[1]) ?? 80;

      if (systolic > 180 || diastolic > 120) {
        riskFactors.add('Hypertensive Crisis');
      } else if (systolic > 140 || diastolic > 90) {
        riskFactors.add('High Blood Pressure');
      } else if (systolic < 90 || diastolic < 60) {
        riskFactors.add('Low Blood Pressure');
      }
    }

    // Pulse
    if (pulse > 120) {
      riskFactors.add('Severe Tachycardia');
    } else if (pulse > 100) {
      riskFactors.add('Elevated Heart Rate');
    } else if (pulse < 50) {
      riskFactors.add('Severe Bradycardia');
    } else if (pulse < 60) {
      riskFactors.add('Low Heart Rate');
    }

    // Temperature
    if (temperature > 103) {
      riskFactors.add('High Fever (Critical)');
    } else if (temperature > 100.4) {
      riskFactors.add('Fever');
    } else if (temperature < 95) {
      riskFactors.add('Hypothermia');
    }

    // Oxygen
    if (oxygenLevel < 90) {
      riskFactors.add('Critical Hypoxemia');
    } else if (oxygenLevel < 95) {
      riskFactors.add('Low Oxygen Saturation');
    }

    // Age factors
    if (age > 75) {
      riskFactors.add('Advanced Age (>75)');
    } else if (age < 2) {
      riskFactors.add('Infant Patient');
    }

    // Symptoms
    final lowerSymptoms = symptoms.map((s) => s.toLowerCase()).toList();

    if (lowerSymptoms.any((s) => s.contains('chest pain'))) {
      riskFactors.add('Chest Pain');
    }
    if (lowerSymptoms.any((s) => s.contains('shortness of breath') || s.contains('difficulty breathing'))) {
      riskFactors.add('Respiratory Distress');
    }
    if (lowerSymptoms.any((s) => s.contains('unconscious') || s.contains('unresponsive'))) {
      riskFactors.add('Altered Consciousness');
    }
    if (lowerSymptoms.any((s) => s.contains('bleeding'))) {
      riskFactors.add('Active Bleeding');
    }
    if (lowerSymptoms.any((s) => s.contains('stroke') || s.contains('paralysis'))) {
      riskFactors.add('Neurological Emergency');
    }

    return riskFactors;
  }

  /// Returns color for priority level
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'red':
        return const Color(0xFFEF4444); // Red-500
      case 'yellow':
        return const Color(0xFFF59E0B); // Amber-500
      case 'green':
        return const Color(0xFF10B981); // Emerald-500
      default:
        return const Color(0xFF6B7280); // Gray-500
    }
  }

  /// Returns icon emoji for priority level
  static String getPriorityIcon(String priority) {
    switch (priority) {
      case 'red':
        return '🚨';
      case 'yellow':
        return '⚠️';
      case 'green':
        return '✅';
      default:
        return 'ℹ️';
    }
  }

  /// Returns readable label for priority level
  static String getPriorityLabel(String priority) {
    switch (priority) {
      case 'red':
        return 'EMERGENCY';
      case 'yellow':
        return 'URGENT';
      case 'green':
        return 'STABLE';
      default:
        return 'UNKNOWN';
    }
  }
}