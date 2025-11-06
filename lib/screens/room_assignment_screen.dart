import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../models/room_model.dart';

class RoomsScreen extends StatefulWidget {
  static const routeName = '/patient-room-view';
  final dynamic patient;

  const RoomsScreen({Key? key, this.patient}) : super(key: key);

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  bool _isLoading = true;
  RoomModel? _assignedRoom;
  Map<String, dynamic>? _aiAnalysis;

  @override
  void initState() {
    super.initState();
    _loadRoomAssignment();
  }

  Future<void> _loadRoomAssignment() async {
    setState(() => _isLoading = true);

    try {
      await Provider.of<RoomProvider>(context, listen: false).fetchRooms();
      await Future.delayed(const Duration(seconds: 2));

      final rooms = Provider.of<RoomProvider>(context, listen: false).rooms;

      if (widget.patient != null) {
        final patientId = widget.patient.id?.toString() ?? '';
        _assignedRoom = rooms.firstWhere(
              (room) => room.patientId == patientId,
          orElse: () => rooms.first,
        );
      } else {
        _assignedRoom = rooms.isNotEmpty ? rooms.first : null;
      }

      _aiAnalysis = _generateAIAnalysis();
    } catch (e) {
      print('Error loading room assignment: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _generateAIAnalysis() {
    return {
      'riskLevel': 'Moderate',
      'recommendations': [
        'Room with cardiac monitoring equipment',
        'Close to nursing station',
        'Quiet environment recommended',
      ],
      'priorityScore': 7.5,
      'estimatedStayDuration': '3-5 days',
      'roomFeatures': [
        'Private bathroom',
        'Adjustable bed',
        'Emergency call button',
        'TV and WiFi',
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Room Assignment',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF9D84F5)),
              const SizedBox(height: 20),
              Text(
                'AI is analyzing your requirements...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF9D84F5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadRoomAssignment,
        color: const Color(0xFF9D84F5),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientInfo(),
              const SizedBox(height: 20),
              _buildAIAnalysisCard(),
              const SizedBox(height: 20),
              _buildAssignedRoomCard(),
              const SizedBox(height: 20),
              _buildRoomFeaturesCard(),
              const SizedBox(height: 20),
              _buildAllRoomsStatus(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Room Assignment',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF9D84F5)),
          onPressed: _loadRoomAssignment,
        ),
      ],
    );
  }

  Widget _buildPatientInfo() {
    final patientName = widget.patient?.name?.toString() ?? 'John Doe';
    final patientId = widget.patient?.id?.toString() ?? 'P001';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B5CE7), Color(0xFF9D84F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9D84F5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Patient ID: $patientId',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9D84F5).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9D84F5).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology, color: Color(0xFF9D84F5), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Analysis',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Risk Level',
            _aiAnalysis?['riskLevel'] ?? 'Moderate',
            _getRiskColor(_aiAnalysis?['riskLevel'] ?? 'Moderate'),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Priority Score',
            '${_aiAnalysis?['priorityScore'] ?? 7.5}/10',
            const Color(0xFF9D84F5),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Estimated Stay',
            _aiAnalysis?['estimatedStayDuration'] ?? '3-5 days',
            Colors.grey[700]!,
          ),
          const SizedBox(height: 16),
          Text(
            'AI Recommendations:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...(_aiAnalysis?['recommendations'] as List<String>? ?? []).map(
                (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Color(0xFF5EEAD4)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedRoomCard() {
    if (_assignedRoom == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFA500).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFFFA500), size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'No room assigned yet. Our AI system is finding the best room for you.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final statusColor = _getStatusColor(_assignedRoom!.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9D84F5).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Assigned Room',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _assignedRoom!.status,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6B5CE7).withOpacity(0.3),
                    const Color(0xFF9D84F5).withOpacity(0.3),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Text(
                _assignedRoom!.number,
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF9D84F5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildRoomDetailRow(Icons.layers, 'Floor', _assignedRoom!.floor),
          _buildRoomDetailRow(Icons.apartment, 'Type', _assignedRoom!.type ?? 'General'),
          if (_assignedRoom!.assignedTime != null)
            _buildRoomDetailRow(
              Icons.access_time,
              'Assigned On',
              _formatDateTime(_assignedRoom!.assignedTime!),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomFeaturesCard() {
    final features = _aiAnalysis?['roomFeatures'] as List<String>? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9D84F5).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room Features & Amenities',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: features.map((feature) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5EEAD4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF5EEAD4).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Color(0xFF5EEAD4)),
                    const SizedBox(width: 6),
                    Text(
                      feature,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAllRoomsStatus() {
    final roomProvider = Provider.of<RoomProvider>(context);
    final rooms = roomProvider.rooms;
    final allRooms = _addDummyRoomsForDisplay(rooms);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9D84F5).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Room Status',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusIndicator(
                'Available',
                _countRoomsByStatus(allRooms, 'Available'),
                const Color(0xFF10B981),
              ),
              _buildStatusIndicator(
                'Occupied',
                _countRoomsByStatus(allRooms, 'Occupied'),
                const Color(0xFFEF4444),
              ),
              _buildStatusIndicator(
                'Cleaning',
                _countRoomsByStatus(allRooms, 'Cleaning'),
                const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'All Rooms',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...allRooms.map((room) => _buildRoomListItem(room)),
        ],
      ),
    );
  }

  List<RoomModel> _addDummyRoomsForDisplay(List<RoomModel> existingRooms) {
    final displayRooms = List<RoomModel>.from(existingRooms);

    final dummyRooms = [
      RoomModel(
        id: 'D101',
        number: '101',
        floor: 'Floor 1',
        status: 'Available',
        type: 'Private',
      ),
      RoomModel(
        id: 'D102',
        number: '102',
        floor: 'Floor 1',
        status: 'Occupied',
        type: 'General',
        patientName: 'Sarah Johnson',
        patientId: 'P102',
        assignedTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RoomModel(
        id: 'D201',
        number: '201',
        floor: 'Floor 2',
        status: 'Cleaning',
        type: 'ICU',
      ),
      RoomModel(
        id: 'D202',
        number: '202',
        floor: 'Floor 2',
        status: 'Maintenance',
        type: 'Private',
      ),
      RoomModel(
        id: 'D301',
        number: '301',
        floor: 'Floor 3',
        status: 'Available',
        type: 'General',
      ),
    ];

    for (var dummyRoom in dummyRooms) {
      if (!displayRooms.any((r) => r.id == dummyRoom.id)) {
        displayRooms.add(dummyRoom);
      }
    }

    displayRooms.sort((a, b) => a.number.compareTo(b.number));
    return displayRooms;
  }

  int _countRoomsByStatus(List<RoomModel> rooms, String status) {
    return rooms.where((r) => r.status == status).length;
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomListItem(RoomModel room) {
    final statusColor = _getStatusColor(room.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Room ${room.number} (${room.floor})',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              room.status,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return const Color(0xFF10B981);
      case 'Occupied':
        return const Color(0xFFEF4444);
      case 'Cleaning':
        return const Color(0xFFF59E0B);
      case 'Maintenance':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF9D84F5);
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return const Color(0xFF10B981);
      case 'moderate':
        return const Color(0xFFF59E0B);
      case 'high':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF9D84F5);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
