import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/patient_model.dart';
import '../models/vital_signs.dart';
import '../providers/patient_provider.dart';
import '../services/openai_service.dart';

class QueueScreen extends StatefulWidget {
  final OpenAIService aiService;
  const QueueScreen({Key? key, required this.aiService}) : super(key: key);
  @override
  _QueueScreenState createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, provider, _) {
        // Get current user's patient data (simulated - find patient with ID 'P001' which is "You")
        final patients = provider.waitingPatients.isEmpty ? _generateDummyPatients() : provider.waitingPatients;

        // Find current user in the queue (looking for 'P001' or 'You')
        final currentPatientIndex = patients.indexWhere((p) => p.id == 'P001' || p.name == 'You');
        final currentPatient = currentPatientIndex != -1 ? patients[currentPatientIndex] : null;
        final position = currentPatientIndex != -1 ? currentPatientIndex + 1 : 0;
        final totalInQueue = patients.length + 2; // Add some padding to total
        final patientsAhead = position > 0 ? position - 1 : 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                if (provider.waitingPatients.isNotEmpty) {
                  await provider.refreshQueue();
                }
              },
              color: const Color(0xFF7C6FE8),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    if (position > 0)
                      _buildPatientStatusCard(
                        currentPatient!,
                        position,
                        totalInQueue,
                        patientsAhead,
                      )
                    else
                      _buildEmptyQueueCard(),
                    const SizedBox(height: 24),
                    if (position > 0) ...[
                      _buildQuickInfoSection(patientsAhead, currentPatient!),
                      const SizedBox(height: 24),
                      if (patientsAhead > 0) ...[
                        _buildPatientsAheadSection(patients, currentPatientIndex),
                        const SizedBox(height: 24),
                      ],
                    ],
                    _buildWhatsNextSection(currentPatient?.room),
                    const SizedBox(height: 24),
                    _buildHelpButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<PatientModel> _generateDummyPatients() {
    final now = DateTime.now();
    return [
      // Patient ahead - Position 1
      PatientModel(
        id: 'D001',
        name: 'Sarah Mitchell',
        age: 42,
        gender: 'Female',
        phone: '555-0201',
        address: '456 Oak Ave',
        emergencyLevel: 'High',
        symptoms: 'Severe chest pain, difficulty breathing',
        symptomChecks: {'chest_pain': true, 'breathing': true},
        vitals: VitalSigns(
          spO2: 91,
          pulse: 115,
          temperature: 37.8,
          bloodPressure: 145,
        ),
        reports: [],
        createdAt: now.subtract(const Duration(minutes: 45)),
        registrationTime: now.subtract(const Duration(minutes: 45)),
        status: 'Pending',
        priority: 'Critical',
        room: 'Room 1',
      ),
      // Patient ahead - Position 2
      PatientModel(
        id: 'D002',
        name: 'James Cooper',
        age: 28,
        gender: 'Male',
        phone: '555-0202',
        address: '789 Pine Rd',
        emergencyLevel: 'Medium',
        symptoms: 'High fever, persistent headache',
        symptomChecks: {'fever': true, 'headache': true},
        vitals: VitalSigns(
          spO2: 96,
          pulse: 95,
          temperature: 39.1,
          bloodPressure: 130,
        ),
        reports: [],
        createdAt: now.subtract(const Duration(minutes: 35)),
        registrationTime: now.subtract(const Duration(minutes: 35)),
        status: 'Pending',
        priority: 'Urgent',
        room: null,
      ),
      // Current User - Position 3
      PatientModel(
        id: 'P001',
        name: 'You',
        age: 35,
        gender: 'Male',
        phone: '555-0100',
        address: '123 Main St',
        emergencyLevel: 'Medium',
        symptoms: 'Routine checkup, mild discomfort',
        symptomChecks: {'checkup': true},
        vitals: VitalSigns(
          spO2: 98,
          pulse: 72,
          temperature: 36.6,
          bloodPressure: 120,
        ),
        reports: [],
        createdAt: now.subtract(const Duration(minutes: 15)),
        registrationTime: now.subtract(const Duration(minutes: 15)),
        status: 'Pending',
        priority: 'Stable',
        room: null,
      ),
      // Patients behind
      PatientModel(
        id: 'D003',
        name: 'Emily Watson',
        age: 55,
        gender: 'Female',
        phone: '555-0203',
        address: '321 Elm St',
        emergencyLevel: 'Low',
        symptoms: 'Minor injury, needs stitches',
        symptomChecks: {'injury': true},
        vitals: VitalSigns(
          spO2: 99,
          pulse: 68,
          temperature: 36.5,
          bloodPressure: 118,
        ),
        reports: [],
        createdAt: now.subtract(const Duration(minutes: 10)),
        registrationTime: now.subtract(const Duration(minutes: 10)),
        status: 'Pending',
        priority: 'Stable',
        room: null,
      ),
      PatientModel(
        id: 'D004',
        name: 'Michael Chen',
        age: 31,
        gender: 'Male',
        phone: '555-0204',
        address: '654 Maple Dr',
        emergencyLevel: 'Low',
        symptoms: 'Follow-up consultation',
        symptomChecks: {'consultation': true},
        vitals: VitalSigns(
          spO2: 98,
          pulse: 70,
          temperature: 36.7,
          bloodPressure: 115,
        ),
        reports: [],
        createdAt: now.subtract(const Duration(minutes: 5)),
        registrationTime: now.subtract(const Duration(minutes: 5)),
        status: 'Pending',
        priority: 'Stable',
        room: null,
      ),
    ];
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C6FE8).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.medical_services, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Queue Status',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              Text(
                'Track your appointment progress',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF7C6FE8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientStatusCard(
      PatientModel patient,
      int position,
      int totalInQueue,
      int patientsAhead,
      ) {
    final progress = 1 - (position / totalInQueue);
    final progressPercent = (progress * 100).round();
    final waitTime = _getEstimatedWaitTime(patient, patientsAhead);

    Color priorityColor;
    IconData priorityIcon;
    String priorityText;

    switch (patient.priority.toLowerCase()) {
      case 'critical':
        priorityColor = const Color(0xFFFF6B9D);
        priorityIcon = Icons.warning_rounded;
        priorityText = 'CRITICAL';
        break;
      case 'urgent':
        priorityColor = const Color(0xFFFFA07A);
        priorityIcon = Icons.priority_high;
        priorityText = 'URGENT';
        break;
      default:
        priorityColor = const Color(0xFF95E1D3);
        priorityIcon = Icons.check_circle_outline;
        priorityText = 'ROUTINE';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FE8).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Patient Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7C6FE8).withOpacity(0.2),
                      const Color(0xFF9D84F5).withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Color(0xFF7C6FE8), size: 32),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Patient ID: ${patient.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Progress Section
          Text(
            'Track My Progress',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),

          // Animated Progress Bar
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress * _progressController.value,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C6FE8).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Started',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$progressPercent% Complete',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7C6FE8),
                        ),
                      ),
                      Text(
                        'Your Turn',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Position Info Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C6FE8).withOpacity(0.1),
                  const Color(0xFF9D84F5).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF7C6FE8).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  icon: Icons.groups,
                  label: 'Position',
                  value: '#$position',
                  color: const Color(0xFF7C6FE8),
                ),
                Container(width: 1.5, height: 45, color: const Color(0xFF7C6FE8).withOpacity(0.3)),
                _buildInfoColumn(
                  icon: Icons.access_time,
                  label: 'Est. Wait',
                  value: waitTime,
                  color: const Color(0xFF7C6FE8),
                ),
                Container(width: 1.5, height: 45, color: const Color(0xFF7C6FE8).withOpacity(0.3)),
                _buildInfoColumn(
                  icon: priorityIcon,
                  label: 'Priority',
                  value: priorityText,
                  color: priorityColor,
                ),
              ],
            ),
          ),

          // Room Assignment (if available)
          if (patient.room != null) ...[
            const SizedBox(height: 18),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF95E1D3).withOpacity(0.8 + (_pulseController.value * 0.2)),
                        const Color(0xFF95E1D3).withOpacity(0.6 + (_pulseController.value * 0.2)),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF95E1D3).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.door_front_door, color: Colors.white, size: 26),
                      const SizedBox(width: 12),
                      Text(
                        'Assigned to ${patient.room}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getEstimatedWaitTime(PatientModel patient, int patientsAhead) {
    // Calculate based on priority and patients ahead
    int baseWaitPerPatient = 15; // minutes

    switch (patient.priority.toLowerCase()) {
      case 'critical':
        return '5 min';
      case 'urgent':
        return '${10 + (patientsAhead * 5)} min';
      default:
        return '${baseWaitPerPatient * (patientsAhead + 1)} min';
    }
  }

  Widget _buildQuickInfoSection(int patientsAhead, PatientModel patient) {
    final waitSince = _getTimeSince(patient.registrationTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Info',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickInfoCard(
                icon: Icons.people_outline,
                title: patientsAhead.toString(),
                subtitle: patientsAhead == 1 ? 'Patient ahead' : 'Patients ahead',
                color: const Color(0xFF7C6FE8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickInfoCard(
                icon: Icons.schedule,
                title: waitSince,
                subtitle: 'Waiting time',
                color: const Color(0xFFFFA07A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTimeSince(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    return '${diff.inMinutes}m';
  }

  Widget _buildPatientsAheadSection(List<PatientModel> allPatients, int currentIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Queue Overview',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF7C6FE8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF7C6FE8).withOpacity(0.3),
                ),
              ),
              child: Text(
                '${allPatients.length} in queue',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7C6FE8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...allPatients.asMap().entries.map((entry) {
          final index = entry.key;
          final patient = entry.value;
          final isCurrentUser = index == currentIndex;
          return _buildPatientQueueCard(patient, index + 1, isCurrentUser);
        }).toList(),
      ],
    );
  }

  Widget _buildPatientQueueCard(PatientModel patient, int position, bool isCurrentUser) {
    Color priorityColor;
    switch (patient.priority.toLowerCase()) {
      case 'critical':
        priorityColor = const Color(0xFFFF6B9D);
        break;
      case 'urgent':
        priorityColor = const Color(0xFFFFA07A);
        break;
      default:
        priorityColor = const Color(0xFF95E1D3);
    }

    // Show real name only for current user, otherwise use generic label
    final displayName = isCurrentUser ? patient.name : 'Patient ${patient.id}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFF7C6FE8).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFF7C6FE8)
              : priorityColor.withOpacity(0.3),
          width: isCurrentUser ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
                ? const Color(0xFF7C6FE8).withOpacity(0.2)
                : priorityColor.withOpacity(0.1),
            blurRadius: isCurrentUser ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isCurrentUser
                  ? const LinearGradient(
                colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
              )
                  : LinearGradient(
                colors: [priorityColor, priorityColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#$position',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Patient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C6FE8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'YOU',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${_getTimeSince(patient.registrationTime)} wait',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Priority Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              patient.priority.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Room status
          if (patient.room != null) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: 'In ${patient.room}',
              child: Icon(
                Icons.door_front_door,
                color: const Color(0xFF95E1D3),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWhatsNextSection(String? room) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7C6FE8).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FE8).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF7C6FE8), size: 24),
              const SizedBox(width: 8),
              Text(
                "What's Next?",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (room != null)
            _buildNextStep(
              icon: Icons.meeting_room,
              text: 'Please proceed to $room. A doctor will see you shortly.',
              iconColor: const Color(0xFF95E1D3),
            )
          else
            _buildNextStep(
              icon: Icons.event_seat,
              text: 'Please remain in the waiting area. You\'ll be called soon!',
              iconColor: const Color(0xFFFFA07A),
            ),
          const SizedBox(height: 12),
          _buildNextStep(
            icon: Icons.notifications_active,
            text: 'We\'ll notify you when it\'s your turn',
            iconColor: const Color(0xFF7C6FE8),
          ),
          const SizedBox(height: 12),
          _buildNextStep(
            icon: Icons.phone,
            text: 'Keep your phone handy for updates',
            iconColor: const Color(0xFFFF6B9D),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStep({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpButton() {
    return Center(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF7C6FE8), width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          // Show help dialog
          _showHelpDialog();
        },
        icon: const Icon(Icons.support_agent, color: Color(0xFF7C6FE8)),
        label: Text(
          "Need Help?",
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3E50),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.support_agent, color: const Color(0xFF7C6FE8)),
            const SizedBox(width: 12),
            Text(
              'Contact Support',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelpOption(
              icon: Icons.phone,
              title: 'Call Helpdesk',
              subtitle: '+1 (555) 123-4567',
              onTap: () {
                // Handle phone call
              },
            ),
            const SizedBox(height: 12),
            _buildHelpOption(
              icon: Icons.chat_bubble_outline,
              title: 'AI Live Chat',
              subtitle: 'Chat with our multilingual AI assistant',
              onTap: () {
                Navigator.pop(context);
                _showAIChatbot();
              },
            ),
            const SizedBox(height: 12),
            _buildHelpOption(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@hospital.com',
              onTap: () {
                // Handle email
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: const Color(0xFF7C6FE8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAIChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIChatbotScreen(aiService: widget.aiService),
      ),
    );
  }

  Widget _buildHelpOption({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF7C6FE8).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF7C6FE8).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF7C6FE8), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: const Color(0xFF7C6FE8), size: 16),
          ],
        ),
      ),
    );
  }
}

