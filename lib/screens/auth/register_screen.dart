import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../providers/patient_provider.dart';
import '../vital_signs_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPatientScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterPatientScreen({Key? key}) : super(key: key);

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _symptoms = TextEditingController();
  String _gender = 'Male';
  String _emergency = 'Low';
  File? _photo;
  bool _saving = false;

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final prov = Provider.of<PatientProvider>(context, listen: false);
    final p = await prov.registerPatient(
      name: _name.text.trim(),
      gender: _gender,
      age: int.parse(_age.text.trim()),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      symptoms: _symptoms.text.trim(),
      emergencyLevel: _emergency,
      imageFile: _photo,
    );
    setState(() => _saving = false);
    if (p != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient registered')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VitalSignsScreen(patientId: p.id)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to register')));
    }
  }

  @override
  void dispose() {
    _name.dispose(); _age.dispose(); _phone.dispose(); _address.dispose(); _symptoms.dispose();
    super.dispose();
  }

  Widget _card({required Widget child}) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: child);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Patient Registration', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  GestureDetector(onTap: _pickPhoto, child: CircleAvatar(radius: 36, backgroundColor: Colors.grey[200], backgroundImage: _photo != null ? FileImage(_photo!) : null, child: _photo == null ? const Icon(Icons.camera_alt, color: Colors.grey) : null)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextFormField(controller: _age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: DropdownButtonFormField<String>(value: _gender, items: ['Male', 'Female', 'Other'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v)=>setState(()=>_gender=v!), decoration: const InputDecoration(labelText: 'Gender'))),
                ]),
                const SizedBox(height: 12),
                TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Contact Number'), validator: (v)=>v==null||v.isEmpty?'Required':null),
                const SizedBox(height: 12),
                TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Address'), maxLines: 3),
              ])),
              const SizedBox(height: 12),
              _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Chief Complaint', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(controller: _symptoms, decoration: const InputDecoration(labelText: 'Symptoms'), maxLines: 4),
              ])),
              const SizedBox(height: 12),
              _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Vital Signs', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'BP (120/80)'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Pulse (bpm)'))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Temp (°F)'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'SpO2 (%)'))),
                ]),
              ])),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: _saving ? null : _submit, child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Register Patient'))),
            ]),
          ),
        ),
      ),
    );
  }
}
