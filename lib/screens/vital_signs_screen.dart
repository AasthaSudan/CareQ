// lib/screens/vital_signs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/patient_provider.dart';
import 'ai_analysis_screen.dart';

class VitalSignsScreen extends StatefulWidget {
  static const routeName = '/vitals';
  final String? patientId;
  const VitalSignsScreen({Key? key, this.patientId}) : super(key: key);

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  final TextEditingController _bp = TextEditingController(text: '120/80');
  final TextEditingController _hr = TextEditingController(text: '72');
  final TextEditingController _temp = TextEditingController(text: '98.6');
  final TextEditingController _spo2 = TextEditingController(text: '98');

  bool _saving = false;

  @override
  void dispose() {
    _bp.dispose();
    _hr.dispose();
    _temp.dispose();
    _spo2.dispose();
    super.dispose();
  }

  Future<void> _onAnalyze() async {
    setState(() => _saving = true);
    final provider = Provider.of<PatientProvider>(context, listen: false);
    final patientId = widget.patientId;
    if (patientId != null) {
      await provider.addVitals(patientId, {
        'blood_pressure': _bp.text,
        'heart_rate': _hr.text,
        'temperature': _temp.text,
        'spo2': _spo2.text,
      });
    }
    await Future.delayed(const Duration(milliseconds: 350));
    setState(() => _saving = false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AIAnalysisScreen(patientId: patientId)));
  }

  Widget _vitalRow(String label, TextEditingController ctrl, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700])),
            const SizedBox(height: 6),
            TextFormField(controller: ctrl, decoration: const InputDecoration(border: InputBorder.none)),
          ]),
        ),
        const SizedBox(width: 8),
        Text(unit, style: GoogleFonts.inter(color: Colors.grey[600])),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vital Signs', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            _vitalRow('Blood Pressure', _bp, 'mmHg'),
            const SizedBox(height: 12),
            _vitalRow('Heart Rate', _hr, 'bpm'),
            const SizedBox(height: 12),
            _vitalRow('Temperature', _temp, '°F'),
            const SizedBox(height: 12),
            _vitalRow('Oxygen Level', _spo2, '%'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saving ? null : _onAnalyze,
                child: _saving ? const CircularProgressIndicator(color: Colors.white) : Text('Analyze with AI', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
