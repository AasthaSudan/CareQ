import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DischargeSummaryScreen extends StatefulWidget {
  const DischargeSummaryScreen({super.key});

  @override
  State<DischargeSummaryScreen> createState() => _DischargeSummaryScreenState();
}

class _DischargeSummaryScreenState extends State<DischargeSummaryScreen> {
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discharge Summary'),
        backgroundColor: const Color(0xFF7A5AF8), // Your theme color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Treatment Summary',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _treatmentController,
                decoration: const InputDecoration(
                  hintText: 'Enter treatment details...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Text('Medications Prescribed',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _medicationsController,
                decoration: const InputDecoration(
                  hintText: 'Enter medications...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Follow-up Care',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _followUpController,
                decoration: const InputDecoration(
                  hintText: 'Enter follow-up care instructions...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Additional Notes',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _additionalNotesController,
                decoration: const InputDecoration(
                  hintText: 'Enter additional notes...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle save action
                    // For example, save discharge summary to the database
                    print('Discharge summary saved!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A5AF8), // Your theme color
                  ),
                  child: const Text('Save Discharge Summary'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
