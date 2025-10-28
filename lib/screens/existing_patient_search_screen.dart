import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'symptoms_recorder_screen.dart';

class ExistingPatientSearchScreen extends StatefulWidget {
  const ExistingPatientSearchScreen({super.key});

  @override
  State<ExistingPatientSearchScreen> createState() => _ExistingPatientSearchScreenState();
}

class _ExistingPatientSearchScreenState extends State<ExistingPatientSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Find Your Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search by',
              style: TextStyle(fontSize: 24, color: PremiumTheme.textGray),
            ),
            const Text(
              'Patient ID or Phone',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: PremiumTheme.primaryPurple,
              ),
            ),
            const SizedBox(height: 40),

            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter Patient ID or Phone Number',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Search Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SymptomsRecorderScreen(patientId: '',),
                    ),
                  );
                },
                child: const Text(
                  'Search',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // OR Divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR'),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),
            const SizedBox(height: 24),

            // QR Code Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: PremiumTheme.blueGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: PremiumTheme.cardShadow,
              ),
              child: Column(
                children: const [
                  Icon(Icons.qr_code_2, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Use your patient card',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}