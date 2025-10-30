// lib/screens/register_patient_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_provider.dart';
import 'vital_signs_screen.dart';

class RegisterPatientScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterPatientScreen({Key? key}) : super(key: key);

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _symptoms = TextEditingController();
  String _gender = 'Male';
  String _emergency = 'Low';
  bool _saving = false;

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = Provider.of<PatientProvider>(context, listen: false);

    final patient = await provider.registerPatient(
      name: _name.text.trim(),
      gender: _gender,
      age: int.tryParse(_age.text.trim()),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      symptoms: _symptoms.text.trim().isEmpty ? null : _symptoms.text.trim(),
      emergencyLevel: _emergency,
    );

    setState(() => _saving = false);

    if (patient != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient registered successfully')),
      );
      // Navigate to vitals and pass patient id
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VitalSignsScreen(patientId: patient.id)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to register patient')),
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _phone.dispose();
    _address.dispose();
    _symptoms.dispose();
    super.dispose();
  }

  Widget _field({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register New Patient', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Personal Information', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              _field(child: TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(child: TextFormField(controller: _age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null))),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      items: ['Male', 'Female', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                      decoration: const InputDecoration(labelText: 'Gender'),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              _field(child: TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone'))),
              const SizedBox(height: 12),
              _field(child: TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Address'), maxLines: 3)),
              const SizedBox(height: 12),
              _field(child: TextFormField(controller: _symptoms, decoration: const InputDecoration(labelText: 'Symptoms'), maxLines: 3)),
              const SizedBox(height: 12),
              _field(
                child: DropdownButtonFormField<String>(
                  value: _emergency,
                  items: ['Low', 'Medium', 'High'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _emergency = v ?? 'Low'),
                  decoration: const InputDecoration(labelText: 'Emergency Level'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _onNext,
                  child: _saving ? const CircularProgressIndicator(color: Colors.white) : Text('Next: Vital Signs', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
