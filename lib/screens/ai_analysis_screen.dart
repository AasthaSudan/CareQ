import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'queue_screen.dart';
import '../config/theme.dart';

class AIAnalysisScreen extends StatelessWidget {
  static const routeName = '/ai';
  final String? patientId;
  const AIAnalysisScreen({Key? key, this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final confidence = 94.5;
    final priority = 'URGENT';
    final recommendation =
        'Immediate review and observation recommended. Consider oxygen supplementation and priority room assignment.';

    return Scaffold(
      // ✅ only one body now
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryPurple, AppTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.analytics,
                        size: 56, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text('AI Analysis Complete',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 12),
                  Text('Priority: $priority',
                      style:
                      GoogleFonts.inter(fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Confidence: ${confidence.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recommendation',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          recommendation,
                          style: GoogleFonts.inter(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushReplacementNamed(context, QueueScreen.routeName),
        label: const Text('View Queue'),
        icon: const Icon(Icons.list),
      ),
    );
  }
}
