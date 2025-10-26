import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/patient_provider.dart';
import 'new_patient_registration_screen.dart' hide PatientProvider;
import 'existing_patient_search_screen.dart';

class PatientQueueStatusScreen extends StatelessWidget {
  const PatientQueueStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context);
    final patient = provider.patient;

    // No patient loaded scenario
    if (patient == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Patient Dashboard'),
          backgroundColor: PremiumTheme.primaryPurple,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No patient loaded', style: TextStyle(fontSize: 18, color: PremiumTheme.primaryPurple)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ExistingPatientSearchScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: PremiumTheme.primaryPurple),
                child: const Text('Search for Existing Patient'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NewPatientRegistrationScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: PremiumTheme.primaryPurple),
                child: const Text('Register New Patient'),
              ),
            ],
          ),
        ),
      );
    }

    // Display the dashboard for the loaded patient
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        backgroundColor: PremiumTheme.primaryPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patient.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Age: ${patient.age}, Phone: ${patient.phone}'),
            const SizedBox(height: 16),
            _buildVitals(provider),
            const SizedBox(height: 16),
            _buildAssignedDoctor(provider),
            const SizedBox(height: 16),
            if (patient.aiAnalysis.isNotEmpty) _buildAIAnalysis(provider),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (patient.id.startsWith('PAT')) {
                    // Navigate to the flow for new patients
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NewPatientRegistrationScreen()));
                  } else {
                    // Navigate to the flow for existing patients
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ExistingPatientSearchScreen()));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: PremiumTheme.primaryPurple),
                child: const Text('Edit / Re-analyze'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitals(PatientProvider provider) {
    final vitals = provider.patient?.vitals ?? {};
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vitals', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('BP: ${vitals['bp'] ?? 'Not available'}'),
            Text('Pulse: ${vitals['pulse'] ?? 'Not available'}'),
            Text('Temp: ${vitals['temp'] ?? 'Not available'}'),
            Text('Oxygen: ${vitals['oxygen'] ?? 'Not available'}'),
            Text('Pain Level: ${vitals['painLevel'] ?? 'Not available'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedDoctor(PatientProvider provider) {
    final doctor = provider.patient?.assignedDoctor ?? 'Not assigned';
    final room = provider.patient?.assignedRoom ?? 'Not assigned';
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assigned Doctor', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Doctor: $doctor'),
            Text('Room: $room'),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysis(PatientProvider provider) {
    final ai = provider.patient?.aiAnalysis ?? {};
    final priority = ai['priority'] ?? 'Not analyzed';
    final riskScore = ai['riskScore'] ?? 0;
    final riskFactors = List<String>.from(ai['riskFactors'] ?? []);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Priority: $priority'),
            Text('Risk Score: $riskScore'),
            if (riskFactors.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Key Risk Factors:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...riskFactors.map((factor) => Text('• $factor')),
            ],
          ],
        ),
      ),
    );
  }
}
