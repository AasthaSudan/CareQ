import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MetricBox extends StatelessWidget {
  final String value;
  final String label;

  const MetricBox({Key? key, required this.value, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
      ]),
    );
  }
}
