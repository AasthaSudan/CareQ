import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../widgets/vital_input_card.dart';
import '../providers/patient_provider.dart';
import 'ai_analysis_screen.dart';

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key});

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _oxygenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final patient = Provider.of<PatientProvider>(context, listen: false).patient;
    if (patient != null && patient.vitals.isNotEmpty) {
      _bpController.text = patient.vitals['bp'] ?? '';
      _pulseController.text = patient.vitals['pulse']?.toString() ?? '';
      _tempController.text = patient.vitals['temperature']?.toString() ?? '';
      _oxygenController.text = patient.vitals['oxygen']?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Vital Signs'),
        backgroundColor: PremiumTheme.primaryPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please enter your', style: TextStyle(fontSize: 24, color: PremiumTheme.textGray)),
            const Text('vital signs', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: PremiumTheme.primaryPurple)),
            const SizedBox(height: 32),
            _buildVitalInputCard(Icons.favorite, 'Blood Pressure', 'mmHg', '120/80', _bpController, PremiumTheme.pinkGradient),
            const SizedBox(height: 16),
            _buildVitalInputCard(Icons.monitor_heart, 'Pulse Rate', 'BPM', '72', _pulseController, PremiumTheme.purpleGradient, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildVitalInputCard(Icons.thermostat, 'Temperature', '°F', '98.6', _tempController, PremiumTheme.blueGradient, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildVitalInputCard(Icons.air, 'Oxygen Level', '%', '98', _oxygenController, const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]), keyboardType: TextInputType.number),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _analyzeVitals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumTheme.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Analyze with AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalInputCard(IconData icon, String title, String unit, String hint, TextEditingController controller, LinearGradient gradient, {TextInputType keyboardType = TextInputType.text}) {
    return VitalInputCard(
      icon: icon,
      title: title,
      unit: unit,
      hint: hint,
      controller: controller,
      gradient: gradient,
      keyboardType: keyboardType,
    );
  }

  void _analyzeVitals() {
    if (_bpController.text.isEmpty || _pulseController.text.isEmpty || _tempController.text.isEmpty || _oxygenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all vital signs')));
      return;
    }

    final provider = Provider.of<PatientProvider>(context, listen: false);
    final vitalsMap = {
      'bp': _bpController.text,
      'pulse': int.parse(_pulseController.text),
      'temperature': double.parse(_tempController.text),
      'oxygen': int.parse(_oxygenController.text),
    };

    provider.updateVitals(vitalsMap);  // No need to use `.then()`

    // Navigate directly to AI Analysis Screen
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AIAnalysisScreen()));
  }
}
