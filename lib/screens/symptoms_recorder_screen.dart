import 'package:flutter/material.dart';
import 'vital_signs_screen.dart';
import '../config/theme.dart';

class SymptomsRecorderScreen extends StatefulWidget {
  final String patientId; // ✅ receive patientId from previous screen

  const SymptomsRecorderScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<SymptomsRecorderScreen> createState() => _SymptomsRecorderScreenState();
}

class _SymptomsRecorderScreenState extends State<SymptomsRecorderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _symptomsController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Save or process symptoms here if needed
    final symptomsData = {
      'symptoms': _symptomsController.text.trim(),
    };

    // ✅ Navigate to VitalSignsScreen with the SAME patientId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VitalSignsScreen(
          patientId: widget.patientId,
        ),
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.backgroundLight, // ✅ already defined in your theme
      appBar: AppBar(
        title: const Text('Record Symptoms'),
        backgroundColor: PremiumTheme.primaryPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _symptomsController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Enter Symptoms',
                  hintText: 'Describe patient symptoms...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter symptoms' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Continue to Vital Signs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
