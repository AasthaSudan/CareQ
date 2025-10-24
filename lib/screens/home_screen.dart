import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'statistics_screen.dart';
import 'register_patient_screen.dart';
import 'queue_screen.dart';
import 'rooms_screen.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> with TickerProviderStateMixin {
  int patientsRegistered = 25;
  int patientsInQueue = 8;
  int availableRooms = 6;
  int todayAppointments = 12;
  int completedToday = 4;

  AnimationController? _headerAnimController;
  AnimationController? _cardAnimController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _headerAnimController?.dispose();
    _cardAnimController?.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    _cardAnimController?.reset();

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        patientsRegistered += math.Random().nextInt(3);
        patientsInQueue = math.max(0, patientsInQueue + math.Random().nextInt(3) - 1);
        availableRooms = 6 + math.Random().nextInt(3);
        completedToday += math.Random().nextInt(2);
      });

      _cardAnimController?.forward();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7A5AF8),
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFF7A5AF8),
          backgroundColor: Colors.white,
          strokeWidth: 3,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Animated Header
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerAnimController!,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _headerAnimController!,
                      curve: Curves.easeOutCubic,
                    )),
                    child: _buildHeader(context, horizontalPadding),
                  ),
                ),
              ),

              // Quick Stats Cards
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerAnimController!,
                  child: _buildQuickStats(horizontalPadding),
                ),
              ),

              // Main Action Cards
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: size.height * 0.02,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildAnimatedCard(
                      context,
                      delay: 0,
                      title: "Statistics",
                      icon: Icons.analytics_outlined,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      summary: "View detailed analytics and insights",
                      page: const StatisticsScreen(),
                      badgeCount: patientsInQueue,
                      stats: [
                        {"label": "Registered", "value": "$patientsRegistered"},
                        {"label": "In Queue", "value": "$patientsInQueue"},
                      ],
                    ),
                    _buildAnimatedCard(
                      context,
                      delay: 100,
                      title: "Register Patient",
                      icon: Icons.person_add_alt_1_outlined,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      summary: "Add new patient to the system",
                      page: const RegisterPatientScreen(),
                      stats: [
                        {"label": "Today", "value": "$todayAppointments"},
                        {"label": "Completed", "value": "$completedToday"},
                      ],
                    ),
                    _buildAnimatedCard(
                      context,
                      delay: 200,
                      title: "Queue Management",
                      icon: Icons.people_outline,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      summary: "Manage patient waiting list",
                      page: const QueueScreen(),
                      badgeCount: patientsInQueue,
                      stats: [
                        {"label": "Waiting", "value": "$patientsInQueue"},
                        {"label": "Avg Wait", "value": "15m"},
                      ],
                    ),
                    _buildAnimatedCard(
                      context,
                      delay: 300,
                      title: "Room Status",
                      icon: Icons.meeting_room_outlined,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      summary: "Monitor consultation rooms",
                      page: const RoomsScreen(),
                      stats: [
                        {"label": "Available", "value": "$availableRooms"},
                        {"label": "Total", "value": "10"},
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double horizontalPadding) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        size.height * 0.02,
        horizontalPadding,
        size.height * 0.03,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_getGreeting()},",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.045,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dr. Smith",
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () {
                  // Profile action
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(double horizontalPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.people,
            value: "$patientsRegistered",
            label: "Total Patients",
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStatItem(
            icon: Icons.access_time,
            value: "$patientsInQueue",
            label: "In Queue",
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStatItem(
            icon: Icons.check_circle,
            value: "$completedToday",
            label: "Completed",
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard(
      BuildContext context, {
        required int delay,
        required String title,
        required IconData icon,
        required Gradient gradient,
        required String summary,
        required Widget page,
        int badgeCount = 0,
        List<Map<String, String>>? stats,
      }) {
    return AnimatedBuilder(
      animation: _cardAnimController!,
      builder: (context, child) {
        final delayedProgress = math.max(
          0.0,
          (_cardAnimController!.value - (delay / 1000)) * (1000 / (1000 - delay)),
        ).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 50 * (1 - delayedProgress)),
          child: Opacity(
            opacity: delayedProgress,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => page,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: gradient.colors.first.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              summary,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (badgeCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            badgeCount.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (stats != null && stats.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: stats.map((stat) {
                          return Column(
                            children: [
                              Text(
                                stat["value"]!,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                stat["label"]!,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}