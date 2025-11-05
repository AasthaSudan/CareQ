import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/patient_model.dart';  // Import your PatientModel
import '../models/vital_signs.dart';

class PdfService {
  static Future<void> generatePatientReport(PatientModel patient) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Emergency Triage Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildSection('Patient Information', [
              'Patient ID: ${patient.id ?? 'N/A'}',
              'Name: ${patient.name ?? 'N/A'}',
              'Age: ${patient.age} years',
              'Gender: ${patient.gender}',
              'Contact: ${patient.phone ?? 'N/A'}',
            ]),
            pw.SizedBox(height: 20),
            _buildSection('Triage Assessment', [
              'Priority: ${patient.priority?.toUpperCase() ?? 'N/A'}',
              'Registration Time: ${patient.registrationTime != null ? DateFormat('MMM dd, yyyy hh:mm a').format(patient.registrationTime!) : 'N/A'}', // No need for .toDate() here
              'Status: ${patient.status ?? 'N/A'}',
            ]),
            pw.SizedBox(height: 20),
            _buildSection('Vital Signs', [
              'Blood Pressure: ${patient.vitals?.bloodPressure ?? 'N/A'}',
              'Pulse Rate: ${patient.vitals?.pulse ?? 'N/A'} bpm',
              'Temperature: ${patient.vitals?.temperature ?? 'N/A'}°F',
              'SpO2: ${patient.vitals?.spO2 ?? 'N/A'}%',
            ]),
            pw.SizedBox(height: 20),
            _buildSection('Symptoms', [
              patient.symptoms ?? 'N/A',
            ]),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static pw.Widget _buildSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        ...items.map((item) => pw.Padding(
          padding: pw.EdgeInsets.only(bottom: 5),
          child: pw.Text(item, style: pw.TextStyle(fontSize: 14)),
        )),
      ],
    );
  }

  static Future<void> generateDailyReport(
      List<PatientModel> patients,
      DateTime date,
      ) async {
    final pdf = pw.Document();
    final critical = patients.where((p) => p.priority == 'critical').length;
    final urgent = patients.where((p) => p.priority == 'urgent').length;
    final stable = patients.where((p) => p.priority == 'stable').length;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Daily Triage Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Text('Date: ${DateFormat('MMMM dd, yyyy').format(date)}'),
            pw.SizedBox(height: 20),
            pw.Text('Summary Statistics',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Total Patients: ${patients.length}'),
            pw.Text('Critical: $critical'),
            pw.Text('Urgent: $urgent'),
            pw.Text('Stable: $stable'),
            pw.SizedBox(height: 20),
            pw.Text('Patient Details',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['ID', 'Name', 'Priority', 'Time'],
              data: patients.map((p) => [
                p.id ?? 'N/A',
                p.name ?? 'N/A',
                p.priority ?? 'N/A',
                p.registrationTime != null ? DateFormat('hh:mm a').format(p.registrationTime!) : 'N/A', // No need for .toDate() here
              ]).toList(),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
