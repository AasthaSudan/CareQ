import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_provider.dart';
import '../models/patient_model.dart';
import '../theme.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../services/pdf_service.dart';
import 'update_patient_screen.dart';

class ExistingPatientScreen extends StatefulWidget {
  @override
  _ExistingPatientScreenState createState() => _ExistingPatientScreenState();
}

class _ExistingPatientScreenState extends State<ExistingPatientScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final provider = Provider.of<PatientProvider>(context, listen: false);
    await provider.refreshQueue();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context);
    final patients = provider.patients
        .where((p) =>
    p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.id.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Color(0xFF7C6FE8)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Existing Patients',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: const Color(0xFF2C3E50),
              ),
            ),
            Text(
              '${patients.length} patients found',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or ID...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF7C6FE8)),
                filled: true,
                fillColor: const Color(0xFFFAFBFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: const Color(0xFFE8E8F0), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF7C6FE8), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Patient List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPatients,
              color: const Color(0xFF7C6FE8),
              child: provider.loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C6FE8)))
                  : patients.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.folder_open_rounded,
                        size: 60,
                        color: const Color(0xFF7C6FE8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No patients found',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  return _buildPatientCard(patients[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(PatientModel p) {
    Color priorityColor = _getPriorityColor(p.emergencyLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: priorityColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: priorityColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPatientDetails(p),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7C6FE8),
                        const Color(0xFF9B8AFF),
                      ],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: p.photoUrl != null && p.photoUrl!.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(p.photoUrl!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: p.photoUrl == null || p.photoUrl!.isEmpty
                        ? Icon(Icons.person, color: const Color(0xFF7C6FE8), size: 30)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                // Patient Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${p.id}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Age: ${p.age} • ${p.gender}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Priority Badge
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: priorityColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        p.emergencyLevel.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPatientDetails(PatientModel p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Profile Photo
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C6FE8), Color(0xFF9B8AFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C6FE8).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: p.photoUrl != null
                          ? DecorationImage(
                        image: NetworkImage(p.photoUrl!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: p.photoUrl == null
                        ? const Icon(Icons.person, size: 50, color: Color(0xFF7C6FE8))
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  p.name,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getPriorityColor(p.emergencyLevel),
                        _getPriorityColor(p.emergencyLevel).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getPriorityColor(p.emergencyLevel).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Priority: ${p.emergencyLevel.toUpperCase()}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Patient Information
              _buildSectionHeader('Patient Information', Icons.person_rounded),
              const SizedBox(height: 16),
              _buildInfoCard([
                _infoRow('Patient ID', p.id),
                _infoRow('Age', '${p.age} years'),
                _infoRow('Gender', p.gender),
                _infoRow('Phone', p.phone),
                _infoRow('Address', p.address),
                _infoRow('Registration', DateFormat('MMM dd, yyyy').format(p.registrationTime)),
              ]),
              const SizedBox(height: 24),

              // Medical Information
              _buildSectionHeader('Medical Information', Icons.medical_services_rounded),
              const SizedBox(height: 16),
              _buildInfoCard([
                _infoRow('Symptoms', p.symptoms),
                _infoRow('Blood Pressure', p.vitals.bloodPressure?.toString() ?? 'N/A'),
                _infoRow('Pulse', p.vitals.pulse != null ? '${p.vitals.pulse} bpm' : 'N/A'),
                _infoRow('Temperature', p.vitals.temperature != null ? '${p.vitals.temperature}°F' : 'N/A'),
                _infoRow('SpO2', p.vitals.spO2 != null ? '${p.vitals.spO2}%' : 'N/A'),
              ]),
              const SizedBox(height: 24),

              // Reports Section
              _buildSectionHeader('Medical Reports', Icons.description_rounded),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E8F0)),
                ),
                child: Column(
                  children: [
                    if (p.reports.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No reports uploaded',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                        ),
                      )
                    else
                      ...p.reports.map((report) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
                        ),
                        title: Text(report, style: GoogleFonts.poppins(fontSize: 14)),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_rounded, color: Color(0xFF7C6FE8)),
                          onPressed: () {},
                        ),
                      )),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _uploadReport(p),
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Upload New Report'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7C6FE8),
                        side: const BorderSide(color: Color(0xFF7C6FE8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7C6FE8),
                            const Color(0xFF9B8AFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C6FE8).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            PdfService.generatePatientReport(p);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Download',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4ECDC4).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _updatePatientInfo(p),
                          borderRadius: BorderRadius.circular(14),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Update',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF7C6FE8).withOpacity(0.15),
                const Color(0xFF9B8AFF).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF7C6FE8), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadReport(PatientModel patient) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final provider = Provider.of<PatientProvider>(context, listen: false);
        final uploadedUrls = await provider.uploadReport(
          File(result.files.single.path!),
          patient.id,
        );

        if (uploadedUrls != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Report uploaded successfully!'),
              backgroundColor: const Color(0xFF7C6FE8),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading report: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _updatePatientInfo(PatientModel patient) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdatePatientScreen(patient: patient),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical':
        return const Color(0xFFFF6B9D);
      case 'urgent':
        return const Color(0xFFFFA07A);
      default:
        return const Color(0xFF95E1D3);
    }
  }
}