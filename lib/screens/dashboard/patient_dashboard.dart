import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../existing_patient_screen.dart';
import '../register_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({Key? key}) : super(key: key);

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _HeaderSection(),
                const SizedBox(height: 14),
                _QuickStatsSection(),
                const SizedBox(height: 14),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _PatientCards(
                      onNewPatient: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterPatientScreen()),
                        );
                      },
                      onExistingPatient: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ExistingPatientScreen()),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FE8).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusBadge(),
              Row(
                children: const [
                  _HeaderIcon(icon: Icons.notifications_outlined),
                  SizedBox(width: 12),
                  _HeaderIcon(icon: Icons.settings_outlined),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome back,',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Miss Clare',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How can we help you today?',
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF95E1D3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Online',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  const _HeaderIcon({required this.icon, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _QuickStatsSection extends StatelessWidget {
  const _QuickStatsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _StatItem(icon: Icons.people_outline, value: '127', label: 'Patients', color: Color(0xFF7C6FE8)),
          _VerticalDivider(),
          _StatItem(icon: Icons.schedule_outlined, value: '24h', label: 'Available', color: Color(0xFF95E1D3)),
          _VerticalDivider(),
          _StatItem(icon: Icons.check_circle_outline, value: '98%', label: 'Success', color: Color(0xFFFFA07A)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({required this.icon, required this.value, required this.label, required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2C3E50))),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }
}

class _PatientCards extends StatelessWidget {
  final VoidCallback onNewPatient;
  final VoidCallback onExistingPatient;

  const _PatientCards({required this.onNewPatient, required this.onExistingPatient, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _PatientCard(
            icon: Icons.person_add_alt_rounded,
            title: 'New Patient',
            subtitle: 'Register a new patient',
            color: const Color(0xFF7C6FE8),
            onTap: onNewPatient,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _PatientCard(
            icon: Icons.folder_shared_rounded,
            title: 'Existing Patient',
            subtitle: 'View patient records',
            color: const Color(0xFF95E1D3),
            onTap: onExistingPatient,
          ),
        ),
      ],
    );
  }
}

class _PatientCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PatientCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.scale(
        scale: 0.9 + 0.1 * value,
        child: Opacity(opacity: value, child: child),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: color.withOpacity(0.1),
            highlightColor: color.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CardIcon(icon: icon, color: color),
                  const SizedBox(height: 12),
                  Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2C3E50))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey)),
                  const SizedBox(height: 12),
                  _CardButton(color: color),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CardIcon({required this.icon, required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.2), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Icon(icon, size: 40, color: color),
    );
  }
}

class _CardButton extends StatelessWidget {
  final Color color;
  const _CardButton({required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Get Started', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          SizedBox(width: 5),
          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
        ],
      ),
    );
  }
}