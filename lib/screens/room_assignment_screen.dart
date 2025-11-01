import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class RoomsScreen extends StatelessWidget {
  static const routeName = '/rooms';
  const RoomsScreen({Key? key}) : super(key: key);

  Widget _roomCard(String number, String status, {String? patient}) {
    Color tagColor = Colors.grey;
    if (status == 'Available') tagColor = AppTheme.stable;
    if (status == 'Occupied') tagColor = AppTheme.critical;
    if (status == 'Cleaning') tagColor = Colors.grey;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: status=='Occupied' ? Border.all(color: AppTheme.critical, width: 2) : null),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [const Icon(Icons.meeting_room, color: Color(0xFF06B6D4)), const SizedBox(width: 8), Text(number, style: GoogleFonts.inter(fontWeight: FontWeight.bold))]), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(20)), child: Text(status, style: GoogleFonts.inter(color: Colors.white)))]),
        const SizedBox(height: 8),
        Text('Floor 1', style: GoogleFonts.inter(color: Colors.grey[600])),
        const SizedBox(height: 8),
        if (patient != null) Row(children: [const Icon(Icons.person, size: 16), const SizedBox(width: 8), Text(patient, style: GoogleFonts.inter(fontWeight: FontWeight.w600))]),
        if (status == 'Available') const SizedBox(height: 12),
        if (status == 'Available') ElevatedButton(onPressed: () {}, child: const Text('Assign Patient')),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room Management', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)))),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            Wrap(spacing: 12, runSpacing: 12, children: [
              SizedBox(width: 320, child: _roomCard('101', 'Occupied', patient: 'Michael Chen')),
              SizedBox(width: 320, child: _roomCard('102', 'Available')),
              SizedBox(width: 320, child: _roomCard('103', 'Cleaning')),
              SizedBox(width: 320, child: _roomCard('104', 'Available')),
            ]),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Status Legend', style: GoogleFonts.inter(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppTheme.stable, borderRadius: BorderRadius.circular(12)), child: Text('Available', style: GoogleFonts.inter(color: Colors.white))), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppTheme.critical, borderRadius: BorderRadius.circular(12)), child: Text('Occupied', style: GoogleFonts.inter(color: Colors.white))), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12)), child: Text('Cleaning', style: GoogleFonts.inter(color: Colors.white)))])]),
                ),
          ],
        ),
        ),
      ),
    );
  }
}
