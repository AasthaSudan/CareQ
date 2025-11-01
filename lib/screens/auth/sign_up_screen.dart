import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  String _role = 'patient';
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _loading = true);

    try {
      await auth.signUp(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
        role: _role,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully!'),
          backgroundColor: AppTheme.stable,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate to login or auto-login based on your flow
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: ${e.toString()}'),
          backgroundColor: AppTheme.critical,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple.withOpacity(0.1),
              AppTheme.scaffoldBg,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient(),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign up to get started',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Name Field
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(
                          Icons.person_outlined,
                          color: AppTheme.primaryPurple,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppTheme.primaryPurple,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Role Selection
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(
                        labelText: 'I am a...',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          color: AppTheme.primaryPurple,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'patient',
                          child: Text('Patient'),
                        ),
                        DropdownMenuItem(
                          value: 'doctor',
                          child: Text('Doctor'),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Hospital Admin'),
                        ),
                      ],
                      onChanged: (value) => setState(() => _role = value!),
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Create a password',
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                          color: AppTheme.primaryPurple,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textLight,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPassword,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                          color: AppTheme.primaryPurple,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textLight,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _password.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              LoginScreen.routeName,
                            );
                          },
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}