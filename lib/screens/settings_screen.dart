// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../config/theme.dart';
//
// class SettingsScreen extends StatelessWidget {
//   static const routeName = '/settings';
//   const SettingsScreen({Key? key}) : super(key: key);
//
//   Widget tile(IconData icon, String title, String subtitle) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//       child: Row(children: [Container(decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.all(10), child: Icon(icon, color: AppTheme.primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(subtitle, style: GoogleFonts.inter(color: Colors.grey[600]))])), const Icon(Icons.chevron_right)]),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(title: Text('Settings', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)))), body: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
//     Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(children: [CircleAvatar(backgroundColor: AppTheme.primary, radius: 28, child: Text('DR', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Dr. John Smith', style: GoogleFonts.inter(fontWeight: FontWeight.bold)), Text('Emergency Department', style: GoogleFonts.inter(color: Colors.grey[600]))])), ElevatedButton(onPressed: (){}, child: const Text('Edit Profile'))])),
//         const SizedBox(height: 12),
//         tile(Icons.account_circle, 'Profile Information', 'View and edit your profile'),
//         const SizedBox(height: 12),
//         tile(Icons.lock, 'Security', 'Password and authentication'),
//         const SizedBox(height: 12),
//         tile(Icons.notifications, 'Notifications', 'Manage alert settings'),
//         const SizedBox(height: 12),
//         tile(Icons.settings, 'App Settings', 'Customize your experience'),
//         const SizedBox(height: 16),
//         Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Current Role', style: GoogleFonts.inter(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Text('Doctor', style: GoogleFonts.inter(color: AppTheme.primary))))]),])),
//         const Spacer(),
//         SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.critical), onPressed: () {}, child: const Text('Logout'))),
//         ]))));
//   }
// }
