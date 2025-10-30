// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import 'register_patient_screen.dart';
import 'existing_patient_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/welcome';
  const WelcomeScreen({Key? key}) : super(key: key);

  Widget _buildOptionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Gradient gradient,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.86,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
            ]),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const doctorName = 'Dr. Smith';
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient()),
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Good morning,', style: GoogleFonts.inter(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(doctorName, style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                ]),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient(), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppTheme.primaryStart.withOpacity(0.22), blurRadius: 12, offset: const Offset(0, 6))]),
                  child: const Icon(Icons.person, color: Colors.white),
                )
              ]),
            ),
            const SizedBox(height: 30),
            _buildOptionCard(
              context,
              title: 'New Patient',
              subtitle: 'Register a new patient and record vitals',
              icon: Icons.person_add,
              gradient: const LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)]),
              onTap: () => Navigator.pushNamed(context, RegisterPatientScreen.routeName),
            ),
            const SizedBox(height: 22),
            _buildOptionCard(
              context,
              title: 'Existing Patient',
              subtitle: 'Upload or view previous reports',
              icon: Icons.folder_open,
              gradient: const LinearGradient(colors: [Color(0xFFF472B6), Color(0xFFEC4899)]),
              onTap: () => Navigator.pushNamed(context, ExistingPatientScreen.routeName),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text('CareQ', style: GoogleFonts.inter(color: Colors.white70)),
            )
          ]),
        ),
      ),
    );
  }
}
