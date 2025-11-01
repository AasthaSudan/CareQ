// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../config/theme.dart';
// import 'auth/dashboard/doctor_dashboard.dart';
// import 'auth/register_screen.dart';
// import 'existing_patient_screen.dart';
// import '../widgets/section_card.dart';
//
// class WelcomeScreen extends StatelessWidget {
//   static const routeName = '/';
//   const WelcomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final hour = DateTime.now().hour;
//     final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
//     return Scaffold(
//       backgroundColor: AppTheme.scaffoldBg,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('$greeting,', style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700])),
//                 const SizedBox(height: 6),
//                 Text('Dr. Smith', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
//               ]),
//               Container(width: 52, height: 52, decoration: BoxDecoration(gradient: AppTheme.mainGradient(), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: Colors.white)),
//             ]),
//             const SizedBox(height: 22),
//             SectionCard(
//               icon: Icons.person_add,
//               iconColor: const Color(0xFF44B6AF),
//               title: 'Register Patient',
//               subtitle: 'Add new patient to the system',
//               onTap: () => Navigator.pushNamed(context, RegisterPatientScreen.routeName),
//               children: [const SizedBox(height: 12)],
//             ),
//             const SizedBox(height: 14),
//             SectionCard(
//               icon: Icons.folder_open,
//               iconColor: const Color(0xFF06B6D4),
//               title: 'Existing Patient',
//               subtitle: 'Upload or view reports',
//               onTap: () => Navigator.pushNamed(context, ExistingPatientScreen.routeName),
//             ),
//             const SizedBox(height: 14),
//             SectionCard(
//               icon: Icons.groups,
//               iconColor: const Color(0xFFF59E0B),
//               title: 'Queue Management',
//               subtitle: 'Manage patient waiting list',
//               onTap: () => Navigator.pushNamed(context, '/queue'),
//             ),
//             const Spacer(),
//             Center(child: Text('CareQ', style: GoogleFonts.inter(color: Colors.grey[500]))),
//           ]),
//         ),
//       ),
//     );
//   }
// }
