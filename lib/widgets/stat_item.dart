import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatItem({Key? key, required this.icon, required this.value, required this.label, this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: color, size: 26),
      const SizedBox(height: 8),
      Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 6),
      Text(label, style: GoogleFonts.inter(fontSize: 12, color: color.withOpacity(0.9))),
    ]);
  }
}
