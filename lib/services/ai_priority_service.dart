import 'dart:math';

class AIService {
  // Simulate AI analysis based on patient's symptoms and vital signs
  Map<String, dynamic> analyzePriority(Map<String, dynamic> vitals, List<String> symptoms) {
    double riskScore = _calculateRiskScore(vitals, symptoms);
    String priority = _assignPriority(riskScore);

    return {
      'riskScore': riskScore,
      'priority': priority,
      'confidence': Random().nextInt(40) + 60, // Simulating AI confidence (60-100%)
      'riskFactors': _identifyRiskFactors(vitals, symptoms),
    };
  }

  // Calculate a risk score (simplified for this example)
  double _calculateRiskScore(Map<String, dynamic> vitals, List<String> symptoms) {
    double score = 0.0;
    if (vitals['bp'] < 90 || vitals['bp'] > 140) score += 20;
    if (vitals['pulse'] < 60 || vitals['pulse'] > 100) score += 15;
    if (vitals['temp'] > 38) score += 25;
    if (vitals['oxygen'] < 95) score += 20;

    // Add additional score for critical symptoms
    if (symptoms.contains('chest pain')) score += 30;
    if (symptoms.contains('shortness of breath')) score += 25;

    return score;
  }

  // Assign priority based on the risk score
  String _assignPriority(double riskScore) {
    if (riskScore > 60) {
      return 'red';
    } else if (riskScore > 30) {
      return 'yellow';
    } else {
      return 'green';
    }
  }

  // Identify risk factors
  List<String> _identifyRiskFactors(Map<String, dynamic> vitals, List<String> symptoms) {
    List<String> riskFactors = [];

    if (vitals['bp'] < 90 || vitals['bp'] > 140) riskFactors.add('Abnormal Blood Pressure');
    if (vitals['pulse'] < 60 || vitals['pulse'] > 100) riskFactors.add('Abnormal Pulse');
    if (vitals['temp'] > 38) riskFactors.add('High Fever');
    if (vitals['oxygen'] < 95) riskFactors.add('Low Oxygen Levels');

    if (symptoms.contains('chest pain')) riskFactors.add('Chest Pain');
    if (symptoms.contains('shortness of breath')) riskFactors.add('Shortness of Breath');

    return riskFactors;
  }
}
