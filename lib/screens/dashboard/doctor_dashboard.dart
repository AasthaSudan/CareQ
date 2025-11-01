import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../config/theme.dart';
import '../../../widgets/section_card.dart';
import '../../../widgets/stat_item.dart';
import '../../../widgets/metric_box.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../providers/patient_provider.dart';

class DoctorDashboard extends StatefulWidget {
  static const routeName = '/doctor-dashboard';
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _navIndex = 0;

  void _onNav(int idx) {
    setState(() => _navIndex = idx);
    switch (idx) {
      case 1:
        Navigator.pushNamed(context, '/register');
        break;
      case 2:
        Navigator.pushNamed(context, '/queue');
        break;
      case 3:
        Navigator.pushNamed(context, '/rooms');
        break;
      case 4:
        Navigator.pushNamed(context, '/settings');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context);

    final total = provider.patients.length;
    final inQueue = provider.queue.length;
    final completed = provider.patients.where((p) => p.vitals != null).length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await provider.fetchPatients();
            await provider.refreshQueue();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good evening,',
                            style: GoogleFonts.inter(
                                fontSize: 16, color: Colors.grey[600])),
                        Text('Dr. Smith',
                            style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B))),
                      ],
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppTheme.mainGradient(),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Stats summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.mainGradient(),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StatItem(
                        icon: Icons.people,
                        value: '$total',
                        label: 'Total Patients',
                        color: Colors.white,
                      ),
                      Container(width: 1, height: 48, color: Colors.white24),
                      StatItem(
                        icon: Icons.access_time,
                        value: '$inQueue',
                        label: 'In Queue',
                        color: Colors.white,
                      ),
                      Container(width: 1, height: 48, color: Colors.white24),
                      StatItem(
                        icon: Icons.check_circle,
                        value: '$completed',
                        label: 'Completed',
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Register Patient
                SectionCard(
                  icon: Icons.person_add,
                  iconColor: const Color(0xFF44B6AF),
                  title: 'Register Patient',
                  subtitle: 'Add new patient to the system',
                  onTap: () => Navigator.pushNamed(context, '/register'),
                ),

                const SizedBox(height: 12),

                // Queue Management
                SectionCard(
                  icon: Icons.groups,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Queue Management',
                  subtitle: 'Manage patient waiting list',
                  onTap: () => Navigator.pushNamed(context, '/queue'),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: _onNav,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/register'),
        backgroundColor: const Color(0xFF1E293B),
        icon: const Icon(Icons.add),
        label: const Text('New Patient'),
      ),
    );
  }
}
