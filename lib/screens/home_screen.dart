import 'package:flutter/material.dart';
import 'statistics_screen.dart';
import 'register_patient_screen.dart';
import 'queue_screen.dart';
import 'rooms_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    // const StatisticsScreen(),
    // const RegisterPatientScreen(),
    // const QueueScreen(),
    // const RoomsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_add_outlined),
      activeIcon: Icon(Icons.person_add),
      label: 'Register',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.queue_outlined),
      activeIcon: Icon(Icons.queue),
      label: 'Queue',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.meeting_room_outlined),
      activeIcon: Icon(Icons.meeting_room),
      label: 'Rooms',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2196F3),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: _navItems,
        ),
      ),
    );
  }
}