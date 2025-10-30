// lib/screens/queue_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/patient_model.dart';
import '../providers/patient_provider.dart';

class QueueScreen extends StatelessWidget {
  static const routeName = '/queue';
  const QueueScreen({Key? key}) : super(key: key);

  Widget _queueItem(BuildContext context, int idx, PatientModel patient, PatientProvider provider) {
    final priorities = ['Critical', 'Urgent', 'Stable'];
    final priority = idx % 3 == 0 ? 'Critical' : (idx % 3 == 1 ? 'Urgent' : 'Stable');
    final colors = {
      'Critical': const Color(0xFFEF4444),
      'Urgent': const Color(0xFFFFA726),
      'Stable': const Color(0xFF10B981),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6))]),
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: colors[priority]!.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text('${idx + 1}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: colors[priority]))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patient.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Waiting: ${(idx + 1) * 5}m', style: GoogleFonts.inter(color: Colors.grey[600])),
          ]),
        ),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: colors[priority], borderRadius: BorderRadius.circular(20)), child: Text(priority, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        IconButton(onPressed: () => provider.removeFromQueue(patient.id), icon: const Icon(Icons.check_circle_outline, color: Color(0xFF6366F1))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Queue', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.queue.isEmpty
              ? Center(child: Text('No patients in queue', style: GoogleFonts.inter(color: Colors.grey[600])))
              : ListView.builder(
            itemCount: provider.queue.length,
            itemBuilder: (ctx, i) => _queueItem(ctx, i, provider.queue[i], provider),
          ),
        ),
      ),
    );
  }
}
