import 'package:flutter/material.dart';
import 'package:care_q/models/patient_model.dart';

class PatientDetailsScreen extends StatelessWidget {
  final PatientModel patient;

  PatientDetailsScreen({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${patient.name}', style: TextStyle(fontSize: 18)),
              Text('Age: ${patient.age}', style: TextStyle(fontSize: 18)),
              Text('Gender: ${patient.gender}', style: TextStyle(fontSize: 18)),
              Text('Phone: ${patient.phone}', style: TextStyle(fontSize: 18)),
              Text('Address: ${patient.address}', style: TextStyle(fontSize: 18)),
              Text('Symptoms: ${patient.symptoms}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text('Priority: ${patient.priority}', style: TextStyle(fontSize: 18)),

              // Example of how you can display the patient's vitals
              SizedBox(height: 16),
              Text('Vitals:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('SpO2: ${patient.vitals.spO2}', style: TextStyle(fontSize: 16)),
              Text('Pulse: ${patient.vitals.pulse}', style: TextStyle(fontSize: 16)),
              Text('Temperature: ${patient.vitals.temperature}', style: TextStyle(fontSize: 16)),

              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {

                },
                child: Text('Add Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
