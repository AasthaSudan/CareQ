// lib/screens/vital_signs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import 'ai_analysis_screen.dart';

class VitalSignsScreen extends StatefulWidget {
  final String patientId;

  const VitalSignsScreen({super.key, required this.patientId});

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _bpController = TextEditingController();
  final _pulseController = TextEditingController();
  final _tempController = TextEditingController();
  final _oxygenController = TextEditingController();

  double _progress = 0.33;
  bool _isAnalyzing = false;
  bool _showContinue = false;

  @override
  void dispose() {
    _bpController.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    _oxygenController.dispose();
    super.dispose();
  }

  Future<void> _submitVitals(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final vitals = {
      'bp': _bpController.text,
      'pulse': _pulseController.text,
      'temperature': _tempController.text,
      'oxygen': _oxygenController.text,
    };

    setState(() {
      _isAnalyzing = true;
      _progress = 0.66;
    });

    await Future.delayed(const Duration(seconds: 1)); // mimic processing
    setState(() {
      _isAnalyzing = false;
      _showContinue = true;
      _progress = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patientProvider = Provider.of<PatientProvider>(context);
    final patient = patientProvider.currentPatient;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Vital Signs'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Step Progress
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade200,
              color: theme.colorScheme.primary,
              minHeight: 6,
            ),
            const SizedBox(height: 24),

            Expanded(
              child: _isAnalyzing
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(strokeWidth: 5),
                  const SizedBox(height: 20),
                  Text(
                    "Analyzing vital signs...",
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              )
                  : _showContinue
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle,
                      color: theme.colorScheme.primary, size: 70),
                  const SizedBox(height: 16),
                  const Text(
                    "Vitals recorded successfully!",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AIAnalysisScreen(
                            patientId: widget.patientId,
                            vitals: {
                              'bp': _bpController.text,
                              'pulse': _pulseController.text,
                              'temperature': _tempController.text,
                              'oxygen': _oxygenController.text,
                            },
                            symptoms: const {},
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                          fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              )
                  : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField(
                        _bpController, "Blood Pressure (mmHg)"),
                    _buildTextField(
                        _pulseController, "Pulse Rate (bpm)"),
                    _buildTextField(
                        _tempController, "Temperature (°C)"),
                    _buildTextField(
                        _oxygenController, "Oxygen Level (%)"),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => _submitVitals(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Analyze",
                        style: TextStyle(
                            fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: (value) =>
        value == null || value.isEmpty ? 'Please enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
