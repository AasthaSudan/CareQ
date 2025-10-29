import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../config/theme.dart';
import '../widgets/vital_input_card.dart';
import '../providers/patient_provider.dart';
import 'ai_analysis_screen.dart';

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key});

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _oxygenController = TextEditingController();

  late AnimationController _pulseAnimationController;
  late AnimationController _breathAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _breathAnimation;

  bool _isAnalyzing = false;
  int _filledCount = 0;

  @override
  void initState() {
    super.initState();

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut),
    );

    _breathAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathAnimationController, curve: Curves.easeInOut),
    );

    final patient = Provider.of<PatientProvider>(context, listen: false).currentPatient;
    if (patient != null && patient.vitals.isNotEmpty) {
      _bpController.text = patient.vitals['bp'] ?? '';
      _pulseController.text = patient.vitals['pulse']?.toString() ?? '';
      _tempController.text = patient.vitals['temperature']?.toString() ?? '';
      _oxygenController.text = patient.vitals['oxygen']?.toString() ?? '';
    }

    _bpController.addListener(_updateFilledCount);
    _pulseController.addListener(_updateFilledCount);
    _tempController.addListener(_updateFilledCount);
    _oxygenController.addListener(_updateFilledCount);
    _updateFilledCount();
  }

  void _updateFilledCount() {
    setState(() {
      _filledCount = [
        _bpController.text,
        _pulseController.text,
        _tempController.text,
        _oxygenController.text,
      ].where((text) => text.isNotEmpty).length;
    });
  }

  @override
  void dispose() {
    _bpController.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    _oxygenController.dispose();
    _pulseAnimationController.dispose();
    _breathAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumTheme.primaryPurple.withOpacity(0.05),
              Colors.white,
              PremiumTheme.accentBlue.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 24),
                      _buildProgressCard(),
                      const SizedBox(height: 32),
                      _buildVitalCards(),
                      const SizedBox(height: 24),
                      _buildInfoBanner(),
                      const SizedBox(height: 32),
                      _buildAnalyzeButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: PremiumTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: PremiumTheme.primaryPurple,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Health Monitoring',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: PremiumTheme.textDark,
                  ),
                ),
                Text(
                  'Record vital signs',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: PremiumTheme.pinkGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: PremiumTheme.accentPink.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Please enter your',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (bounds) => PremiumTheme.purpleGradient.createShader(bounds),
          child: const Text(
            'Vital Signs',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final progress = _filledCount / 4;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PremiumTheme.primaryPurple.withOpacity(0.1),
            PremiumTheme.accentBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PremiumTheme.primaryPurple.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: PremiumTheme.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: PremiumTheme.textDark,
                      ),
                    ),
                    Text(
                      '$_filledCount of 4 vitals recorded',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: PremiumTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                PremiumTheme.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCards() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildVitalInputCard(
            Icons.favorite_outline,
            'Blood Pressure',
            'mmHg',
            '120/80',
            _bpController,
            PremiumTheme.pinkGradient,
            const Color(0xFFFF4081),
          ),
        ),
        const SizedBox(height: 16),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildVitalInputCard(
            Icons.monitor_heart_outlined,
            'Pulse Rate',
            'BPM',
            '72',
            _pulseController,
            PremiumTheme.purpleGradient,
            PremiumTheme.primaryPurple,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 16),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildVitalInputCard(
            Icons.thermostat_outlined,
            'Temperature',
            '°F',
            '98.6',
            _tempController,
            PremiumTheme.blueGradient,
            PremiumTheme.accentBlue,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 16),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 700),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathAnimation.value,
                child: child,
              );
            },
            child: _buildVitalInputCard(
              Icons.air,
              'Oxygen Level',
              '%',
              '98',
              _oxygenController,
              const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              ),
              const Color(0xFF4CAF50),
              keyboardType: TextInputType.number,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalInputCard(
      IconData icon,
      String title,
      String unit,
      String hint,
      TextEditingController controller,
      LinearGradient gradient,
      Color color, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: controller.text.isNotEmpty
              ? color.withOpacity(0.3)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: controller.text.isNotEmpty
                ? color.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: VitalInputCard(
        icon: icon,
        title: title,
        unit: unit,
        hint: hint,
        controller: controller,
        gradient: gradient,
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumTheme.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PremiumTheme.infoBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PremiumTheme.infoBlue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: PremiumTheme.infoBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'AI will analyze your vitals and provide health insights',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final isEnabled = _filledCount == 4;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: isEnabled ? PremiumTheme.purpleGradient : null,
        color: isEnabled ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
            ? [
          BoxShadow(
            color: PremiumTheme.primaryPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isEnabled && !_isAnalyzing ? _analyzeVitals : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: Colors.transparent,
        ),
        child: _isAnalyzing
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              color: isEnabled ? Colors.white : Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Text(
              'Analyze with AI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _analyzeVitals() {
    if (_bpController.text.isEmpty ||
        _pulseController.text.isEmpty ||
        _tempController.text.isEmpty ||
        _oxygenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Please fill all vital signs'),
            ],
          ),
          backgroundColor: PremiumTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final provider = Provider.of<PatientProvider>(context, listen: false);
    final patient = provider.currentPatient;

    if (patient == null || patient.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('No patient found'),
            ],
          ),
          backgroundColor: PremiumTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    final vitalsMap = {
      'bp': _bpController.text,
      'pulse': int.tryParse(_pulseController.text) ?? 0,
      'temperature': double.tryParse(_tempController.text) ?? 0.0,
      'oxygen': int.tryParse(_oxygenController.text) ?? 0,
    };

    provider.updateVitals(patient.id!, vitalsMap);

    // Simulate AI processing
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AIAnalysisScreen(
            patientId: patient.id!,
            vitals: vitalsMap,
            symptoms: const {},
          ),
        ),
      );
    });
  }
}