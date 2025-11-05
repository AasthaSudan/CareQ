import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import '../services/pdf_service.dart';
import 'ai_analysis_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Example: Refresh patient data or settings
    final patientProvider =
    Provider.of<PatientProvider>(context, listen: false);
    await patientProvider.fetchPatients();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data refreshed successfully!'),
        backgroundColor: AppTheme.stable,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileCard(authProvider),
                    const SizedBox(height: 16),
                    _buildDarkModeToggle(themeProvider),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Account'),
                    _buildExpandableCard(
                      [
                        _buildSettingsTile(
                          context,
                          icon: Icons.person_rounded,
                          title: 'Profile Information',
                          subtitle: 'View and edit your profile',
                          onTap: () {},
                        ),
                        _buildSettingsTile(
                          context,
                          icon: Icons.security_rounded,
                          title: 'Security',
                          subtitle: 'Password and authentication',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Preferences'),
                    _buildExpandableCard(
                      [
                        _buildSettingsTile(
                          context,
                          icon: Icons.notifications_rounded,
                          title: 'Notifications',
                          subtitle: 'Manage alert settings',
                          onTap: () {},
                        ),
                        _buildSettingsTile(
                          context,
                          icon: Icons.download_rounded,
                          title: 'Export Reports',
                          subtitle: 'Download daily reports',
                          onTap: () => _exportDailyReport(context),
                        ),
                        _buildSettingsTile(
                          context,
                          icon: Icons.analytics_rounded,
                          title: 'Analytics',
                          subtitle: 'View AI insights and trends',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AIAnalysisScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCurrentRoleCard(authProvider),
                    const SizedBox(height: 16),
                    _buildAboutCard(),
                    const SizedBox(height: 24),
                    _buildLogoutButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(AuthProvider authProvider) {
    final initials = authProvider.userName != null && authProvider.userName!.isNotEmpty
        ? authProvider.userName!.substring(0, 2).toUpperCase()
        : 'DR';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.teal,
              child: Text(
                initials,
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.userName ?? 'Unknown Name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Emergency Department',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Staff ID: DOC-2024-001',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.teal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle(ThemeProvider themeProvider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        title: const Text(
          'Dark Mode',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Switch between light and dark theme'),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: AppTheme.primaryPurple,
          ),
        ),
        value: themeProvider.isDarkMode,
        activeColor: AppTheme.teal,
        onChanged: (value) => themeProvider.toggleTheme(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildExpandableCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        children: children
            .map((child) => Column(
          children: [child, const Divider(height: 1)],
        ))
            .toList(),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context,
      {required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.teal),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildCurrentRoleCard(AuthProvider authProvider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.teal.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Role',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              authProvider.userRole ?? 'Unknown Role',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.teal),
            ),
            const SizedBox(height: 4),
            const Text(
              'Full access to patient records, triage assessment, and room management',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'For role changes, contact your administrator',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Version', '1.0.0'),
            const SizedBox(height: 8),
            _buildInfoRow('Last Updated', 'January 2024'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Logout', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.critical,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
              authProvider.signOut();
              Navigator.pop(context);
              // Navigate to login screen if required
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.critical),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportDailyReport(BuildContext context) async {
    final patientProvider =
    Provider.of<PatientProvider>(context, listen: false);
    await PdfService.generateDailyReport(patientProvider.patients, DateTime.now());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report generated successfully!'),
        backgroundColor: AppTheme.stable,
      ),
    );
  }
}
