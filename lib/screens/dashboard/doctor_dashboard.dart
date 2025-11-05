import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';
import '../../providers/room_provider.dart';
import '../../widgets/metric_box.dart';
import '../../widgets/section_card.dart';
import '../../theme.dart';
import 'package:intl/intl.dart';
import '../../models/patient_model.dart'; // Import the PatientModel

class DoctorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<PatientProvider, RoomProvider>(
      builder: (context, patientProvider, roomProvider, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metrics Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  MetricBox(
                    icon: Icons.people_rounded,
                    value: '${patientProvider.totalPatients}',
                    label: 'Total Patients',
                    color: AppTheme.primaryPurple,
                  ),
                  MetricBox(
                    icon: Icons.access_time_rounded,
                    value: '${patientProvider.averageWaitTime.toInt()} min',
                    label: 'Avg Wait Time',
                    color: AppTheme.teal,
                  ),
                  MetricBox(
                    icon: Icons.meeting_room_rounded,
                    value: '${roomProvider.availableRooms}/${roomProvider.rooms.length}',
                    label: 'Available Rooms',
                    color: AppTheme.stable,
                  ),
                  MetricBox(
                    icon: Icons.local_hospital_rounded,
                    value: '${patientProvider.criticalPatients.length}',
                    label: 'Critical Cases',
                    color: AppTheme.critical,
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Triage Distribution
              SectionCard(
                title: 'Triage Distribution',
                child: Column(
                  children: [
                    _buildPriorityRow(
                      'Critical',
                      patientProvider.criticalPatients.length,
                      AppTheme.critical,
                    ),
                    SizedBox(height: 12),
                    _buildPriorityRow(
                      'Urgent',
                      patientProvider.urgentPatients.length,
                      AppTheme.urgent,
                    ),
                    SizedBox(height: 12),
                    _buildPriorityRow(
                      'Stable',
                      patientProvider.stablePatients.length,
                      AppTheme.stable,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Recent Registrations
              Text(
                'Recent Registrations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              // Use a ListView.builder for patient cards
              patientProvider.patients.isEmpty
                  ? Center(child: Text('No recent registrations'))
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: patientProvider.patients.take(3).length,
                itemBuilder: (context, index) {
                  final patient = patientProvider.patients[index];
                  return _buildPatientCard(context, patient);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriorityRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Spacer(),
        Text(
          '$count patients',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(BuildContext context, PatientModel patient) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(patient.priority).withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: _getPriorityColor(patient.priority),
          ),
        ),
        title: Text(
          patient.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${patient.age}y • ${patient.id}'),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getPriorityColor(patient.priority),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            patient.priority.toUpperCase(),
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical':
        return AppTheme.critical;
      case 'urgent':
        return AppTheme.urgent;
      default:
        return AppTheme.stable;
    }
  }
}
