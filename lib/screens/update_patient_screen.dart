import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/patient_model.dart';
import '../models/vital_signs.dart';
import '../providers/patient_provider.dart';
import '../theme.dart';
import '../utils/priority_calculator.dart';
import 'package:intl/intl.dart';

class UpdatePatientScreen extends StatefulWidget {
  final PatientModel patient;

  const UpdatePatientScreen({required this.patient});

  @override
  _UpdatePatientScreenState createState() => _UpdatePatientScreenState();
}

class _UpdatePatientScreenState extends State<UpdatePatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _symptomsController;
  late TextEditingController _bpController;
  late TextEditingController _pulseController;
  late TextEditingController _tempController;
  late TextEditingController _spo2Controller;

  String _calculatedPriority = 'stable';
  late Map<String, bool> _symptomChecks;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.patient.phone);
    _addressController = TextEditingController(text: widget.patient.address);
    _symptomsController = TextEditingController(text: widget.patient.symptoms);
    _bpController = TextEditingController(text: widget.patient.vitals.bloodPressure?.toString() ?? '');
    _pulseController = TextEditingController(text: widget.patient.vitals.pulse.toString());
    _tempController = TextEditingController(text: widget.patient.vitals.temperature.toString());
    _spo2Controller = TextEditingController(text: widget.patient.vitals.spO2.toString());

    _symptomChecks = Map<String, bool>.from(widget.patient.symptomChecks);
    _calculatedPriority = widget.patient.emergencyLevel;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _symptomsController.dispose();
    _bpController.dispose();
    _pulseController.dispose();
    _tempController.dispose();
    _spo2Controller.dispose();
    super.dispose();
  }

  void _calculatePriority() {
    if (_pulseController.text.isEmpty ||
        _tempController.text.isEmpty ||
        _spo2Controller.text.isEmpty) {
      return;
    }

    final vitals = VitalSigns(
      bloodPressure: _bpController.text.isNotEmpty
          ? double.tryParse(_bpController.text)
          : null,
      pulse: _pulseController.text.isNotEmpty
          ? double.tryParse(_pulseController.text)
          : null,
      temperature: _tempController.text.isNotEmpty
          ? double.tryParse(_tempController.text)
          : null,
      spO2: _spo2Controller.text.isNotEmpty
          ? double.tryParse(_spo2Controller.text)
          : null,
    );

    setState(() {
      _calculatedPriority = PriorityCalculator.calculate(_symptomChecks, vitals);
    });
  }

  void _updatePatient() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<PatientProvider>(context, listen: false);

    await provider.updatePatient(widget.patient.id, {
      'phone': _phoneController.text,
      'address': _addressController.text,
      'symptoms': _symptomsController.text,
      'emergencyLevel': _calculatedPriority,
      'symptomChecks': _symptomChecks,
      'vitals': {
        'bloodPressure': _bpController.text,
        'pulse': int.parse(_pulseController.text),
        'temperature': double.parse(_tempController.text),
        'spO2': int.parse(_spo2Controller.text),
      },
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Patient information updated successfully!'),
        backgroundColor: const Color(0xFF7C6FE8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _uploadReport() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report uploaded successfully!'),
            backgroundColor: const Color(0xFF7C6FE8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to upload the report'),
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
          'Update Patient Info',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: const Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_rounded, size: 20, color: Color(0xFF7C6FE8)),
            ),
            onPressed: _updatePatient,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C6FE8), Color(0xFF9B8AFF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C6FE8).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: widget.patient.photoUrl != null
                              ? DecorationImage(
                            image: NetworkImage(widget.patient.photoUrl!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: widget.patient.photoUrl == null
                            ? const Icon(Icons.person, size: 35, color: Color(0xFF7C6FE8))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patient.name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${widget.patient.id}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'Age: ${widget.patient.age} • ${widget.patient.gender}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Contact Information
              _buildSectionTitle('Contact Information'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                required: true,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 28),

              // Symptoms Update
              _buildSectionTitle('Symptoms & Complaints'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _symptomsController,
                label: 'Symptoms',
                icon: Icons.note_outlined,
                maxLines: 3,
                required: true,
              ),
              const SizedBox(height: 18),
              Text(
                'Critical Symptoms',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              _buildSymptomChecks(),
              const SizedBox(height: 28),

              // Vital Signs Update
              _buildSectionTitle('Vital Signs'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildVitalCard(
                      controller: _bpController,
                      label: 'Blood Pressure',
                      icon: Icons.favorite_outline,
                      color: const Color(0xFFFF6B9D),
                      hint: '120/80',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVitalCard(
                      controller: _pulseController,
                      label: 'Pulse',
                      icon: Icons.monitor_heart_outlined,
                      color: const Color(0xFF4ECDC4),
                      hint: 'bpm',
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
                      icon: Icons.thermostat_outlined,
                      color: const Color(0xFFFFA07A),
                      hint: '°F',
                      onChanged: (_) => _calculatePriority(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVitalCard(
                      controller: _spo2Controller,
                      label: 'SpO2',
                      icon: Icons.air,
                      color: const Color(0xFF95E1D3),
                      hint: '%',
                      onChanged: (_) => _calculatePriority(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Updated Priority Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PriorityCalculator.getColor(_calculatedPriority),
                      PriorityCalculator.getColor(_calculatedPriority).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: PriorityCalculator.getColor(_calculatedPriority).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
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
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Updated Priority',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          _calculatedPriority.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Upload Report Button
              _buildActionButton(
                onPressed: _uploadReport,
                icon: Icons.upload_file_rounded,
                label: 'Upload Previous Report',
                color: const Color(0xFF4ECDC4),
              ),
              const SizedBox(height: 16),

              // Save Changes Button
              _buildActionButton(
                onPressed: _updatePatient,
                icon: Icons.check_circle_rounded,
                label: 'Save Changes',
                color: const Color(0xFF7C6FE8),
                isGradient: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF7C6FE8).withOpacity(0.15),
                const Color(0xFF9B8AFF).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getSectionIcon(title),
            color: const Color(0xFF7C6FE8),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  IconData _getSectionIcon(String title) {
    if (title.contains('Contact')) return Icons.phone_rounded;
    if (title.contains('Symptoms')) return Icons.medical_services_rounded;
    if (title.contains('Vital')) return Icons.monitor_heart_rounded;
    return Icons.info_rounded;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF2C3E50)),
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
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
        fillColor: const Color(0xFFFAFBFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFFE8E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7C6FE8), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      validator: required ? (v) => v!.isEmpty ? 'Required' : null : null,
    );
  }

  Widget _buildSymptomChecks() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF7C6FE8) : const Color(0xFFFAFBFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF7C6FE8) : const Color(0xFFE8E8F0),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: isSelected ? Colors.white : const Color(0xFF9B8AFF),
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
        borderRadius: BorderRadius.circular(14),
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
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
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
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isGradient = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isGradient
            ? LinearGradient(
          colors: [
            const Color(0xFF7C6FE8),
            const Color(0xFF9B8AFF),
          ],
        )
            : null,
        color: isGradient ? null : color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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