class AIChatbotScreen extends StatefulWidget {
  final OpenAIService aiService;
  const AIChatbotScreen({Key? key, required this.aiService}) : super(key: key);
  @override
  _AIChatbotScreenState createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  String _selectedLanguage = 'English';
  bool _isTyping = false;

  final Map<String, String> _languages = {
    'English': '🇬🇧',
    'Spanish': '🇪🇸',
    'Hindi': '🇮🇳',
    'Chinese': '🇨🇳',
    'Arabic': '🇸🇦',
    'French': '🇫🇷',
  };

  @override
  void initState() {
    super.initState();
    // Send welcome message
    _addBotMessage(_getWelcomeMessage());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getWelcomeMessage() {
    switch (_selectedLanguage) {
      case 'Spanish':
        return '¡Hola! Soy tu asistente virtual. ¿Cómo puedo ayudarte hoy?';
      case 'Hindi':
        return 'नमस्ते! मैं आपका वर्चुअल सहायक हूं। आज मैं आपकी कैसे मदद कर सकता हूं?';
      case 'Chinese':
        return '你好！我是您的虚拟助手。今天我能帮您什么？';
      case 'Arabic':
        return 'مرحبا! أنا مساعدك الافتراضي. كيف يمكنني مساعدتك اليوم؟';
      case 'French':
        return 'Bonjour! Je suis votre assistant virtuel. Comment puis-je vous aider aujourd\'hui?';
      default:
        return 'Hello! I\'m your virtual assistant. How can I help you today?';
    }
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    setState(() => _isTyping = true);

    // Simulate AI response delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate AI response based on message
    final response = _generateAIResponse(message.toLowerCase());

    setState(() => _isTyping = false);
    _addBotMessage(response);
  }

  String _generateAIResponse(String message) {
    // Simple keyword-based responses (in production, use actual AI API)
    if (message.contains('wait') || message.contains('time') || message.contains('long')) {
      return _translateResponse('Your estimated wait time is based on current queue position and priority. Critical cases are seen first.');
    } else if (message.contains('position') || message.contains('queue')) {
      return _translateResponse('You can check your current position in the main queue screen. Your position updates automatically.');
    } else if (message.contains('room') || message.contains('assigned')) {
      return _translateResponse('You will be notified when a room is assigned to you. Please wait in the waiting area.');
    } else if (message.contains('priority') || message.contains('urgent')) {
      return _translateResponse('Priority is assigned based on medical urgency. Critical and urgent cases are prioritized.');
    } else if (message.contains('cancel') || message.contains('reschedule')) {
      return _translateResponse('To cancel or reschedule, please contact our helpdesk at +1 (555) 123-4567.');
    } else if (message.contains('doctor') || message.contains('specialist')) {
      return _translateResponse('You will be assigned to the next available appropriate specialist based on your symptoms.');
    } else {
      return _translateResponse('I\'m here to help! You can ask about wait times, queue position, room assignments, or any other questions.');
    }
  }

  String _translateResponse(String englishText) {
    // In production, integrate with translation API
    // For now, return basic translations for demo
    switch (_selectedLanguage) {
      case 'Spanish':
        return 'Estoy aquí para ayudar. ' + englishText;
      case 'Hindi':
        return 'मैं मदद के लिए यहाँ हूँ। ' + englishText;
      case 'Chinese':
        return '我在这里帮助您。 ' + englishText;
      case 'Arabic':
        return 'أنا هنا للمساعدة. ' + englishText;
      case 'French':
        return 'Je suis là pour vous aider. ' + englishText;
      default:
        return englishText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C6FE8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Row(
              children: [
                Text(
                  _languages[_selectedLanguage]!,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
            onSelected: (language) {
              setState(() {
                _selectedLanguage = language;
                _messages.clear();
                _addBotMessage(_getWelcomeMessage());
              });
            },
            itemBuilder: (context) => _languages.entries
                .map((entry) => PopupMenuItem(
              value: entry.key,
              child: Row(
                children: [
                  Text(entry.value, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(entry.key, style: GoogleFonts.poppins()),
                ],
              ),
            ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction('Wait Time', Icons.access_time),
                  _buildQuickAction('My Position', Icons.pin_drop),
                  _buildQuickAction('Room Status', Icons.meeting_room),
                  _buildQuickAction('Contact Doctor', Icons.medical_services),
                ],
              ),
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypingDot(0),
                        const SizedBox(width: 4),
                        _buildTypingDot(200),
                        const SizedBox(width: 4),
                        _buildTypingDot(400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FE),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _sendMessage(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF7C6FE8).withOpacity(0.1),
                const Color(0xFF9D84F5).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF7C6FE8).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF7C6FE8), size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7C6FE8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                  colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
                )
                    : null,
                color: message.isUser ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser
                        ? const Color(0xFF7C6FE8).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: message.isUser ? Colors.white : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: message.isUser
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF7C6FE8).withOpacity(0.2),
              child: const Icon(Icons.person, color: Color(0xFF7C6FE8), size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF7C6FE8).withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

Widget _buildEmptyQueueCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF7C6FE8).withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(Icons.event_available, color: Colors.grey[400], size: 64),
        const SizedBox(height: 16),
        Text(
          'No Active Appointment',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You don\'t have any appointments in the queue right now',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
