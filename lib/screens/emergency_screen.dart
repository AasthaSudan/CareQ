import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🚨 Emergency', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
              const SizedBox(height: 8),
              const Text('Quick access to emergency services', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [const Color(0xFFEF5350), const Color(0xFFE53935)]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: const Color(0xFFEF5350).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.phone_rounded, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 20),
                    const Text('Call Emergency', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Dial 911', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildQuickAction(Icons.local_hospital_rounded, 'Nearest Hospital', 'Find closest emergency room', const Color(0xFF6B5CE7)),
              const SizedBox(height: 16),
              _buildQuickAction(Icons.medical_services_rounded, 'Ambulance Service', 'Request immediate transport', const Color(0xFF4ECDC4)),
              const SizedBox(height: 16),
              _buildQuickAction(Icons.warning_rounded, 'Report Symptoms', 'Get priority assessment', const Color(0xFFFFB74D)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
