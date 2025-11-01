import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final List<Widget> children;
  final VoidCallback? onTap;

  const SectionCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.children = const [],
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0,6))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                Container(width: 56, height: 56, decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))), const SizedBox(height: 4), Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey))])),
                if (badge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)), child: Text(badge!, style: const TextStyle(color: Colors.white))),
              ]),
              if (children.isNotEmpty) const SizedBox(height: 12),
              ...children,
            ]),
          ),
        ),
      ),
    );
  }
}
