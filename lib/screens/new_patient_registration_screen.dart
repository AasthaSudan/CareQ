// lib/screens/new_patient_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/patient_model.dart';
import '../providers/patient_provider.dart';
import 'symptoms_recorder_screen.dart';

class NewPatientRegistrationScreen extends StatefulWidget {
  const NewPatientRegistrationScreen({super.key});

  @override
  State<NewPatientRegistrationScreen> createState() =>
      _NewPatientRegistrationScreenState();
}

class _NewPatientRegistrationScreenState
    extends State<NewPatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController =
  TextEditingController();

  String _gender = 'Male';
  String? _patientId;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: PremiumTheme.backgroundLight,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildPage1(),
                    _buildPage2(),
                    _buildPage3(),
                  ],
                ),
              ),
              _buildContinueButton(() => _handleContinue(patientProvider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentPage > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const Expanded(
            child: Text(
              'New Patient Registration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? PremiumTheme.primaryPurple
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPage1() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageTitle('Personal', 'Information'),
        const SizedBox(height: 40),
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Please enter patient name';
            }
            if (v.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final age = int.tryParse(v);
                  if (age == null || age < 0 || age > 150) {
                    return 'Invalid age';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: const Icon(Icons.wc),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value!),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildPage2() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageTitle('Contact', 'Details'),
        const SizedBox(height: 40),
        _buildTextField(
          controller: _contactController,
          label: 'Contact Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v.length < 10) return 'Enter valid number';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.home_outlined,
          maxLines: 2,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            return null;
          },
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    ),
  );

  Widget _buildPage3() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageTitle('Emergency', 'Contact'),
        const SizedBox(height: 40),
        _buildTextField(
          controller: _emergencyContactController,
          label: 'Emergency Contact Number',
          icon: Icons.warning_amber_rounded,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v.length < 10) return 'Enter valid number';
            return null;
          },
        ),
      ],
    ),
  );

  Widget _buildPageTitle(String t1, String t2) => Row(
    children: [
      Text(
        '$t1 ',
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      Text(
        t2,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: PremiumTheme.primaryPurple,
        ),
      ),
    ],
  );

  Widget _buildContinueButton(VoidCallback onPressed) => Padding(
    padding: const EdgeInsets.all(24),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: PremiumTheme.primaryPurple,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Continue',
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) =>
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
          errorMaxLines: 2,
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
      );

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _handleContinue(PatientProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    try {
      final patient = Patient(
        id: '',
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _gender,
        contact: _contactController.text.trim(),
        address: _addressController.text.trim(),
        chiefComplaint: '',
        checkInTime: DateTime.now(),
        status: 'registering',
        priority: 'green',
      );

      final patientId = await provider.addPatient(patient);

      if (patientId == null) {
        _showErrorDialog('Failed to register patient. Please try again.');
        return;
      }

      _patientId = patientId;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Patient registered successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SymptomsRecorderScreen(patientId: patientId),
        ),
      );
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }
}
