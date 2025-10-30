// lib/screens/existing_patient_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_provider.dart';
import '../models/patient_model.dart';

class ExistingPatientScreen extends StatefulWidget {
  static const routeName = '/existing';
  const ExistingPatientScreen({Key? key}) : super(key: key);

  @override
  State<ExistingPatientScreen> createState() => _ExistingPatientScreenState();
}

class _ExistingPatientScreenState extends State<ExistingPatientScreen> {
  String? _selectedPatientId;
  bool _uploading = false;

  Future<void> _pickFileAndUpload(PatientProvider provider) async {
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a patient first')));
      return;
    }
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    final file = File(path);

    setState(() => _uploading = true);
    final urls = await provider.uploadReport(file, _selectedPatientId!);
    setState(() => _uploading = false);
    if (urls != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PatientProvider>(context);
    final patients = provider.patients;

    return Scaffold(
      appBar: AppBar(
        title: Text('Existing Patient - Reports', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            DropdownButtonFormField<String>(
              value: _selectedPatientId,
              items: patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
              onChanged: (v) => setState(() => _selectedPatientId = v),
              decoration: const InputDecoration(labelText: 'Select Patient'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _uploading ? null : () => _pickFileAndUpload(provider),
                    icon: const Icon(Icons.upload_file),
                    label: _uploading ? const CircularProgressIndicator(color: Colors.white) : Text('Upload Report', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => provider.refreshQueue(),
                  child: const Icon(Icons.refresh),
                ),
              )
            ]),
            const SizedBox(height: 18),
            Expanded(
              child: _selectedPatientId == null
                  ? Center(child: Text('Select a patient to view uploaded reports', style: GoogleFonts.inter(color: Colors.grey[600])))
                  : FutureBuilder(
                future: Future.value(provider.patients.firstWhere((p) => p.id == _selectedPatientId, orElse: () => PatientModel(id: '', name: 'Unknown', gender: 'N/A'))),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final patient = snapshot.data as PatientModel;
                  final reports = patient.reports ?? [];
                  if (reports.isEmpty) {
                    return Center(child: Text('No uploaded reports', style: GoogleFonts.inter(color: Colors.grey[600])));
                  }
                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (ctx, i) {
                      final url = reports[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
                        child: Row(children: [
                          const Icon(Icons.insert_drive_file),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Report ${i + 1}', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                          IconButton(onPressed: () {/* TODO: download or view URL */}, icon: const Icon(Icons.open_in_new))
                        ]),
                      );
                    },
                  );
                },
              ),
            )
          ]),
        ),
      ),
    );
  }
}
