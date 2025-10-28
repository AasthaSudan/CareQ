// lib/screens/ai_analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../config/theme.dart';
import '../services/ai_priority_service.dart';
import '../models/triage_model.dart';
import '../models/patient_model.dart';
import '../providers/patient_provider.dart';

class AIAnalysisScreen extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> vitals;
  final List<String> symptoms;

  const AIAnalysisScreen({
    Key? key,
    required this.patientId,
    required this.vitals,
    required this.symptoms,
  }) : super(key: key);

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _analysisComplete = false;
  bool _hasError = false;
  String? _errorMessage;
  Map<String, dynamic>? _result;
  Patient? _patient;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadPatientAndAnalyze();
  }

  Future<void> _loadPatientAndAnalyze() async {
    try {
      // Load patient data
      final provider = context.read<PatientProvider>();
      _patient = await provider.getPatient(widget.patientId);

      if (_patient == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Patient not found';
        });
        return;
      }

      // Simulate analysis delay
      await Future.delayed(const Duration(seconds: 3));

      // Run AI analysis
      _result = AIPriorityService.predictPriority(
        age: _patient!.age,
        pulse: widget.vitals['pulse'] ?? 0,
        bloodPressure: widget.vitals['bloodPressure'] ?? '120/80',
        temperature: widget.vitals['temperature'] ?? 98.6,
        oxygenLevel: widget.vitals['oxygenLevel'] ?? 98,
        symptoms: widget.symptoms,
      );

      // Create triage record
      final triage = Triage(
        id: '',
        patientId: widget.patientId,
        priority: _result!['priority'],
        vitals: widget.vitals,
        symptoms: widget.symptoms,
        triageTime: DateTime.now(),
        assessmentResult: _getAssessmentResult(_result!['priority']),
        aiConfidence: _parseDouble(_result!['confidence']),
        riskScore: _parseDouble(_result!['riskScore']),
        riskFactors: List<String>.from(_result!['riskFactors'] ?? []),
        priorityProbabilities: _parsePriorityProbabilities(_result!),
      );

      // Save triage to Firebase
      await provider.addTriageRecord(triage);

      // Update patient with priority
      await provider.updatePatient(widget.patientId, {
        'priority': _result!['priority'],
        'status': 'waiting',
      });

      setState(() {
        _analysisComplete = true;
      });

      _controller.forward();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _getAssessmentResult(String priority) {
    switch (priority) {
      case 'red':
        return 'emergency';
      case 'yellow':
        return 'urgent';
      case 'green':
        return 'stable';
      default:
        return 'stable';
    }
  }

  Map<String, double>? _parsePriorityProbabilities(Map<String, dynamic> result) {
    if (result['priorityProbabilities'] != null) {
      return Map<String, double>.from(result['priorityProbabilities']);
    }
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: PremiumTheme.purpleGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _hasError
                    ? _buildError()
                    : _analysisComplete
                    ? _buildResults()
                    : _buildAnalyzing(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'AI Analysis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          const Text(
            'AI is analyzing',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'your vitals & symptoms',
            style: TextStyle(fontSize: 20, color: Colors.white70),
          ),
          const SizedBox(height: 40),
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Please wait...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              'Analysis Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: PremiumTheme.textGray,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_result == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: PremiumTheme.backgroundLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildSuccessBadge(),
                const SizedBox(height: 32),
                _buildRiskScoreIndicator(),
                const SizedBox(height: 32),
                _buildPriorityCard(),
                const SizedBox(height: 24),
                if (_patient != null) _buildPatientInfo(),
                const SizedBox(height: 24),
                _buildVitalsCard(),
                const SizedBox(height: 24),
                if (_result!['riskFactors'] != null &&
                    (_result!['riskFactors'] as List).isNotEmpty)
                  _buildRiskFactorsCard(),
                const SizedBox(height: 24),
                _buildRecommendations(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: PremiumTheme.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PremiumTheme.successGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.check_circle,
            color: PremiumTheme.successGreen,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Analysis Complete',
            style: TextStyle(
              color: PremiumTheme.successGreen,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskScoreIndicator() {
    final riskScore = _parseDouble(_result!['riskScore']);
    final priority = _result!['priority'];

    return CircularPercentIndicator(
      radius: 100,
      lineWidth: 20,
      percent: (riskScore / 100).clamp(0.0, 1.0),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            riskScore.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AIPriorityService.getPriorityColor(priority),
            ),
          ),
          const Text(
            'Risk Score',
            style: TextStyle(
              fontSize: 14,
              color: PremiumTheme.textGray,
            ),
          ),
        ],
      ),
      progressColor: AIPriorityService.getPriorityColor(priority),
      backgroundColor: Colors.grey.shade200,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 1500,
    );
  }

  Widget _buildPriorityCard() {
    final priority = _result!['priority'];
    final confidence = _parseDouble(_result!['confidence']);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AIPriorityService.getPriorityColor(priority),
            AIPriorityService.getPriorityColor(priority).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AIPriorityService.getPriorityColor(priority).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AIPriorityService.getPriorityIcon(priority),
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            AIPriorityService.getPriorityLabel(priority),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI Confidence: ${confidence.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 20),
          _buildInfoRow('Name', _patient!.name),
          _buildInfoRow('Age', '${_patient!.age} years'),
          _buildInfoRow('Gender', _patient!.gender),
          _buildInfoRow('Contact', _patient!.contact),
        ],
      ),
    );
  }

  Widget _buildVitalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vital Signs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 20),
          _buildVitalRow(
            'Blood Pressure',
            widget.vitals['bloodPressure']?.toString() ?? 'N/A',
            Icons.favorite,
          ),
          _buildVitalRow(
            'Pulse',
            '${widget.vitals['pulse'] ?? 'N/A'} bpm',
            Icons.monitor_heart,
          ),
          _buildVitalRow(
            'Temperature',
            '${widget.vitals['temperature'] ?? 'N/A'}°F',
            Icons.thermostat,
          ),
          _buildVitalRow(
            'Oxygen Level',
            '${widget.vitals['oxygenLevel'] ?? 'N/A'}%',
            Icons.air,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactorsCard() {
    final riskFactors = _result!['riskFactors'] as List;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                color: PremiumTheme.warningOrange,
              ),
              SizedBox(width: 8),
              Text(
                'Key Risk Factors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...riskFactors.map(
                (factor) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PremiumTheme.warningOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: PremiumTheme.warningOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      factor.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final priority = _result!['priority'];
    String recommendation;
    IconData icon;
    Color color;

    switch (priority) {
      case 'red':
        recommendation = 'Immediate medical attention required. Patient should be seen by a doctor immediately.';
        icon = Icons.emergency;
        color = Colors.red;
        break;
      case 'yellow':
        recommendation = 'Urgent care needed. Patient should be evaluated within 30 minutes.';
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case 'green':
        recommendation = 'Stable condition. Patient can wait for routine examination.';
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        recommendation = 'Please consult with medical staff.';
        icon = Icons.info;
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommendation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation,
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: PremiumTheme.textGray,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PremiumTheme.primaryPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to dashboard or queue
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumTheme.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.dashboard),
            label: const Text(
              'View Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: PremiumTheme.primaryPurple,
              side: const BorderSide(
                color: PremiumTheme.primaryPurple,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.close),
            label: const Text(
              'Close',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}