// ==================== AI ANALYSIS SCREEN ====================
// lib/screens/ai_analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:confetti/confetti.dart';
import '../config/theme.dart';
import '../services/ai_priority_service.dart';
import '../models/triage_model.dart';
import '../providers/patient_provider.dart';

class AIAnalysisScreen extends StatefulWidget {
  final Map<String, dynamic> vitals;

  const AIAnalysisScreen({
    super.key,
    required this.vitals,
  });

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;
  bool _analysisComplete = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _runAnalysis();
  }

  void _runAnalysis() async {
    await Future.delayed(const Duration(seconds: 3));

    // Get patient from provider
    final patient = context.read<PatientProvider>().currentPatient;

    _result = AIPriorityService.predictPriority(
      age: patient?.age ?? 45,
      pulse: widget.vitals['pulse'],
      bloodPressure: widget.vitals['bp'],
      temperature: widget.vitals['temp'],
      oxygenLevel: widget.vitals['oxygen'],
      symptoms: ['chest_pain'], // Get from previous screen
    );

    setState(() => _analysisComplete = true);
    _controller.forward();

    if (_result!['priority'] == 'red') {
      _confettiController.play();
    }

    // Save triage to Firebase
    if (patient != null) {
      Triage triage = Triage(
        id: '',
        patientId: patient.id,
        priority: _result!['priority'],
        vitals: widget.vitals,
        symptoms: ['chest_pain'],
        triageTime: DateTime.now(),
        aiConfidence: double.parse(_result!['confidence']),
        riskScore: double.parse(_result!['riskScore']),
      );

      await context.read<PatientProvider>().addTriageRecord(triage);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
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
          child: Stack(
            children: [
              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                  ],
                ),
              ),

              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _analysisComplete
                        ? _buildResults()
                        : _buildAnalyzing(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
          const SizedBox(height: 40),

          const Text(
            'AI is analyzing',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
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
        ],
      ),
    );
  }

  Widget _buildResults() {
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
            // Success Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: PremiumTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '✓ Analysis Complete',
                style: TextStyle(
                  color: PremiumTheme.successGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Risk Score Circle
            CircularPercentIndicator(
              radius: 100,
              lineWidth: 20,
              percent: double.parse(_result!['riskScore']) / 100,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _result!['riskScore'],
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: PremiumTheme.primaryPurple,
                    ),
                  ),
                  const Text(
                    'Risk Score',
                    style: TextStyle(fontSize: 14, color: PremiumTheme.textGray),
                  ),
                ],
              ),
              progressColor: AIPriorityService.getPriorityColor(_result!['priority']),
              backgroundColor: Colors.grey.shade200,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 32),

            // Priority Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AIPriorityService.getPriorityColor(_result!['priority']),
                    AIPriorityService.getPriorityColor(_result!['priority']).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AIPriorityService.getPriorityColor(_result!['priority']).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    AIPriorityService.getPriorityIcon(_result!['priority']),
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AIPriorityService.getPriorityLabel(_result!['priority']),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI Confidence: ${_result!['confidence']}%',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Risk Factors
            if (_result!['riskFactors'].isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: PremiumTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Key Risk Factors',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...(_result!['riskFactors'] as List).map(
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
                                Icons.warning_amber,
                                color: PremiumTheme.warningOrange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(factor, style: const TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
                        (route) => false,
                  );
                },
                child: const Text(
                  'View Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
