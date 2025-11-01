import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/patient_model.dart';
import '../providers/patient_provider.dart';
import '../config/theme.dart';

class QueueScreen extends StatelessWidget {
  static const routeName = '/queue';
  const QueueScreen({Key? key}) : super(key: key);

  Widget _item(BuildContext context, int idx, PatientModel patient, PatientProvider provider) {
    final priorities = ['Critical', 'Urgent', 'Stable'];
    final priority = idx % 3 == 0 ? priorities[0] : (idx % 3 == 1 ? priorities[1] : priorities[2]);
    final colors = {'Critical': AppTheme.critical, 'Urgent': AppTheme.urgent, 'Stable': AppTheme.stable};
    final color = colors[priority]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0,6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 54, height: 54, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Center(child: Text('${idx+1}', style: TextStyle(color: color, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(patient.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)), const SizedBox(height: 6), Text('Waiting ${(idx+1)*5}m • ${patient.age ?? '-'}y • ${patient.gender}', style: GoogleFonts.inter(color: Colors.grey[600]))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)), child: Text(priority, style: GoogleFonts.inter(color: Colors.white))),
        ]),
        const SizedBox(height: 12),
        if (patient.symptoms != null) Text('Symptoms: ${patient.symptoms}', style: GoogleFonts.inter(color: Colors.grey[700])),
        const SizedBox(height: 8),
        if (patient.vitals != null) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)), child: Row(children: [
          Expanded(child: Text('BP: ${patient.vitals!['blood_pressure'] ?? '-'}', style: GoogleFonts.inter(color: Colors.grey[800]))),
          Expanded(child: Text('Pulse: ${patient.vitals!['heart_rate'] ?? '-'}', style: GoogleFonts.inter(color: Colors.grey[800]))),
        ])),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () => provider.removeFromQueue(patient.id), child: const Text('View Details')),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Patient Queue', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)))),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(16), child: provider.loading ? const Center(child: CircularProgressIndicator()) : provider.queue.isEmpty ? Center(child: Text('No patients in queue', style: GoogleFonts.inter(color: Colors.grey[600]))) : ListView.builder(itemCount: provider.queue.length, itemBuilder: (ctx, i) => _item(ctx, i, provider.queue[i], provider))),
      ),
    );
  }
}
