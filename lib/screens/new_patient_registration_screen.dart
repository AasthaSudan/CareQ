// lib/screens/new_patient_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
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
    extends State<NewPatientRegistrationScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _progressController;
  late AnimationController _slideController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();

  String _gender = 'Male';
  String? _patientId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _pageController.dispose();
    _progressController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumTheme.primaryPurple.withOpacity(0.05),
              Colors.white,
              PremiumTheme.accentBlue.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                _buildEnhancedProgressBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                      _progressController.forward(from: 0);
                    },
                    children: [
                      _buildPage1(),
                      _buildPage2(),
                      _buildPage3(),
                    ],
                  ),
                ),
                _buildEnhancedButton(() => _handleContinue(patientProvider)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: PremiumTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: PremiumTheme.primaryPurple,
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Patient',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: PremiumTheme.textDark,
                  ),
                ),
                Text(
                  'Step ${_currentPage + 1} of 3',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: PremiumTheme.purpleGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${(_currentPage + 1) * 30}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProgressBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentPage;
          final isCompleted = index < _currentPage;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? PremiumTheme.purpleGradient
                          : null,
                      color: isActive ? null : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: isActive
                        ? AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: isCompleted ? 1.0 : _progressController.value,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.transparent),
                          minHeight: 6,
                        );
                      },
                    )
                        : null,
                  ),
                ),
                if (index < 2)
                  Container(
                    width: 8,
                    height: 6,
                    color: Colors.transparent,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPage1() => _buildPageWrapper(
    icon: Icons.person_outline,
    title: 'Personal',
    subtitle: 'Information',
    child: Column(
      children: [
        _buildEnhancedTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          hint: 'Enter your full name',
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Please enter patient name';
            if (v.trim().length < 2) return 'Name must be at least 2 characters';
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildEnhancedTextField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.cake_outlined,
                hint: 'Years',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final age = int.tryParse(v);
                  if (age == null || age < 0 || age > 150) return 'Invalid';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildGenderSelector()),
          ],
        ),
      ],
    ),
  );

  Widget _buildPage2() => _buildPageWrapper(
    icon: Icons.phone_outlined,
    title: 'Contact',
    subtitle: 'Details',
    child: Column(
      children: [
        _buildEnhancedTextField(
          controller: _contactController,
          label: 'Contact Number',
          icon: Icons.phone_outlined,
          hint: 'Enter phone number',
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v.length < 10) return 'Enter valid number';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildEnhancedTextField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on_outlined,
          hint: 'Enter your address',
          maxLines: 3,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            return null;
          },
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    ),
  );

  Widget _buildPage3() => _buildPageWrapper(
    icon: Icons.emergency_outlined,
    title: 'Emergency',
    subtitle: 'Contact',
    child: Column(
      children: [
        _buildEnhancedTextField(
          controller: _emergencyContactController,
          label: 'Emergency Contact',
          icon: Icons.call_outlined,
          hint: 'Emergency phone number',
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v.length < 10) return 'Enter valid number';
            return null;
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: PremiumTheme.warningOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: PremiumTheme.warningOrange.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: PremiumTheme.warningOrange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This contact will be notified in case of emergency',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildPageWrapper({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: PremiumTheme.purpleGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: PremiumTheme.textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: PremiumTheme.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PremiumTheme.primaryPurple.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PremiumTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: PremiumTheme.primaryPurple, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: PremiumTheme.primaryPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: PremiumTheme.errorRed, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: PremiumTheme.errorRed, width: 2),
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PremiumTheme.primaryPurple.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _gender,
        decoration: const InputDecoration(
          labelText: 'Gender',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: PremiumTheme.primaryPurple),
        items: ['Male', 'Female', 'Other']
            .map((g) => DropdownMenuItem(
          value: g,
          child: Text(g),
        ))
            .toList(),
        onChanged: (value) => setState(() => _gender = value!),
      ),
    );
  }

  Widget _buildEnhancedButton(VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: PremiumTheme.purpleGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: PremiumTheme.primaryPurple.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentPage < 2 ? 'Continue' : 'Complete Registration',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                _currentPage < 2
                    ? Icons.arrow_forward_rounded
                    : Icons.check_circle_outline,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: PremiumTheme.errorRed),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
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

    setState(() => _isLoading = true);

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
        setState(() => _isLoading = false);
        return;
      }

      _patientId = patientId;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Patient registered successfully!'),
            ],
          ),
          backgroundColor: PremiumTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      setState(() => _isLoading = false);
    }
  }
}