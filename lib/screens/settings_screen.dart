// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../providers/theme_provider.dart';
// import '../theme.dart';
// import '../providers/auth_provider.dart';
// import '../providers/patient_provider.dart';
// import '../services/pdf_service.dart';
// import 'ai_analysis_screen.dart';
//
// class SettingsScreen extends StatefulWidget {
//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _listController;
//   late Animation<double> _fadeAnimation;
//   late List<Animation<Offset>> _slideAnimations;
//
//   bool _notificationsEnabled = true;
//   bool _soundEnabled = true;
//   bool _autoBackup = false;
//   String _selectedLanguage = 'English';
//
//   final List<Map<String, dynamic>> _recentActivities = [
//     {'action': 'Viewed patient records', 'time': '2 hours ago', 'icon': Icons.folder_open},
//     {'action': 'Generated report', 'time': '5 hours ago', 'icon': Icons.description},
//     {'action': 'Updated settings', 'time': 'Yesterday', 'icon': Icons.settings},
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _listController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeIn,
//     );
//
//     _slideAnimations = List.generate(
//       8,
//           (index) => Tween<Offset>(
//         begin: const Offset(0.3, 0),
//         end: Offset.zero,
//       ).animate(
//         CurvedAnimation(
//           parent: _listController,
//           curve: Interval(
//             index * 0.1,
//             (index * 0.1) + 0.3,
//             curve: Curves.easeOutCubic,
//           ),
//         ),
//       ),
//     );
//
//     _fadeController.forward();
//     _listController.forward();
//   }
//
//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _listController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _refreshData() async {
//     final patientProvider = Provider.of<PatientProvider>(context, listen: false);
//     await patientProvider.fetchPatients();
//
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(Icons.check_circle, color: Colors.white),
//               const SizedBox(width: 12),
//               Text('Data refreshed successfully!', style: GoogleFonts.poppins()),
//             ],
//           ),
//           backgroundColor: const Color(0xFF95E1D3),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final authProvider = Provider.of<AuthProvider>(context);
//     final isDark = themeProvider.isDarkMode;
//     final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FE);
//     final cardColor = isDark ? const Color(0xFF16213E) : Colors.white;
//     final textColor = isDark ? Colors.white : const Color(0xFF2C3E50);
//
//     return Scaffold(
//       backgroundColor: bgColor,
//       body: RefreshIndicator(
//         onRefresh: _refreshData,
//         color: const Color(0xFF7C6FE8),
//         backgroundColor: cardColor,
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: CustomScrollView(
//             slivers: [
//               _buildAppBar(isDark, textColor, cardColor),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildAnimatedSection(0, _buildProfileCard(authProvider, isDark, cardColor, textColor)),
//                       const SizedBox(height: 20),
//                       _buildAnimatedSection(1, _buildQuickActions(isDark, cardColor, textColor)),
//                       const SizedBox(height: 24),
//                       _buildSectionHeader('Preferences', textColor),
//                       const SizedBox(height: 12),
//                       _buildAnimatedSection(2, _buildPreferencesCard(themeProvider, isDark, cardColor, textColor)),
//                       const SizedBox(height: 20),
//                       _buildSectionHeader('Account Settings', textColor),
//                       const SizedBox(height: 12),
//                       _buildAnimatedSection(3, _buildAccountSettings(isDark, cardColor, textColor)),
//                       const SizedBox(height: 20),
//                       _buildSectionHeader('Recent Activity', textColor),
//                       const SizedBox(height: 12),
//                       _buildAnimatedSection(4, _buildRecentActivity(isDark, cardColor, textColor)),
//                       const SizedBox(height: 20),
//                       _buildAnimatedSection(5, _buildStorageCard(isDark, cardColor, textColor)),
//                       const SizedBox(height: 20),
//                       _buildAnimatedSection(6, _buildAboutCard(isDark, cardColor, textColor)),
//                       const SizedBox(height: 20),
//                       _buildAnimatedSection(7, _buildLogoutButton(isDark)),
//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAnimatedSection(int index, Widget child) {
//     return SlideTransition(
//       position: _slideAnimations[index],
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: child,
//       ),
//     );
//   }
//
//   Widget _buildAppBar(bool isDark, Color textColor, Color cardColor) {
//     return SliverAppBar(
//       expandedHeight: 120,
//       floating: false,
//       pinned: true,
//       backgroundColor: const Color(0xFF7C6FE8),
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(
//           'Settings',
//           style: GoogleFonts.poppins(
//             fontSize: 24,
//             fontWeight: FontWeight.w700,
//             color: Colors.white,
//           ),
//         ),
//         background: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.search, color: Colors.white),
//           onPressed: () => _showSearchDialog(),
//         ),
//         IconButton(
//           icon: const Icon(Icons.more_vert, color: Colors.white),
//           onPressed: () => _showMoreOptions(),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProfileCard(AuthProvider authProvider, bool isDark, Color cardColor, Color textColor) {
//     final initials = authProvider.userName != null && authProvider.userName!.isNotEmpty
//         ? authProvider.userName!.substring(0, 2).toUpperCase()
//         : 'DR';
//
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF7C6FE8).withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 3),
//             ),
//             child: CircleAvatar(
//               radius: 36,
//               backgroundColor: Colors.white.withOpacity(0.3),
//               child: Text(
//                 initials,
//                 style: GoogleFonts.poppins(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   authProvider.userName ?? 'Unknown User',
//                   style: GoogleFonts.poppins(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   authProvider.userRole ?? 'Staff Member',
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     color: Colors.white.withOpacity(0.85),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     'ID: DOC-2024-001',
//                     style: GoogleFonts.poppins(
//                       fontSize: 10,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             onPressed: () => _editProfile(),
//             icon: const Icon(Icons.edit, color: Colors.white),
//             style: IconButton.styleFrom(
//               backgroundColor: Colors.white.withOpacity(0.2),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuickActions(bool isDark, Color cardColor, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildQuickActionItem(Icons.download_rounded, 'Export', const Color(0xFF95E1D3), () => _exportDailyReport()),
//           _buildQuickActionItem(Icons.analytics_rounded, 'Analytics', const Color(0xFFFFA07A), () => _navigateToAnalytics()),
//           _buildQuickActionItem(Icons.backup_rounded, 'Backup', const Color(0xFF7C6FE8), () => _performBackup()),
//           _buildQuickActionItem(Icons.help_outline, 'Help', const Color(0xFFFF6B9D), () => _showHelp()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuickActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: color, size: 24),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, Color textColor) {
//     return Text(
//       title,
//       style: GoogleFonts.poppins(
//         fontSize: 16,
//         fontWeight: FontWeight.w700,
//         color: textColor,
//       ),
//     );
//   }
//
//   Widget _buildPreferencesCard(ThemeProvider themeProvider, bool isDark, Color cardColor, Color textColor) {
//     return Container(
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildSwitchTile(
//             icon: isDark ? Icons.dark_mode : Icons.light_mode,
//             title: 'Dark Mode',
//             subtitle: 'Switch theme',
//             value: isDark,
//             onChanged: (val) => themeProvider.toggleTheme(),
//             color: const Color(0xFF7C6FE8),
//           ),
//           _buildDivider(),
//           _buildSwitchTile(
//             icon: Icons.notifications_active,
//             title: 'Notifications',
//             subtitle: 'Push notifications',
//             value: _notificationsEnabled,
//             onChanged: (val) => setState(() => _notificationsEnabled = val),
//             color: const Color(0xFF95E1D3),
//           ),
//           _buildDivider(),
//           _buildSwitchTile(
//             icon: Icons.volume_up,
//             title: 'Sound',
//             subtitle: 'Alert sounds',
//             value: _soundEnabled,
//             onChanged: (val) => setState(() => _soundEnabled = val),
//             color: const Color(0xFFFFA07A),
//           ),
//           _buildDivider(),
//           _buildSwitchTile(
//             icon: Icons.cloud_upload,
//             title: 'Auto Backup',
//             subtitle: 'Daily automatic backup',
//             value: _autoBackup,
//             onChanged: (val) => setState(() => _autoBackup = val),
//             color: const Color(0xFFFF6B9D),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSwitchTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//     required Color color,
//   }) {
//     return SwitchListTile(
//       secondary: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(icon, color: color, size: 24),
//       ),
//       title: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontWeight: FontWeight.w600,
//           fontSize: 14,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: GoogleFonts.poppins(fontSize: 12),
//       ),
//       value: value,
//       activeColor: color,
//       onChanged: onChanged,
//     );
//   }
//
//   Widget _buildAccountSettings(bool isDark, Color cardColor, Color textColor) {
//     return Container(
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildSettingsTile(
//             icon: Icons.person,
//             title: 'Profile Information',
//             subtitle: 'Update your details',
//             color: const Color(0xFF7C6FE8),
//             onTap: () => _editProfile(),
//           ),
//           _buildDivider(),
//           _buildSettingsTile(
//             icon: Icons.lock,
//             title: 'Change Password',
//             subtitle: 'Security settings',
//             color: const Color(0xFFFF6B9D),
//             onTap: () => _changePassword(),
//           ),
//           _buildDivider(),
//           _buildSettingsTile(
//             icon: Icons.language,
//             title: 'Language',
//             subtitle: _selectedLanguage,
//             color: const Color(0xFF95E1D3),
//             onTap: () => _selectLanguage(),
//           ),
//           _buildDivider(),
//           _buildSettingsTile(
//             icon: Icons.privacy_tip,
//             title: 'Privacy Policy',
//             subtitle: 'Terms and conditions',
//             color: const Color(0xFFFFA07A),
//             onTap: () => _showPrivacyPolicy(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSettingsTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(icon, color: color, size: 24),
//       ),
//       title: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontWeight: FontWeight.w600,
//           fontSize: 14,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: GoogleFonts.poppins(fontSize: 12),
//       ),
//       trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//       onTap: onTap,
//     );
//   }
//
//   Widget _buildRecentActivity(bool isDark, Color cardColor, Color textColor) {
//     return Container(
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: _recentActivities.map((activity) {
//           final isLast = activity == _recentActivities.last;
//           return Column(
//             children: [
//               ListTile(
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF7C6FE8).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(activity['icon'], color: const Color(0xFF7C6FE8), size: 20),
//                 ),
//                 title: Text(
//                   activity['action'],
//                   style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
//                 ),
//                 subtitle: Text(
//                   activity['time'],
//                   style: GoogleFonts.poppins(fontSize: 11),
//                 ),
//               ),
//               if (!isLast) _buildDivider(),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildStorageCard(bool isDark, Color cardColor, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Storage',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: textColor,
//                 ),
//               ),
//               Text(
//                 '3.2 GB / 10 GB',
//                 style: GoogleFonts.poppins(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF7C6FE8),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: LinearProgressIndicator(
//               value: 0.32,
//               minHeight: 10,
//               backgroundColor: Colors.grey.shade200,
//               valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C6FE8)),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildStorageItem('Documents', '1.5 GB', const Color(0xFF95E1D3)),
//               _buildStorageItem('Images', '1.2 GB', const Color(0xFFFFA07A)),
//               _buildStorageItem('Other', '0.5 GB', const Color(0xFFFF6B9D)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStorageItem(String label, String size, Color color) {
//     return Column(
//       children: [
//         Container(
//           width: 8,
//           height: 8,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: GoogleFonts.poppins(fontSize: 11),
//         ),
//         Text(
//           size,
//           style: GoogleFonts.poppins(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAboutCard(bool isDark, Color cardColor, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'About CareQ',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: textColor,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildInfoRow('Version', '1.0.0'),
//           const SizedBox(height: 8),
//           _buildInfoRow('Build', '2024.01.15'),
//           const SizedBox(height: 8),
//           _buildInfoRow('Platform', 'Android/iOS'),
//           const SizedBox(height: 16),
//           Text(
//             '© 2024 CareQ. All rights reserved.',
//             style: GoogleFonts.poppins(
//               fontSize: 11,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: GoogleFonts.poppins(fontSize: 13)),
//         Text(
//           value,
//           style: GoogleFonts.poppins(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLogoutButton(bool isDark) {
//     return Container(
//       width: double.infinity,
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFFFF6B9D), Color(0xFFFF8FA3)],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFFFF6B9D).withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: ElevatedButton.icon(
//         onPressed: () => _showLogoutDialog(),
//         icon: const Icon(Icons.logout_rounded, color: Colors.white),
//         label: Text(
//           'Logout',
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDivider() {
//     return Divider(height: 1, color: Colors.grey.shade200);
//   }
//
//   // Actions
//   void _showSearchDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Search Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//         content: TextField(
//           decoration: InputDecoration(
//             hintText: 'Search...',
//             prefixIcon: const Icon(Icons.search),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showMoreOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.share),
//               title: const Text('Share App'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.rate_review),
//               title: const Text('Rate Us'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.bug_report),
//               title: const Text('Report Bug'),
//               onTap: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _editProfile() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Edit Profile feature coming soon!', style: GoogleFonts.poppins()),
//         backgroundColor: const Color(0xFF7C6FE8),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   void _changePassword() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Change Password', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               obscureText: true,
//               decoration: InputDecoration(
//                 labelText: 'Current Password',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               obscureText: true,
//               decoration: InputDecoration(
//                 labelText: 'New Password',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C6FE8)),
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _selectLanguage() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Select Language', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
//             const SizedBox(height: 20),
//             ...['English', 'Spanish', 'French', 'German'].map((lang) {
//               return RadioListTile<String>(
//                 title: Text(lang),
//                 value: lang,
//                 groupValue: _selectedLanguage,
//                 onChanged: (val) {
//                   setState(() => _selectedLanguage = val!);
//                   Navigator.pop(context);
//                 },
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showPrivacyPolicy() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Privacy Policy', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//         content: SingleChildScrollView(
//           child: Text(
//             'Your privacy is important to us. This app collects and processes data according to HIPAA guidelines...',
//             style: GoogleFonts.poppins(fontSize: 13),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showHelp() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             const Icon(Icons.help_outline, color: Color(0xFF7C6FE8)),
//             const SizedBox(width: 12),
//             Text('Help & Support', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Need assistance?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 12),
//             _buildHelpOption(Icons.email, 'Email Support', 'support@careq.com'),
//             const SizedBox(height: 8),
//             _buildHelpOption(Icons.phone, 'Call Us', '+1 (555) 123-4567'),
//             const SizedBox(height: 8),
//             _buildHelpOption(Icons.chat, 'Live Chat', 'Available 24/7'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHelpOption(IconData icon, String title, String subtitle) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: const Color(0xFF7C6FE8)),
//         const SizedBox(width: 12),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
//             Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
//           ],
//         ),
//       ],
//     );
//   }
//
//   void _performBackup() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const CircularProgressIndicator(color: Color(0xFF7C6FE8)),
//             const SizedBox(height: 20),
//             Text('Backing up data...', style: GoogleFonts.poppins()),
//           ],
//         ),
//       ),
//     );
//
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(Icons.check_circle, color: Colors.white),
//               const SizedBox(width: 12),
//               Text('Backup completed successfully!', style: GoogleFonts.poppins()),
//             ],
//           ),
//           backgroundColor: const Color(0xFF95E1D3),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//     });
//   }
//
//   void _exportDailyReport() async {
//     final patientProvider = Provider.of<PatientProvider>(context, listen: false);
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const CircularProgressIndicator(color: Color(0xFF7C6FE8)),
//             const SizedBox(height: 20),
//             Text('Generating report...', style: GoogleFonts.poppins()),
//           ],
//         ),
//       ),
//     );
//
//     try {
//       await PdfService.generateDailyReport(patientProvider.patients, DateTime.now());
//
//       if (mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.white),
//                 const SizedBox(width: 12),
//                 Text('Report exported successfully!', style: GoogleFonts.poppins()),
//               ],
//             ),
//             backgroundColor: const Color(0xFF95E1D3),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             action: SnackBarAction(
//               label: 'View',
//               textColor: Colors.white,
//               onPressed: () {},
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Export failed: $e', style: GoogleFonts.poppins()),
//             backgroundColor: const Color(0xFFFF6B9D),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }
//
//   void _navigateToAnalytics() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => AIAnalysisScreen()),
//     );
//   }
//
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             const Icon(Icons.logout, color: Color(0xFFFF6B9D)),
//             const SizedBox(width: 12),
//             Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//           ],
//         ),
//         content: Text(
//           'Are you sure you want to logout?',
//           style: GoogleFonts.poppins(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: GoogleFonts.poppins()),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final authProvider = Provider.of<AuthProvider>(context, listen: false);
//               authProvider.signOut();
//               Navigator.pop(context);
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Row(
//                     children: [
//                       const Icon(Icons.check_circle, color: Colors.white),
//                       const SizedBox(width: 12),
//                       Text('Logged out successfully', style: GoogleFonts.poppins()),
//                     ],
//                   ),
//                   backgroundColor: const Color(0xFF95E1D3),
//                   behavior: SnackBarBehavior.floating,
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFFF6B9D),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//             child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }