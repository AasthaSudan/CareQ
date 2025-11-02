import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/patient_model.dart';
import '../../models/vital_signs.dart';
import '../../providers/patient_provider.dart';
import '../../theme.dart';
import '../../utils/priority_calculator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterPatientScreen extends StatefulWidget {
  @override
  _RegisterPatientScreenState createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _bpController = TextEditingController();
  final _pulseController = TextEditingController();
  final _tempController = TextEditingController();
  final _spo2Controller = TextEditingController();

  String _gender = 'Male';
  String _calculatedPriority = 'stable';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Map<String, bool> _symptomChecks = {
    'chest_pain': false,
    'difficulty_breathing': false,
    'severe_bleeding': false,
    'unconscious': false,
    'high_fever': false,
    'severe_pain': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _symptomsController.dispose();
    _bpController.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    _spo2Controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _calculatePriority() {
    if (_pulseController.text.isEmpty ||
        _tempController.text.isEmpty ||
        _spo2Controller.text.isEmpty) {
      return;
    }

    final vitals = VitalSigns(
      bloodPressure: _bpController.text,
      pulse: int.tryParse(_pulseController.text) ?? 0,
      temperature: double.tryParse(_tempController.text) ?? 0,
      spO2: int.tryParse(_spo2Controller.text) ?? 0,
    );

    setState(() {
      _calculatedPriority =
          PriorityCalculator.calculate(_symptomChecks, vitals);
    });
  }

  void _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<PatientProvider>(context, listen: false);
    final patientId = 'PT-${DateTime.now().millisecondsSinceEpoch}';

    // TODO: Upload image to Firebase Storage and get URL
    String? photoUrl;
    if (_profileImage != null) {
      // photoUrl = await uploadImageToFirebase(_profileImage!);
      photoUrl = _profileImage!.path; // Temporary - use local path
    }

    final patient = PatientModel(
      id: patientId,
      name: _nameController.text,
      age: int.parse(_ageController.text),
      gender: _gender,
      phone: _phoneController.text,
      address: _addressController.text,
      symptoms: _symptomsController.text,
      emergencyLevel: _calculatedPriority,
      symptomChecks: _symptomChecks,
      vitals: VitalSigns(
        bloodPressure: _bpController.text,
        pulse: int.parse(_pulseController.text),
        temperature: double.parse(_tempController.text),
        spO2: int.parse(_spo2Controller.text),
      ),
      registrationTime: DateTime.now(),
      photoUrl: photoUrl,
    );

    await provider.registerPatient(patient);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Patient registered successfully!'),
        backgroundColor: AppTheme.stable,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'New Patient Registration',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: AppTheme.primaryPurple, width: 3),
                      image: _profileImage != null
                          ? DecorationImage(
                        image: FileImage(_profileImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _profileImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                        Text('Add Photo',
                            style: GoogleFonts.inter(fontSize: 12)),
                      ],
                    )
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Personal Information
              _buildSectionTitle('Personal Information'),
              SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Full Name *', Icons.person),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Age *', Icons.calendar_today),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _buildInputDecoration('Gender', Icons.wc),
                      items: ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration('Phone Number *', Icons.phone),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: _buildInputDecoration('Address', Icons.home),
              ),
              SizedBox(height: 24),

              // Symptoms
              _buildSectionTitle('Symptoms & Complaints'),
              SizedBox(height: 12),
              TextFormField(
                controller: _symptomsController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                    'Describe symptoms *', Icons.medical_services),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              Text('Critical Symptoms:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ..._symptomChecks.keys.map((key) {
                return CheckboxListTile(
                  title: Text(_getSymptomLabel(key)),
                  value: _symptomChecks[key],
                  activeColor: AppTheme.critical,
                  onChanged: (value) {
                    setState(() {
                      _symptomChecks[key] = value!;
                      _calculatePriority();
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
              SizedBox(height: 24),

              // Vital Signs
              _buildSectionTitle('Vital Signs'),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bpController,
                      decoration: _buildInputDecoration('BP (120/80)', Icons.favorite),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _pulseController,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Pulse (bpm)', Icons.monitor_heart),
                      onChanged: (_) => _calculatePriority(),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tempController,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Temp (°F)', Icons.thermostat),
                      onChanged: (_) => _calculatePriority(),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _spo2Controller,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('SpO2 (%)', Icons.air),
                      onChanged: (_) => _calculatePriority(),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Priority Badge
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PriorityCalculator.getColor(_calculatedPriority),
                      PriorityCalculator.getColor(_calculatedPriority)
                          .withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_hospital_rounded, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Text(
                      'Priority: ${_calculatedPriority.toUpperCase()}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _registerPatient,
                  icon: Icon(Icons.person_add_rounded, color: Colors.white),
                  label: Text('Register Patient',
                      style: GoogleFonts.inter(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryPurple,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.primaryPurple),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
      ),
    );
  }

  String _getSymptomLabel(String key) {
    final labels = {
      'chest_pain': 'Chest Pain',
      'difficulty_breathing': 'Difficulty Breathing',
      'severe_bleeding': 'Severe Bleeding',
      'unconscious': 'Unconscious',
      'high_fever': 'High Fever',
      'severe_pain': 'Severe Pain',
    };
    return labels[key] ?? key;
  }
}
