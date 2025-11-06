// Create: lib/screens/main_navigator.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:care_q/screens/dashboard/patient_dashboard.dart';
import 'package:care_q/screens/register_screen.dart';
import 'package:care_q/screens/queue_screen.dart';
import 'package:care_q/screens/room_assignment_screen.dart';
import 'package:care_q/screens/profile_screen.dart';
import '../services/openai_service.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final OpenAIService aiService;
  late final AnimationController _fadeController;
  late final AnimationController _fabController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    aiService = OpenAIService(apiKey: dotenv.env['OPENAI_API_KEY'] ?? '');
    _fabController =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..forward();
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  final List<NavigationItem> _navItems = [
    NavigationItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    NavigationItem(icon: Icons.add_circle_outline, activeIcon: Icons.add_circle, label: 'Check-In'),
    NavigationItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Queue'),
    NavigationItem(icon: Icons.meeting_room_outlined, activeIcon: Icons.meeting_room, label: 'Rooms'),
    NavigationItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  late final List<Widget> _screens = [
    const PatientDashboard(),
    RegisterPatientScreen(),
    QueueScreen(aiService: aiService),
    const RoomsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) async {
    if (_currentIndex == index) return;
    await _fadeController.reverse();
    setState(() => _currentIndex = index);
    await _fadeController.forward();
    _fabController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 1
          ? ScaleTransition(
        scale: _fabController,
        child: FloatingActionButton.extended(
          onPressed: _showQuickEmergencyDialog,
          backgroundColor: const Color(0xFFFF6B9D),
          icon: const Icon(Icons.emergency, color: Colors.white),
          label: Text('Emergency',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final isSelected = _currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onItemTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [
                      const Color(0xFF7C6FE8).withOpacity(0.15),
                      const Color(0xFF9B8AFF).withOpacity(0.1),
                    ])
                        : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? const Color(0xFF7C6FE8) : Colors.grey[600],
                          size: isSelected ? 24 : 22),
                      const SizedBox(height: 2),
                      Text(item.label,
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF7C6FE8) : Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showQuickEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF8FAB)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emergency, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              Text('Emergency Registration',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              const SizedBox(height: 12),
              Text('Quick registration for critical patients',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7C6FE8)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF7C6FE8), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Navigate to Emergency Form Screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B9D),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Proceed',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({required this.icon, required this.activeIcon, required this.label});
}