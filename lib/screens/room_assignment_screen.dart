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
          orElse: () => rooms.isNotEmpty ? rooms.first : _createDummyRoom(),
        );
      } else {
        _assignedRoom = rooms.isNotEmpty ? rooms.first : _createDummyRoom();
      }

      _aiAnalysis = _generateAIAnalysis();
    } catch (e) {
      print('Error loading room assignment: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  RoomModel _createDummyRoom() {
    return RoomModel(
      id: 'R301',
      number: '301',
      floor: 'Floor 3',
      status: 'Available',
      type: 'Private',
      patientName: 'You',
      patientId: 'P001',
      assignedTime: DateTime.now(),
    );
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
    final size = MediaQuery.of(context).size;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Room Assignment',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: size.width * 0.045,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width * 0.15,
                height: size.width * 0.15,
                child: const CircularProgressIndicator(
                  color: Color(0xFF7C6FE8),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Text(
                'AI is analyzing your requirements...',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.038,
                  color: const Color(0xFF7C6FE8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: _buildAppBar(size),
      body: RefreshIndicator(
        onRefresh: _loadRoomAssignment,
        color: const Color(0xFF7C6FE8),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientInfo(size),
              SizedBox(height: size.height * 0.025),
              _buildAIAnalysisCard(size),
              SizedBox(height: size.height * 0.025),
              _buildAssignedRoomCard(size),
              SizedBox(height: size.height * 0.025),
              _buildRoomFeaturesCard(size),
              SizedBox(height: size.height * 0.025),
              _buildAllRoomsStatus(size),
              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(Size size) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: const Color(0xFF2C3E50),
          size: size.width * 0.06,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Room Assignment',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: size.width * 0.045,
          color: const Color(0xFF2C3E50),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: const Color(0xFF7C6FE8),
            size: size.width * 0.06,
          ),
          onPressed: _loadRoomAssignment,
        ),
      ],
    );
  }

  Widget _buildPatientInfo(Size size) {
    final patientName = widget.patient?.name?.toString() ?? 'You';
    final patientId = widget.patient?.id?.toString() ?? 'P001';

    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C6FE8), Color(0xFF9D84F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size.width * 0.04),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FE8).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: size.width * 0.08,
              color: Colors.white,
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.048,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  'Patient ID: $patientId',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.032,
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

  Widget _buildAIAnalysisCard(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        border: Border.all(color: const Color(0xFF7C6FE8).withOpacity(0.3)),
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
                padding: EdgeInsets.all(size.width * 0.02),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6FE8).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(size.width * 0.02),
                ),
                child: Icon(
                  Icons.psychology,
                  color: const Color(0xFF7C6FE8),
                  size: size.width * 0.05,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Text(
                'AI Analysis',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          _buildInfoRow(
            size,
            'Risk Level',
            _aiAnalysis?['riskLevel'] ?? 'Moderate',
            _getRiskColor(_aiAnalysis?['riskLevel'] ?? 'Moderate'),
          ),
          SizedBox(height: size.height * 0.01),
          _buildInfoRow(
            size,
            'Priority Score',
            '${_aiAnalysis?['priorityScore'] ?? 7.5}/10',
            const Color(0xFF7C6FE8),
          ),
          SizedBox(height: size.height * 0.01),
          _buildInfoRow(
            size,
            'Estimated Stay',
            _aiAnalysis?['estimatedStayDuration'] ?? '3-5 days',
            Colors.grey[700]!,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'AI Recommendations:',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.034,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          ...(_aiAnalysis?['recommendations'] as List<String>? ?? []).map(
                (rec) => Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.008),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: size.width * 0.04,
                    color: const Color(0xFF95E1D3),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: Text(
                      rec,
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.03,
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

  Widget _buildAssignedRoomCard(Size size) {
    if (_assignedRoom == null) {
      return Container(
        padding: EdgeInsets.all(size.width * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size.width * 0.04),
          border: Border.all(color: const Color(0xFFFFA07A).withOpacity(0.3)),
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
            Icon(
              Icons.info_outline,
              color: const Color(0xFFFFA07A),
              size: size.width * 0.075,
            ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Text(
                'No room assigned yet. Our AI system is finding the best room for you.',
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.034,
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
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        border: Border.all(color: const Color(0xFF7C6FE8).withOpacity(0.3)),
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
              Flexible(
                child: Text(
                  'Your Assigned Room',
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.006,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(size.width * 0.05),
                ),
                child: Text(
                  _assignedRoom!.status,
                  style: GoogleFonts.poppins(
                    fontSize: size.width * 0.028,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.025),
          Center(
            child: Container(
              padding: EdgeInsets.all(size.width * 0.06),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7C6FE8).withOpacity(0.3),
                    const Color(0xFF9D84F5).withOpacity(0.3),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Text(
                _assignedRoom!.number,
                style: GoogleFonts.poppins(
                  fontSize: size.width * 0.12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7C6FE8),
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.025),
          _buildRoomDetailRow(
            size,
            Icons.layers,
            'Floor',
            _assignedRoom!.floor,
          ),
          _buildRoomDetailRow(
            size,
            Icons.apartment,
            'Type',
            _assignedRoom!.type ?? 'General',
          ),
          if (_assignedRoom!.assignedTime != null)
            _buildRoomDetailRow(
              size,
              Icons.access_time,
              'Assigned On',
              _formatDateTime(_assignedRoom!.assignedTime!),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomFeaturesCard(Size size) {
    final features = _aiAnalysis?['roomFeatures'] as List<String>? ?? [];

    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        border: Border.all(color: const Color(0xFF7C6FE8).withOpacity(0.3)),
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
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Wrap(
            spacing: size.width * 0.02,
            runSpacing: size.height * 0.01,
            children: features.map((feature) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.008,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF95E1D3).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(size.width * 0.03),
                  border: Border.all(
                    color: const Color(0xFF95E1D3).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: size.width * 0.04,
                      color: const Color(0xFF95E1D3),
                    ),
                    SizedBox(width: size.width * 0.015),
                    Text(
                      feature,
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.03,
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

  Widget _buildAllRoomsStatus(Size size) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final rooms = roomProvider.rooms;
    final allRooms = _addDummyRoomsForDisplay(rooms);

    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        border: Border.all(color: const Color(0xFF7C6FE8).withOpacity(0.3)),
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
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusIndicator(
                size,
                'Available',
                _countRoomsByStatus(allRooms, 'Available'),
                const Color(0xFF95E1D3),
              ),
              _buildStatusIndicator(
                size,
                'Occupied',
                _countRoomsByStatus(allRooms, 'Occupied'),
                const Color(0xFFFF6B9D),
              ),
              _buildStatusIndicator(
                size,
                'Cleaning',
                _countRoomsByStatus(allRooms, 'Cleaning'),
                const Color(0xFFFFA07A),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.025),
          Text(
            'All Rooms',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: size.height * 0.015),
          ...allRooms.map((room) => _buildRoomListItem(size, room)),
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

  Widget _buildStatusIndicator(Size size, String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.03,
            vertical: size.height * 0.008,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(size.width * 0.03),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.028,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomListItem(Size size, RoomModel room) {
    final statusColor = _getStatusColor(room.status);

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(size.width * 0.03),
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
          Flexible(
            child: Text(
              'Room ${room.number} (${room.floor})',
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.034,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.025,
              vertical: size.height * 0.006,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(size.width * 0.05),
            ),
            child: Text(
              room.status,
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.028,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(Size size, String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.034,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.034,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomDetailRow(Size size, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.01),
      child: Row(
        children: [
          Icon(icon, size: size.width * 0.045, color: Colors.grey[700]),
          SizedBox(width: size.width * 0.02),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.034,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: size.width * 0.034,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return const Color(0xFF95E1D3);
      case 'Occupied':
        return const Color(0xFFFF6B9D);
      case 'Cleaning':
        return const Color(0xFFFFA07A);
      case 'Maintenance':
        return const Color(0xFF9D84F5);
      default:
        return const Color(0xFF7C6FE8);
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
        return const Color(0xFF95E1D3);
      case 'moderate':
        return const Color(0xFFFFA07A);
      case 'high':
        return const Color(0xFFFF6B9D);
      default:
        return const Color(0xFF7C6FE8);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}