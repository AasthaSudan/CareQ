import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/patient_model.dart';
import '../models/vital_signs.dart';
import '../providers/patient_provider.dart';
import '../theme.dart';
import '../utils/priority_calculator.dart';
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
      bloodPressure: double.tryParse(_bpController.text.split('/').first ?? '0'),
      pulse: double.tryParse(_pulseController.text),
      temperature: double.tryParse(_tempController.text),
      spO2: double.tryParse(_spo2Controller.text),
    );

    setState(() {
      _calculatedPriority =
          PriorityCalculator.calculate(_symptomChecks, vitals);
    });
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
        emergencyLevel: _calculatedPriority,
        symptoms: _symptomsController.text,
        imageFile: _profileImage,
        symptomChecks: {},
      );

      if (patient != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Patient registered successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error registering patient: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF7C6FE8),
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'New Patient',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7C6FE8),
                      const Color(0xFF9B8AFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Photo Card
                    _buildProfilePhotoCard(),
                    const SizedBox(height: 24),

                    // Personal Information Card
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Personal Information', Icons.person_rounded),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.badge_rounded,
                            required: true,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _ageController,
                                  label: 'Age',
                                  icon: Icons.cake_rounded,
                                  keyboardType: TextInputType.number,
                                  required: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildGenderDropdown(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                            required: true,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _addressController,
                            label: 'Address',
                            icon: Icons.location_on_rounded,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Symptoms Card
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Symptoms & Complaints', Icons.medical_services_rounded),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _symptomsController,
                            label: 'Describe symptoms',
                            icon: Icons.edit_note_rounded,
                            maxLines: 4,
                            required: true,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Critical Symptoms',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSymptomChecks(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Vital Signs Card
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Vital Signs', Icons.monitor_heart_rounded),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildVitalCard(
                                  controller: _bpController,
                                  label: 'Blood Pressure',
                                  unit: 'mmHg',
                                  icon: Icons.favorite_rounded,
                                  color: const Color(0xFFE74C3C),
                                  hint: '120/80',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildVitalCard(
                                  controller: _pulseController,
                                  label: 'Pulse',
                                  unit: 'bpm',
                                  icon: Icons.monitor_heart_rounded,
                                  color: const Color(0xFF3498DB),
                                  onChanged: (_) => _calculatePriority(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildVitalCard(
                                  controller: _tempController,
                                  label: 'Temperature',
                                  unit: '°F',
                                  icon: Icons.thermostat_rounded,
                                  color: const Color(0xFFE67E22),
                                  onChanged: (_) => _calculatePriority(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildVitalCard(
                                  controller: _spo2Controller,
                                  label: 'SpO2',
                                  unit: '%',
                                  icon: Icons.air_rounded,
                                  color: const Color(0xFF27AE60),
                                  onChanged: (_) => _calculatePriority(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Priority Badge
                    _buildPriorityBadge(),
                    const SizedBox(height: 24),

                    // Register Button
                    _buildRegisterButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FE8).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProfilePhotoCard() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF7C6FE8).withOpacity(0.2),
                const Color(0xFF9B8AFF).withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C6FE8).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
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
                Icon(
                  Icons.add_a_photo_rounded,
                  size: 40,
                  color: const Color(0xFF7C6FE8),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7C6FE8),
                  ),
                ),
              ],
            )
                : null,
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
            gradient: LinearGradient(
              colors: [
                const Color(0xFF7C6FE8).withOpacity(0.2),
                const Color(0xFF9B8AFF).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF7C6FE8), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
      ],
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15),
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        labelStyle: GoogleFonts.poppins(
          color: const Color(0xFF7C6FE8),
          fontSize: 14,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF7C6FE8).withOpacity(0.15),
                const Color(0xFF9B8AFF).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF7C6FE8), size: 20),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF7C6FE8), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: required ? (v) => v!.isEmpty ? 'This field is required' : null : null,
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: _gender,
        style: GoogleFonts.poppins(fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
          labelText: 'Gender',
          labelStyle: GoogleFonts.poppins(
            color: const Color(0xFF7C6FE8),
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C6FE8).withOpacity(0.15),
                  const Color(0xFF9B8AFF).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.wc_rounded, color: Color(0xFF7C6FE8), size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: ['Male', 'Female', 'Other']
            .map((g) => DropdownMenuItem(
          value: g,
          child: Text(g),
        ))
            .toList(),
        onChanged: (v) => setState(() => _gender = v!),
      ),
    );
  }

  Widget _buildSymptomChecks() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _symptomChecks.keys.map((key) {
        final isSelected = _symptomChecks[key]!;
        return InkWell(
          onTap: () {
            setState(() {
              _symptomChecks[key] = !isSelected;
              _calculatePriority();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [
                  const Color(0xFFE74C3C),
                  const Color(0xFFC0392B),
                ],
              )
                  : null,
              color: isSelected ? null : const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFFE74C3C) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  _getSymptomLabel(key),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVitalCard({
    required TextEditingController controller,
    required String label,
    required String unit,
    required IconData icon,
    required Color color,
    String? hint,
    Function(String)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
              suffixText: unit,
              suffixStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PriorityCalculator.getColor(_calculatedPriority),
            PriorityCalculator.getColor(_calculatedPriority).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PriorityCalculator.getColor(_calculatedPriority).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Priority Level',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _calculatedPriority.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7C6FE8),
            Color(0xFF9B8AFF),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FE8).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _registerPatient,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Register Patient',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
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