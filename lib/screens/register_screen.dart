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

class _RegisterPatientScreenState extends State<RegisterPatientScreen> with SingleTickerProviderStateMixin {
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

  late AnimationController _priorityController;
  late Animation<double> _priorityScale;

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
  void initState() {
    super.initState();
    _priorityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 1.0,
      upperBound: 1.05,
    );
    _priorityScale = CurvedAnimation(parent: _priorityController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _priorityController.dispose();
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

    final vitals = VitalSigns(
      bloodPressure: double.tryParse(_bpController.text.split('/').first ?? '0'),
      pulse: double.tryParse(_pulseController.text),
      temperature: double.tryParse(_tempController.text),
      spO2: double.tryParse(_spo2Controller.text),
    );

    final newPriority = PriorityCalculator.calculate(_symptomNotifier.value, vitals);

    if (_priorityNotifier.value != newPriority) {
      _priorityNotifier.value = newPriority;
      _priorityController.forward(from: 0);
    }
  }

  void _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<PatientProvider>(context, listen: false);

    try {
      final patient = await provider.registerPatient(
        name: _nameController.text,
        gender: _gender,
        age: int.parse(_ageController.text),
        phone: _phoneController.text,
        address: _addressController.text,
        emergencyLevel: _priorityNotifier.value,
        symptoms: _symptomsController.text,
        imageFile: _profileImage,
        symptomChecks: _symptomNotifier.value,
      );

      if (patient != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Patient registered successfully!'),
            backgroundColor: const Color(0xFF7C6FE8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error registering patient: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Color(0xFF7C6FE8)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Patient Registration',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF2C3E50)),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfilePhotoCard(),
          const SizedBox(height: 28),
          _buildPersonalInfoSection(),
          const SizedBox(height: 28),
          _buildSymptomsSection(),
          const SizedBox(height: 28),
          _buildVitalsSection(),
          const SizedBox(height: 28),
          _buildPriorityBadge(),
          const SizedBox(height: 24),
          _buildRegisterButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoCard() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: AnimatedScale(
          scale: _profileImage != null ? 1.0 : 1.02,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF7C6FE8), Color(0xFF9B8AFF)]),
              boxShadow: [BoxShadow(color: const Color(0xFF7C6FE8).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: _profileImage != null ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover) : null,
              ),
              child: _profileImage == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_rounded, size: 36, color: Color(0xFF7C6FE8)),
                  const SizedBox(height: 8),
                  Text('Add Photo', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF7C6FE8))),
                ],
              )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF7C6FE8).withOpacity(0.15), const Color(0xFF9B8AFF).withOpacity(0.1)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF7C6FE8), size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50))),
      ],
    );
  }

  // --- Personal Info Section ---
  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Information', Icons.person_rounded),
        const SizedBox(height: 16),
        _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person_outline, required: true),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildTextField(controller: _ageController, label: 'Age', icon: Icons.cake_outlined, keyboardType: TextInputType.number, required: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildGenderDropdown()),
          ],
        ),
        const SizedBox(height: 14),
        _buildTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, required: true),
        const SizedBox(height: 14),
        _buildTextField(controller: _addressController, label: 'Address', icon: Icons.location_on_outlined, maxLines: 2),
      ],
    );
  }

  // --- Symptoms Section ---
  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Symptoms & Complaints', Icons.medical_services_rounded),
        const SizedBox(height: 16),
        _buildTextField(controller: _symptomsController, label: 'Describe symptoms', icon: Icons.note_outlined, maxLines: 3, required: true),
        const SizedBox(height: 16),
        Text('Critical Symptoms', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2C3E50))),
        const SizedBox(height: 12),
        ValueListenableBuilder<Map<String,bool>>(
          valueListenable: _symptomNotifier,
          builder: (context, symptoms, _) {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: symptoms.keys.map((key) {
                final isSelected = symptoms[key]!;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7C6FE8) : const Color(0xFFFAFBFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? const Color(0xFF7C6FE8) : const Color(0xFFE8E8F0), width: 1.5),
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
                        Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, size: 16, color: isSelected ? Colors.white : const Color(0xFF9B8AFF)),
                        const SizedBox(width: 8),
                        Text(_getSymptomLabel(key), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF2C3E50))),
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

  // --- Vitals Section ---
  Widget _buildVitalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Vital Signs', Icons.monitor_heart_rounded),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildVitalCard(controller: _bpController, label: 'Blood Pressure', icon: Icons.favorite_outline, color: const Color(0xFFFF6B9D), hint: '120/80')),
            const SizedBox(width: 12),
            Expanded(child: _buildVitalCard(controller: _pulseController, label: 'Pulse', icon: Icons.monitor_heart_outlined, color: const Color(0xFF4ECDC4), hint: 'bpm', onChanged: (_) => _calculatePriority())),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildVitalCard(controller: _tempController, label: 'Temperature', icon: Icons.thermostat_outlined, color: const Color(0xFFFFA07A), hint: '°F', onChanged: (_) => _calculatePriority())),
            const SizedBox(width: 12),
            Expanded(child: _buildVitalCard(controller: _spo2Controller, label: 'SpO2', icon: Icons.air, color: const Color(0xFF95E1D3), hint: '%', onChanged: (_) => _calculatePriority())),
          ],
        ),
      ],
    );
  }

  // --- Shared Widgets ---
  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType, int maxLines = 1, bool required = false, String? hint}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF2C3E50)),
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        labelStyle: GoogleFonts.poppins(color: const Color(0xFF7C6FE8), fontSize: 14),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF7C6FE8).withOpacity(0.15), const Color(0xFF9B8AFF).withOpacity(0.1)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF7C6FE8), size: 20),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFBFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: const Color(0xFFE8E8F0), width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF7C6FE8), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      validator: required ? (v) => v!.isEmpty ? 'Required' : null : null,
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFFAFBFF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8E8F0), width: 1)),
      child: DropdownButtonFormField<String>(
        value: _gender,
        style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF2C3E50)),
        decoration: InputDecoration(
          labelText: 'Gender',
          labelStyle: GoogleFonts.poppins(color: const Color(0xFF7C6FE8), fontSize: 14),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [const Color(0xFF7C6FE8).withOpacity(0.15), const Color(0xFF9B8AFF).withOpacity(0.1)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.wc_rounded, color: Color(0xFF7C6FE8), size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
        onChanged: (v) => setState(() => _gender = v!),
      ),
    );
  }

  Widget _buildVitalCard({required TextEditingController controller, required String label, required IconData icon, required Color color, String? hint, Function(String)? onChanged}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
              const SizedBox(width: 10),
              Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0)),
            style: GoogleFonts.poppins(fontSize: 15, color: Color(0xFF2C3E50)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    return Center(
      child: ValueListenableBuilder<String>(
        valueListenable: _priorityNotifier,
        builder: (context, priority, _) => Transform.scale(
          scale: _priorityScale.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [PriorityCalculator.getColor(priority), PriorityCalculator.getColor(priority).withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: PriorityCalculator.getColor(priority).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle), child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Priority Level', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.9))),
                    Text(priority.toUpperCase(), style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _registerPatient,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C6FE8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          shadowColor: const Color(0xFF7C6FE8).withOpacity(0.4),
        ),
        child: Text('Register Patient', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
      ),
    );
  }

  String _getSymptomLabel(String key) {
    switch (key) {
      case 'chest_pain': return 'Chest Pain';
      case 'difficulty_breathing': return 'Difficulty Breathing';
      case 'severe_bleeding': return 'Severe Bleeding';
      case 'unconscious': return 'Unconscious';
      case 'high_fever': return 'High Fever';
      case 'severe_pain': return 'Severe Pain';
      default: return key;
    }
  }
}
