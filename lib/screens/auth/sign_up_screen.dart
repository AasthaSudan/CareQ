import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.signUp(
        email: _email.text.trim(),
        password: _password.text.trim(),
        name: _email.text.split('@')[0],
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Responsive sizing based on screen dimensions
    final isSmallScreen = width < 360;
    final isMediumScreen = width >= 360 && width < 400;
    final isLargeScreen = width >= 400;

    // Dynamic padding
    final horizontalPadding = isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
    final cardPadding = isSmallScreen ? 20.0 : (isMediumScreen ? 26.0 : 32.0);

    // Dynamic text sizes
    final titleSize = isSmallScreen ? 24.0 : (isMediumScreen ? 26.0 : 28.0);
    final subtitleSize = isSmallScreen ? 12.0 : 14.0;
    final inputFontSize = isSmallScreen ? 13.0 : 15.0;
    final buttonTextSize = isSmallScreen ? 14.0 : 16.0;
    final linkTextSize = isSmallScreen ? 12.0 : 14.0;

    // Dynamic icon sizes
    final logoIconSize = isSmallScreen ? 40.0 : (isMediumScreen ? 44.0 : 48.0);
    final inputIconSize = isSmallScreen ? 18.0 : 20.0;

    // Dynamic spacing
    final spacing1 = isSmallScreen ? 6.0 : 8.0;
    final spacing2 = isSmallScreen ? 12.0 : 16.0;
    final spacing3 = isSmallScreen ? 20.0 : 24.0;
    final spacing4 = isSmallScreen ? 24.0 : 32.0;

    // Button height
    final buttonHeight = isSmallScreen ? 50.0 : 56.0;

    // Border radius
    final cardRadius = isSmallScreen ? 20.0 : 24.0;
    final inputRadius = isSmallScreen ? 12.0 : 14.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF7C6FE8),
              const Color(0xFF9B8AFF),
              const Color(0xFFB8A9FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isLargeScreen ? 400 : width * 0.95,
                    ),
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo/Icon
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C6FE8), Color(0xFF9B8AFF)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C6FE8).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person_add_rounded,
                              size: logoIconSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: spacing3),
                          Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          SizedBox(height: spacing1),
                          Text(
                            'Sign up to get started',
                            style: GoogleFonts.poppins(
                              fontSize: subtitleSize,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: spacing4),

                          // Email Field
                          TextFormField(
                            controller: _email,
                            style: GoogleFonts.poppins(fontSize: inputFontSize),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: GoogleFonts.poppins(
                                color: const Color(0xFF7C6FE8),
                                fontSize: inputFontSize,
                              ),
                              prefixIcon: Container(
                                margin: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
                                padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF7C6FE8).withOpacity(0.15),
                                      const Color(0xFF9B8AFF).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF7C6FE8),
                                  size: inputIconSize,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFAFBFF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputRadius),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputRadius),
                                borderSide: BorderSide(
                                  color: const Color(0xFFE8E8F0),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputRadius),
                                borderSide: const BorderSide(
                                  color: Color(0xFF7C6FE8),
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12.0 : 16.0,
                                vertical: isSmallScreen ? 14.0 : 16.0,
                              ),
                            ),
                            validator: (v) => v == null || !v.contains('@')
                                ? 'Enter a valid email'
                                : null,
                          ),
                          SizedBox(height: spacing2),

                          // Password Field
                          TextFormField(
                            controller: _password,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.poppins(fontSize: inputFontSize),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: GoogleFonts.poppins(
                                color: const Color(0xFF7C6FE8),
                                fontSize: inputFontSize,
                              ),
                              prefixIcon: Container(
                                margin: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
                                padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF7C6FE8).withOpacity(0.15),
                                      const Color(0xFF9B8AFF).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF7C6FE8),
                                  size: inputIconSize,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF7C6FE8),
                                  size: inputIconSize,
                                ),
                                onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFAFBFF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputRadius),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputRadius),
                                borderSide: BorderSide(
                                  color: const Color(0xFFE8E8F0),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputRadius),
                                borderSide: const BorderSide(
                                  color: Color(0xFF7C6FE8),
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12.0 : 16.0,
                                vertical: isSmallScreen ? 14.0 : 16.0,
                              ),
                            ),
                            validator: (v) => v == null || v.length < 6
                                ? 'Min 6 chars'
                                : null,
                          ),
                          SizedBox(height: spacing2),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPassword,
                            obscureText: _obscureConfirm,
                            style: GoogleFonts.poppins(fontSize: inputFontSize),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: GoogleFonts.poppins(
                                color: const Color(0xFF7C6FE8),
                                fontSize: inputFontSize,
                              ),
                              prefixIcon: Container(
                                margin: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
                                padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF7C6FE8).withOpacity(0.15),
                                      const Color(0xFF9B8AFF).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF7C6FE8),
                                  size: inputIconSize,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF7C6FE8),
                                  size: inputIconSize,
                                ),
                                onPressed: () => setState(
                                        () => _obscureConfirm = !_obscureConfirm),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFAFBFF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputRadius),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputRadius),
                                borderSide: BorderSide(
                                  color: const Color(0xFFE8E8F0),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputRadius),
                                borderSide: const BorderSide(
                                  color: Color(0xFF7C6FE8),
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12.0 : 16.0,
                                vertical: isSmallScreen ? 14.0 : 16.0,
                              ),
                            ),
                            validator: (v) => v != _password.text
                                ? 'Passwords do not match'
                                : null,
                          ),
                          SizedBox(height: spacing3),

                          // Sign Up Button
                          Container(
                            width: double.infinity,
                            height: buttonHeight,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C6FE8), Color(0xFF9B8AFF)],
                              ),
                              borderRadius: BorderRadius.circular(inputRadius),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C6FE8).withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _loading ? null : _register,
                                borderRadius: BorderRadius.circular(inputRadius),
                                child: Center(
                                  child: _loading
                                      ? SizedBox(
                                    width: isSmallScreen ? 20.0 : 24.0,
                                    height: isSmallScreen ? 20.0 : 24.0,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : Text(
                                    'Sign Up',
                                    style: GoogleFonts.poppins(
                                      fontSize: buttonTextSize,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: spacing2),

                          // Sign In Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: GoogleFonts.poppins(
                                  fontSize: linkTextSize,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, LoginScreen.routeName);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.poppins(
                                    fontSize: linkTextSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF7C6FE8),
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
          ),
        ),
      ),
    );
  }
}