import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/patient_model.dart';
import '../models/vital_signs.dart';
import '../providers/patient_provider.dart';
import '../utils/priority_calculator.dart';

class RegisterPatientScreen extends StatefulWidget {
  @override
  _RegisterPatientScreenState createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
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
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final ValueNotifier<String> _priorityNotifier = ValueNotifier('stable');
  final ValueNotifier<Map<String, bool>> _symptomNotifier = ValueNotifier({
    'chest_pain': false,
    'difficulty_breathing': false,
    'severe_bleeding': false,
    'unconscious': false,
    'high_fever': false,
    'severe_pain': false,
  });

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
    _priorityNotifier.dispose();
    _symptomNotifier.dispose();
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
    if (_pulseController.text.isEmpty || _tempController.text.isEmpty || _spo2Controller.text.isEmpty) return;

    // Fixed: Better blood pressure parsing
    double? bloodPressure;
    if (_bpController.text.isNotEmpty && _bpController.text.contains('/')) {
      final parts = _bpController.text.split('/');
      bloodPressure = double.tryParse(parts[0].trim());
    }

    final vitals = VitalSigns(
      bloodPressure: bloodPressure,
      pulse: double.tryParse(_pulseController.text),
      temperature: double.tryParse(_tempController.text),
      spO2: double.tryParse(_spo2Controller.text),
    );

    final newPriority = PriorityCalculator.calculate(_symptomNotifier.value, vitals);

