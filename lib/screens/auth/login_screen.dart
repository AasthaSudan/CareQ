import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _loading = true);

    try {
      await auth.signIn(_email.text.trim(), _password.text.trim());
      if (!mounted) return;

      // Success - navigation handled by main.dart EntryPoint
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
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
                      'Welcome Back',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to continue to CareQ',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Email Field
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(
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

                    // Password Field
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
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
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: AppTheme.primaryPurple.withOpacity(0.3),
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
                          'Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppTheme.textLight.withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textLight,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppTheme.textLight.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Google Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement Google Sign In
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppTheme.textLight.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Image.asset(
                          'assets/images/google_logo.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.g_mobiledata_rounded,
                              size: 32,
                              color: AppTheme.primaryPurple,
                            );
                          },
                        ),
                        label: Text(
                          'Continue with Google',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              SignUpScreen.routeName,
                            );
                          },
                          child: Text(
                            'Sign Up',
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
