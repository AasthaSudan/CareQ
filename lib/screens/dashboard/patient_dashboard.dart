import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/patient_provider.dart';
import '../../models/patient_model.dart';

class PatientDashboard extends StatefulWidget {
  static const routeName = '/patient-dashboard';
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
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
    final patients = provider.queue;

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Dashboard',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPatients,
        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : patients.isEmpty
            ? const Center(child: Text('No patients in queue'))
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final p = patients[index];
            return _buildPatientCard(p);
          },
        ),
      ),
    );
  }

  Widget _buildPatientCard(PatientModel p) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage:
          p.photoUrl != null && p.photoUrl!.isNotEmpty ? NetworkImage(p.photoUrl!) : null,
          backgroundColor: Colors.grey[200],
          child: p.photoUrl == null || p.photoUrl!.isEmpty
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        title: Text(
          p.name,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Age: ${p.age} • ${p.gender}\nEmergency: ${p.emergencyLevel}',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          onPressed: () => _showPatientDetails(p),
        ),
      ),
    );
  }

  void _showPatientDetails(PatientModel p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: p.photoUrl != null
                          ? NetworkImage(p.photoUrl!)
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: p.photoUrl == null
                          ? const Icon(Icons.person, size: 40, color: Colors.grey)
                          : null,
                    )),
                const SizedBox(height: 12),
                Center(
                  child: Text(p.name,
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text('Emergency: ${p.emergencyLevel}',
                      style: GoogleFonts.inter(color: Colors.redAccent)),
                ),
                const Divider(height: 24),
                _infoRow('Age', p.age.toString()),
                _infoRow('Gender', p.gender),
                _infoRow('Phone', p.phone),
                _infoRow('Address', p.address),
                _infoRow('Symptoms', p.symptoms),
                const SizedBox(height: 10),
                Text('Reports:',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                if (p.reports == null || p.reports!.isEmpty)
                  const Text('No reports uploaded'),
                ...?p.reports?.map(
                      (r) => Text('• $r', style: const TextStyle(color: Colors.blue)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text('$label:',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: GoogleFonts.inter())),
        ],
      ),
    );
  }
}