    if (_priorityNotifier.value != newPriority) {
      _priorityNotifier.value = newPriority;
    }
  }

  void _registerPatient() async {
    // Validate form first
    if (_formKey.currentState?.validate() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    // Validate vital signs
    if (_pulseController.text.isEmpty || _tempController.text.isEmpty || _spo2Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all vital signs (Pulse, Temperature, SpO2)'),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    final provider = Provider.of<PatientProvider>(context, listen: false);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF7C6FE8)),
              SizedBox(height: 16),
              Text('Registering patient...'),
            ],
          ),
        ),
      ),
    );

    try {
      // Parse blood pressure
      double? bloodPressure;
      if (_bpController.text.isNotEmpty && _bpController.text.contains('/')) {
        final parts = _bpController.text.split('/');
        bloodPressure = double.tryParse(parts[0].trim());
      }

      // Create vital signs
      final vitals = VitalSigns(
        bloodPressure: bloodPressure,
        pulse: double.tryParse(_pulseController.text),
        temperature: double.tryParse(_tempController.text),
        spO2: double.tryParse(_spo2Controller.text),
      );

      print('Attempting to register patient: ${_nameController.text}');
      print('Priority: ${_priorityNotifier.value}');
      print('Vitals: BP=$bloodPressure, Pulse=${vitals.pulse}, Temp=${vitals.temperature}, SpO2=${vitals.spO2}');

      final patient = await provider.registerPatient(
        name: _nameController.text.trim(),
        gender: _gender,
        age: int.parse(_ageController.text),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        emergencyLevel: _priorityNotifier.value,
        symptoms: _symptomsController.text.trim(),
        imageFile: _profileImage,
        symptomChecks: _symptomNotifier.value,
        vitals: vitals, // Pass vital signs
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (patient != null) {
        print('Patient registered successfully: ${patient.id}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${patient.name} registered successfully!')),
                ],
              ),
              backgroundColor: const Color(0xFF7C6FE8),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              duration: const Duration(seconds: 3),
            ),
          );

          // Refresh the patient list
          await provider.refreshQueue();

          // Go back to previous screen
          Navigator.pop(context);
        }
      } else {
        print('Patient registration returned null');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to register patient. Please try again.'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error registering patient: $e');
      print('Stack trace: $stackTrace');

      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic screen size
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(width * 0.02),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back_ios_rounded, size: width * 0.045, color: Color(0xFF7C6FE8)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Patient Registration',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: width * 0.055, color: const Color(0xFF2C3E50)),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
          children: [
            _buildProfilePhotoCard(width),
            SizedBox(height: height * 0.03),
            _buildPersonalInfoSection(width),
            SizedBox(height: height * 0.03),
            _buildSymptomsSection(width),
            SizedBox(height: height * 0.03),
            _buildVitalsSection(width),
            SizedBox(height: height * 0.03),
            _buildPriorityBadge(width),
            SizedBox(height: height * 0.03),
            _buildRegisterButton(width, height),
            SizedBox(height: height * 0.03),
          ],
        ),
      ),
    );
  }

  // ------------------ WIDGETS ------------------

  Widget _buildProfilePhotoCard(double width) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: AnimatedScale(
          scale: _profileImage != null ? 1.0 : 1.02,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: width * 0.32,
            height: width * 0.32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF7C6FE8), Color(0xFF9B8AFF)]),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C6FE8).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Container(
              margin: EdgeInsets.all(width * 0.007),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: _profileImage != null
                    ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                    : null,
              ),
              child: _profileImage == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, size: width * 0.09, color: Color(0xFF7C6FE8)),
                  SizedBox(height: width * 0.02),
                  Text('Add Photo',
                      style: GoogleFonts.poppins(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7C6FE8))),
                ],
              )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, double width) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(width * 0.025),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7C6FE8).withOpacity(0.15), Color(0xFF9B8AFF).withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Color(0xFF7C6FE8), size: width * 0.05),
        ),
        SizedBox(width: width * 0.03),
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: width * 0.045, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
      ],
    );
  }

  // ---------------- PERSONAL INFO ----------------
  Widget _buildPersonalInfoSection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Information', Icons.person_rounded, width),
        SizedBox(height: width * 0.03),
        _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person_outline, required: true, width: width),
        SizedBox(height: width * 0.03),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                  controller: _ageController,
                  label: 'Age',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  required: true,
                  width: width),
            ),
            SizedBox(width: width * 0.03),
            Expanded(child: _buildGenderDropdown(width)),
          ],
        ),
        SizedBox(height: width * 0.03),
        _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            required: true,
            width: width),
        SizedBox(height: width * 0.03),
        _buildTextField(
            controller: _addressController,
            label: 'Address',
            icon: Icons.location_on_outlined,
            maxLines: 2,
            width: width),
      ],
    );
  }

  // ---------------- SYMPTOMS ----------------
  Widget _buildSymptomsSection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Symptoms & Complaints', Icons.medical_services_rounded, width),
        SizedBox(height: width * 0.03),
        _buildTextField(
            controller: _symptomsController,
            label: 'Describe symptoms',
            icon: Icons.note_outlined,
            maxLines: 3,
            required: true,
            width: width),
        SizedBox(height: width * 0.03),
        Text('Critical Symptoms',
            style: GoogleFonts.poppins(
                fontSize: width * 0.035, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
        SizedBox(height: width * 0.03),
        ValueListenableBuilder<Map<String, bool>>(
          valueListenable: _symptomNotifier,
          builder: (context, symptoms, _) {
            return Wrap(
              spacing: width * 0.02,
              runSpacing: width * 0.02,
              children: symptoms.keys.map((key) {
                final isSelected = symptoms[key]!;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(horizontal: width * 0.035, vertical: width * 0.025),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF7C6FE8) : Color(0xFFFAFBFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isSelected ? Color(0xFF7C6FE8) : Color(0xFFE8E8F0), width: 1.5),
                  ),
                  child: InkWell(
                    onTap: () {
                      symptoms[key] = !isSelected;
                      _symptomNotifier.value = Map.from(symptoms);
                      _calculatePriority();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isSelected ? Icons.check_circle : Icons.circle_outlined,
                            size: width * 0.04, color: isSelected ? Colors.white : Color(0xFF9B8AFF)),
                        SizedBox(width: width * 0.02),
                        Text(_getSymptomLabel(key),
                            style: GoogleFonts.poppins(
                                fontSize: width * 0.035,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : Color(0xFF2C3E50))),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVitalsSection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Vital Signs', Icons.monitor_heart_rounded, width),
        SizedBox(height: width * 0.03),
        Row(
          children: [
            Expanded(
              child: _buildVitalCard(
                  controller: _bpController,
                  label: 'Blood Pressure',
                  icon: Icons.favorite_outline,
                  color: Color(0xFFFF6B9D),
                  hint: '120/80',
                  width: width),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: _buildVitalCard(
                  controller: _pulseController,
                  label: 'Pulse',
                  icon: Icons.monitor_heart_outlined,
                  color: Color(0xFF4ECDC4),
                  hint: 'bpm',
                  onChanged: (_) => _calculatePriority(),
                  width: width),
            ),
          ],
        ),
        SizedBox(height: width * 0.025),
        Row(
          children: [
            Expanded(
              child: _buildVitalCard(
                  controller: _tempController,
                  label: 'Temperature',
                  icon: Icons.thermostat_outlined,
                  color: Color(0xFFFFA07A),
                  hint: '°F',
                  onChanged: (_) => _calculatePriority(),
                  width: width),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: _buildVitalCard(
                  controller: _spo2Controller,
                  label: 'SpO2',
                  icon: Icons.air,
                  color: Color(0xFF95E1D3),
                  hint: '%',
                  onChanged: (_) => _calculatePriority(),
                  width: width),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(double width) {
    return Center(
      child: ValueListenableBuilder<String>(
        valueListenable: _priorityNotifier,
        builder: (context, priority, _) => AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [PriorityCalculator.getColor(priority), PriorityCalculator.getColor(priority).withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: PriorityCalculator.getColor(priority).withOpacity(0.3),
                  blurRadius: 16,
                  offset: Offset(0, 6))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                  child: Icon(Icons.local_hospital_rounded, color: Colors.white, size: width * 0.06)),
              SizedBox(width: width * 0.04),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Priority Level',
                      style: GoogleFonts.poppins(
                          fontSize: width * 0.035,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9))),
                  Text(priority.toUpperCase(),
                      style: GoogleFonts.poppins(
                          fontSize: width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(double width, double height) {
    return SizedBox(
      width: double.infinity,
      height: height * 0.065,
      child: ElevatedButton(
        onPressed: _registerPatient,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C6FE8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          shadowColor: const Color(0xFF7C6FE8).withOpacity(0.4),
        ),
        child: Text('Register Patient',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: width * 0.045, color: Colors.white)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = false,
    String? hint,
    required double width,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: required
          ? (value) {
        if (value == null || value.trim().isEmpty) return 'Please enter $label';
        return null;
      }
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Color(0xFF7C6FE8)),
        filled: true,
        fillColor: Color(0xFFF5F3FF),
        contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: width * 0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildGenderDropdown(double width) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
      decoration: BoxDecoration(
        color: Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _gender,
        decoration: const InputDecoration(border: InputBorder.none),
        items: ['Male', 'Female', 'Other']
            .map((g) => DropdownMenuItem(value: g, child: Text(g, style: GoogleFonts.poppins())))
            .toList(),
        onChanged: (val) => setState(() => _gender = val!),
      ),
    );
  }

  Widget _buildVitalCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    String? hint,
    Function(String)? onChanged,
    required double width,
  }) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: width * 0.06),
          SizedBox(height: width * 0.02),
          Text(label, style: GoogleFonts.poppins(fontSize: width * 0.035, fontWeight: FontWeight.w500)),
          SizedBox(height: width * 0.015),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: width * 0.03),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  String _getSymptomLabel(String key) {
    switch (key) {
      case 'chest_pain':
        return 'Chest Pain';
      case 'difficulty_breathing':
        return 'Difficulty Breathing';
      case 'severe_bleeding':
        return 'Severe Bleeding';
      case 'unconscious':
        return 'Unconscious';
      case 'high_fever':
        return 'High Fever';
      case 'severe_pain':
        return 'Severe Pain';
      default:
        return key;
    }
  }
}