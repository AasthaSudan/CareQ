import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const AppBottomNav({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppTheme.primaryPurple,
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Dashboard'),
        BottomNavigationBarItem(icon: const Icon(Icons.person_add), label: 'Register'),
        BottomNavigationBarItem(icon: const Icon(Icons.people), label: 'Queue'),
        BottomNavigationBarItem(icon: const Icon(Icons.meeting_room), label: 'Rooms'),
        BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
