// lib/screens/ai_analysis_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'queue_screen.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';

class AIAnalysisScreen extends StatelessWidget {
  static const routeName = '/ai';
  final String? patientId;
  const AIAnalysisScreen({Key? key, this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context, listen: false);
    // Placeholder: create analysis summary from vitals if available.
    double confidence = 92.4;
    String priority = 'URGENT';
    String recommendation = 'Monitor vitals and transfer to emergency if condition worsens.';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                  child: const Icon(Icons.analytics, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 26),
                Text('AI Analysis Complete', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Text('Priority: $priority', style: GoogleFonts.inter(fontSize: 18, color: Colors.white)),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18), decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(16)), child: Text('Confidence: ${confidence.toStringAsFixed(1)}%', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600))),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Recommendation', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(recommendation, style: GoogleFonts.inter(color: Colors.grey[700])),
                  ]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF6366F1)),
                    onPressed: () {
                      // Navigate to queue screen
                      Navigator.pushReplacementNamed(context, QueueScreen.routeName);
                    },
                    child: Text('View Queue', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
