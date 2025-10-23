import 'package:flutter/material.dart';
import '../services/firebase.service.dart';
import '../widgets/stats_card.dart';
import '../config/theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      Map<String, int> stats = await _firebaseService.getStatistics();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading statistics: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.analytics,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Real-Time Analytics',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Updated: ${TimeOfDay.now().format(context)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Total Patients Card (Large)
              StatsCard(
                title: 'Total Patients Today',
                value: '${_stats['totalPatients'] ?? 0}',
                icon: Icons.people,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),

              // Priority Breakdown
              const Text(
                'Priority Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Critical',
                      value: '${_stats['critical'] ?? 0}',
                      icon: Icons.warning_amber,
                      color: AppTheme.criticalRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Urgent',
                      value: '${_stats['urgent'] ?? 0}',
                      icon: Icons.error_outline,
                      color: AppTheme.urgentYellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              StatsCard(
                title: 'Non-Urgent',
                value: '${_stats['nonUrgent'] ?? 0}',
                icon: Icons.info_outline,
                color: AppTheme.nonUrgentGreen,
              ),
              const SizedBox(height: 24),

              // Patient Status
              const Text(
                'Patient Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Waiting',
                      value: '${_stats['waiting'] ?? 0}',
                      icon: Icons.hourglass_empty,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'In Treatment',
                      value: '${_stats['inTreatment'] ?? 0}',
                      icon: Icons.medical_services,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              StatsCard(
                title: 'Discharged Today',
                value: '${_stats['discharged'] ?? 0}',
                icon: Icons.check_circle,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),

              // Room Status
              const Text(
                'Room Occupancy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRoomStat(
                      'Total',
                      '${_stats['totalRooms'] ?? 0}',
                      Icons.meeting_room,
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white30,
                    ),
                    _buildRoomStat(
                      'Occupied',
                      '${_stats['occupiedRooms'] ?? 0}',
                      Icons.person,
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white30,
                    ),
                    _buildRoomStat(
                      'Available',
                      '${_stats['availableRooms'] ?? 0}',
                      Icons.check_circle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AI Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.aiGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '🤖 AI-Powered Triage',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Multi-factor risk assessment for accurate prioritization',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}