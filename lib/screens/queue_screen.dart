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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isMediumScreen = size.width >= 360 && size.width < 600;

    return Consumer<PatientProvider>(
      builder: (context, provider, _) {
        final patients = provider.waitingPatients.isEmpty
            ? _generateDummyPatients()
            : provider.waitingPatients;

        final currentPatientIndex = patients.indexWhere(
                (p) => p.id == 'P001' || p.name == 'You'
        );
        final currentPatient = currentPatientIndex != -1
            ? patients[currentPatientIndex]
            : null;
        final position = currentPatientIndex != -1 ? currentPatientIndex + 1 : 0;
        final totalInQueue = patients.length + 2;
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
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(size),
                    SizedBox(height: size.height * 0.03),
                    if (position > 0)
                      _buildPatientStatusCard(
                        size,
                        currentPatient!,
                        position,
                        totalInQueue,
                        patientsAhead,
                      )
                    else
                      _buildEmptyQueueCard(size),
                    SizedBox(height: size.height * 0.025),
                    if (position > 0) ...[
                      _buildQuickInfoSection(size, patientsAhead, currentPatient!),
                      SizedBox(height: size.height * 0.025),
                      if (patientsAhead > 0) ...[
                        _buildPatientsAheadSection(size, patients, currentPatientIndex),
                        SizedBox(height: size.height * 0.025),
                      ],
                    ],
                    _buildWhatsNextSection(size, currentPatient?.room),
                    SizedBox(height: size.height * 0.025),
                    _buildHelpButton(size),
                    SizedBox(height: size.height * 0.02),
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
    ];
  }

  Widget _buildHeader(Size size) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(size.width * 0.03),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
            ),
            borderRadius: BorderRadius.circular(size.width * 0.03),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C6FE8).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.medical_services,
            color: Colors.white,
            size: size.width * 0.07,
          ),
        ),
        SizedBox(width: size.width * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Queue Status',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.055,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              Text(
                'Track your appointment progress',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.032,
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
      Size size,
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
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.06),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF7C6FE8).withOpacity(0.2),
                      const Color(0xFF9D84F5).withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: const Color(0xFF7C6FE8),
                  size: size.width * 0.08,
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.055,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Patient ID: ${patient.id}',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.03,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.03),
          Text(
            'Track My Progress',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.038,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: size.height * 0.02),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: size.height * 0.015,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress * _progressController.value,
                        child: Container(
                          height: size.height * 0.015,
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
                  SizedBox(height: size.height * 0.012),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Started',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.028,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$progressPercent% Complete',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.032,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7C6FE8),
                        ),
                      ),
                      Text(
                        'Your Turn',
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.028,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: size.height * 0.03),
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7C6FE8).withOpacity(0.1),
                  const Color(0xFF9D84F5).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(size.width * 0.04),
              border: Border.all(
                color: const Color(0xFF7C6FE8).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn(
                  size,
                  icon: Icons.groups,
                  label: 'Position',
                  value: '#$position',
                  color: const Color(0xFF7C6FE8),
                ),
                Container(
                  width: 1.5,
                  height: size.height * 0.05,
                  color: const Color(0xFF7C6FE8).withOpacity(0.3),
                ),
                _buildInfoColumn(
                  size,
                  icon: Icons.access_time,
                  label: 'Est. Wait',
                  value: waitTime,
                  color: const Color(0xFF7C6FE8),
                ),
                Container(
                  width: 1.5,
                  height: size.height * 0.05,
                  color: const Color(0xFF7C6FE8).withOpacity(0.3),
                ),
                _buildInfoColumn(
                  size,
                  icon: priorityIcon,
                  label: 'Priority',
                  value: priorityText,
                  color: priorityColor,
                ),
              ],
            ),
          ),
          if (patient.room != null) ...[
            SizedBox(height: size.height * 0.02),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF95E1D3).withOpacity(
                          0.8 + (_pulseController.value * 0.2),
                        ),
                        const Color(0xFF95E1D3).withOpacity(
                          0.6 + (_pulseController.value * 0.2),
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(size.width * 0.04),
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
                      Icon(
                        Icons.door_front_door,
                        color: Colors.white,
                        size: size.width * 0.06,
                      ),
                      SizedBox(width: size.width * 0.03),
                      Text(
                        'Assigned to ${patient.room}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: size.width * 0.05,
                      ),
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

  Widget _buildInfoColumn(
      Size size, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    return Column(
      children: [
        Icon(icon, color: color, size: size.width * 0.07),
        SizedBox(height: size.height * 0.008),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.028,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getEstimatedWaitTime(PatientModel patient, int patientsAhead) {
    int baseWaitPerPatient = 15;
    switch (patient.priority.toLowerCase()) {
      case 'critical':
        return '5 min';
      case 'urgent':
        return '${10 + (patientsAhead * 5)} min';
      default:
        return '${baseWaitPerPatient * (patientsAhead + 1)} min';
    }
  }

  Widget _buildQuickInfoSection(Size size, int patientsAhead, PatientModel patient) {
    final waitSince = _getTimeSince(patient.registrationTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Info',
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Row(
          children: [
            Expanded(
              child: _buildQuickInfoCard(
                size,
                icon: Icons.people_outline,
                title: patientsAhead.toString(),
                subtitle: patientsAhead == 1 ? 'Patient ahead' : 'Patients ahead',
                color: const Color(0xFF7C6FE8),
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: _buildQuickInfoCard(
                size,
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

  Widget _buildQuickInfoCard(
      Size size, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
      }) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
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
          Icon(icon, color: color, size: size.width * 0.08),
          SizedBox(height: size.height * 0.01),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.048,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.028,
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

  Widget _buildPatientsAheadSection(Size size, List<PatientModel> allPatients, int currentIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Queue Overview',
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.008,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF7C6FE8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(size.width * 0.03),
                border: Border.all(
                  color: const Color(0xFF7C6FE8).withOpacity(0.3),
                ),
              ),
              child: Text(
                '${allPatients.length} in queue',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.028,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7C6FE8),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.015),
        ...allPatients.asMap().entries.map((entry) {
          final index = entry.key;
          final patient = entry.value;
          final isCurrentUser = index == currentIndex;
          return _buildPatientQueueCard(size, patient, index + 1, isCurrentUser);
        }).toList(),
      ],
    );
  }

  Widget _buildPatientQueueCard(Size size, PatientModel patient, int position, bool isCurrentUser) {
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

    final displayName = isCurrentUser ? patient.name : 'Patient ${patient.id}';

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFF7C6FE8).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
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
          Container(
            width: size.width * 0.1,
            height: size.width * 0.1,
            decoration: BoxDecoration(
              gradient: isCurrentUser
                  ? const LinearGradient(
                colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
              )
                  : LinearGradient(
                colors: [priorityColor, priorityColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(size.width * 0.025),
            ),
            child: Center(
              child: Text(
                '#$position',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.038,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: GoogleFonts.poppins(
                          fontSize: size.width * 0.036,
                          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      SizedBox(width: size.width * 0.02),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.02,
                          vertical: size.height * 0.004,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C6FE8),
                          borderRadius: BorderRadius.circular(size.width * 0.02),
                        ),
                        child: Text(
                          'YOU',
                          style: GoogleFonts.poppins(
                            fontSize: size.width * 0.024,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: size.height * 0.004),
                Row(
                  children: [
                    Icon(Icons.access_time, size: size.width * 0.032, color: Colors.grey[600]),
                    SizedBox(width: size.width * 0.01),
                    Text(
                      '${_getTimeSince(patient.registrationTime)} wait',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.028,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.025,
              vertical: size.height * 0.006,
            ),
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(size.width * 0.03),
            ),
            child: Text(
              patient.priority.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.024,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (patient.room != null) ...[
            SizedBox(width: size.width * 0.02),
            Icon(
              Icons.door_front_door,
              color: const Color(0xFF95E1D3),
              size: size.width * 0.05,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWhatsNextSection(Size size, String? room) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.05),
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
              Icon(
                Icons.info_outline,
                color: const Color(0xFF7C6FE8),
                size: size.width * 0.06,
              ),
              SizedBox(width: size.width * 0.02),
              Text(
                "What's Next?",
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          if (room != null)
            _buildNextStep(
              size,
              icon: Icons.meeting_room,
              text: 'Please proceed to $room. A doctor will see you shortly.',
              iconColor: const Color(0xFF95E1D3),
            )
          else
            _buildNextStep(
              size,
              icon: Icons.event_seat,
              text: 'Please remain in the waiting area. You\'ll be called soon!',
              iconColor: const Color(0xFFFFA07A),
            ),
          SizedBox(height: size.height * 0.015),
          _buildNextStep(
            size,
            icon: Icons.notifications_active,
            text: 'We\'ll notify you when it\'s your turn',
            iconColor: const Color(0xFF7C6FE8),
          ),
          SizedBox(height: size.height * 0.015),
          _buildNextStep(
            size,
            icon: Icons.phone,
            text: 'Keep your phone handy for updates',
            iconColor: const Color(0xFFFF6B9D),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStep(
      Size size, {
        required IconData icon,
        required String text,
        required Color iconColor,
      }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(size.width * 0.025),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(size.width * 0.025),
          ),
          child: Icon(icon, color: iconColor, size: size.width * 0.05),
        ),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.032,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpButton(Size size) {
    return Center(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF7C6FE8), width: 2),
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.018,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.04),
          ),
        ),
        onPressed: () => _showHelpDialog(size),
        icon: Icon(
          Icons.support_agent,
          color: const Color(0xFF7C6FE8),
          size: size.width * 0.06,
        ),
        label: Text(
          "Need Help?",
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3E50),
            fontSize: size.width * 0.038,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(Size size) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.05),
        ),
        title: Row(
          children: [
            Icon(
              Icons.support_agent,
              color: const Color(0xFF7C6FE8),
              size: size.width * 0.06,
            ),
            SizedBox(width: size.width * 0.03),
            Text(
              'Contact Support',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: size.width * 0.045,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelpOption(
              size,
              icon: Icons.phone,
              title: 'Call Helpdesk',
              subtitle: '+1 (555) 123-4567',
              onTap: () {},
            ),
            SizedBox(height: size.height * 0.015),
            _buildHelpOption(
              size,
              icon: Icons.chat_bubble_outline,
              title: 'AI Live Chat',
              subtitle: 'Chat with our multilingual AI assistant',
              onTap: () {
                Navigator.pop(context);
                _showAIChatbot();
              },
            ),
            SizedBox(height: size.height * 0.015),
            _buildHelpOption(
              size,
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@hospital.com',
              onTap: () {},
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
                fontSize: size.width * 0.036,
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

  Widget _buildHelpOption(
      Size size, {
        required IconData icon,
        required String title,
        required String subtitle,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size.width * 0.03),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: const Color(0xFF7C6FE8).withOpacity(0.1),
          borderRadius: BorderRadius.circular(size.width * 0.03),
          border: Border.all(
            color: const Color(0xFF7C6FE8).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF7C6FE8), size: size.width * 0.07),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.034,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.028,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF7C6FE8),
              size: size.width * 0.04,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyQueueCard(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.06),
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
          Icon(
            Icons.event_available,
            color: Colors.grey[400],
            size: size.width * 0.16,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'No Active Appointment',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.048,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            'You don\'t have any appointments in the queue right now',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.032,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// AI Chatbot Screen
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

    await Future.delayed(const Duration(seconds: 1));

    final response = _generateAIResponse(message.toLowerCase());

    setState(() => _isTyping = false);
    _addBotMessage(response);
  }

  String _generateAIResponse(String message) {
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
    final size = MediaQuery.of(context).size;

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
              padding: EdgeInsets.all(size.width * 0.02),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: size.width * 0.05,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.026,
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
                  style: TextStyle(fontSize: size.width * 0.05),
                ),
                SizedBox(width: size.width * 0.01),
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
                  Text(entry.value, style: TextStyle(fontSize: size.width * 0.05)),
                  SizedBox(width: size.width * 0.03),
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
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction(size, 'Wait Time', Icons.access_time),
                  _buildQuickAction(size, 'My Position', Icons.pin_drop),
                  _buildQuickAction(size, 'Room Status', Icons.meeting_room),
                  _buildQuickAction(size, 'Contact Doctor', Icons.medical_services),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(size.width * 0.04),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(size, _messages[index]);
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(size.width * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(size.width * 0.05),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypingDot(0),
                        SizedBox(width: size.width * 0.01),
                        _buildTypingDot(200),
                        SizedBox(width: size.width * 0.01),
                        _buildTypingDot(400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
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
                    style: GoogleFonts.poppins(fontSize: size.width * 0.036),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FE),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.06),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.015,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    iconSize: size.width * 0.06,
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

  Widget _buildQuickAction(Size size, String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(right: size.width * 0.02),
      child: InkWell(
        onTap: () => _sendMessage(label),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.01,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF7C6FE8).withOpacity(0.1),
                const Color(0xFF9D84F5).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(size.width * 0.05),
            border: Border.all(
              color: const Color(0xFF7C6FE8).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF7C6FE8), size: size.width * 0.045),
              SizedBox(width: size.width * 0.02),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.032,
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

  Widget _buildMessageBubble(Size size, ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.02),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: EdgeInsets.all(size.width * 0.02),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: size.width * 0.05,
              ),
            ),
            SizedBox(width: size.width * 0.03),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                  colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
                )
                    : null,
                color: message.isUser ? null : Colors.white,
                borderRadius: BorderRadius.circular(size.width * 0.05),
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
                      fontSize: size.width * 0.034,
                      color: message.isUser ? Colors.white : const Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: size.width * 0.024,
                      color: message.isUser ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: size.width * 0.03),
            CircleAvatar(
              radius: size.width * 0.045,
              backgroundColor: const Color(0xFF7C6FE8).withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: const Color(0xFF7C6FE8),
                size: size.width * 0.05,
              ),
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