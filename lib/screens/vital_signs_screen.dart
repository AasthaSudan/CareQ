import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_provider.dart';
import '../models/patient_model.dart';
import '../models/vital_signs.dart'; // Import VitalSigns model

class VitalSignsScreen extends StatefulWidget {
  final String patientId;
  const VitalSignsScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bpController = TextEditingController();
  final _pulseController = TextEditingController();
  final _tempController = TextEditingController();
  final _spo2Controller = TextEditingController();
  bool _saving = false;

  Future<void> _saveVitals() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final provider = Provider.of<PatientProvider>(context, listen: false);

    try {
      // Create a VitalSigns object
      final vitals = VitalSigns(
        bloodPressure: double.tryParse(_bpController.text.trim()),
        pulse: double.tryParse(_pulseController.text.trim()),
        temperature: double.tryParse(_tempController.text.trim()),
        spO2: double.tryParse(_spo2Controller.text.trim()),
      );

      // Update Firestore with the new vitals
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(widget.patientId)
          .update({
        'vitals': vitals.toMap(),
        'updatedAt': Timestamp.now(), // This stores the current time
      });

      // Update local cache in provider
      final idx = provider.patients.indexWhere((p) => p.id == widget.patientId);
      if (idx != -1) {
        final updated = provider.patients[idx].copyWith(vitals: vitals);
        provider.patients[idx] = updated;
        provider.notifyListeners();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vitals saved successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save vitals: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _bpController.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    _spo2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context);
    final patient = provider.patients.firstWhere(
          (p) => p.id == widget.patientId,
      orElse: () => PatientModel(
        id: '',
        name: 'Unknown',
        age: 0,
        gender: 'N/A',
        phone: '',
        address: '',
        emergencyLevel: 'Low',
        symptoms: '',
        photoUrl: null,
        vitals: VitalSigns(), // Ensure this is initialized as empty vitals
        reports: [],
        createdAt: Timestamp.now().toDate(),
        registrationTime: Timestamp.now().toDate(),
        status: '',
        priority: '', symptomChecks: {},
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Vital Signs',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient: ${patient.name}',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bpController,
                  decoration: const InputDecoration(labelText: 'BP (e.g. 120/80)'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pulseController,
                  decoration: const InputDecoration(labelText: 'Pulse (bpm)'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tempController,
                  decoration: const InputDecoration(labelText: 'Temperature (°F)'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _spo2Controller,
                  decoration: const InputDecoration(labelText: 'SpO₂ (%)'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveVitals,
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Vitals'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
