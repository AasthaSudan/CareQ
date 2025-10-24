// import 'package:flutter/material.dart';
// import '../models/patient_model.dart';
// import '../services/firebase.service.dart';
// import '../services/voice_service.dart';
// import '../widgets/custom_button.dart';
// import 'triage_assessment_screen.dart';
//
// class RegisterPatientScreen extends StatefulWidget {
//   const RegisterPatientScreen({Key? key}) : super(key: key);
//
//   @override
//   State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
// }
//
// class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseService _firebaseService = FirebaseService();
//   final VoiceService _voiceService = VoiceService();
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();
//   final TextEditingController _complaintController = TextEditingController();
//
//   String _gender = 'Male';
//   bool _isLoading = false;
//   bool _isListening = false;
//   String _currentVoiceField = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _voiceService.initialize();
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _ageController.dispose();
//     _contactController.dispose();
//     _complaintController.dispose();
//     _voiceService.dispose();
//     super.dispose();
//   }
//
//   Future<void> _startVoiceInput(String field, TextEditingController controller) async {
//     if (!_voiceService.isAvailable) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Voice recognition not available')),
//       );
//       return;
//     }
//
//     setState(() {
//       _isListening = true;
//       _currentVoiceField = field;
//     });
//
//     await _voiceService.startListening(
//       onResult: (text) {
//         setState(() {
//           controller.text = text;
//           _isListening = false;
//           _currentVoiceField = '';
//         });
//       },
//     );
//
//     // Auto-stop after 5 seconds
//     Future.delayed(const Duration(seconds: 5), () {
//       if (_isListening) {
//         _voiceService.stopListening();
//         setState(() {
//           _isListening = false;
//           _currentVoiceField = '';
//         });
//       }
//     });
//   }
//
//   Future<void> _registerPatient() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       Patient patient = Patient(
//         id: '',
//         name: _nameController.text.trim(),
//         age: int.parse(_ageController.text.trim()),
//         gender: _gender,
//         contact: _contactController.text.trim(),
//         chiefComplaint: _complaintController.text.trim(),
//         checkInTime: DateTime.now(),
//         status: 'waiting',
//       );
//
//       String patientId = await _firebaseService.addPatient(patient);
//
//       setState(() => _isLoading = false);
//
//       // Navigate to triage assessment
//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TriageAssessmentScreen(
//               patient: patient.copyWith(id: patientId),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Register New Patient'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('Voice Input'),
//                   content: const Text(
//                     'Tap the microphone icon next to any field to use voice input. '
//                         'Speak clearly and the text will be automatically filled.',
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('Got it'),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Info Card
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: const [
//                     Icon(Icons.person_add, color: Colors.white, size: 32),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'Fill patient details to begin triage assessment',
//                         style: TextStyle(color: Colors.white, fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               // Patient Name with Voice Input
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Patient Name *',
//                   prefixIcon: const Icon(Icons.person),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isListening && _currentVoiceField == 'name'
//                           ? Icons.mic
//                           : Icons.mic_none,
//                       color: _isListening && _currentVoiceField == 'name'
//                           ? Colors.red
//                           : Colors.grey,
//                     ),
//                     onPressed: () => _startVoiceInput('name', _nameController),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter patient name';
//                   }
//                   return null;
//                 },
//                 textCapitalization: TextCapitalization.words,
//               ),
//               const SizedBox(height: 16),
//
//               // Age and Gender Row
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: TextFormField(
//                       controller: _ageController,
//                       decoration: const InputDecoration(
//                         labelText: 'Age *',
//                         prefixIcon: Icon(Icons.calendar_today),
//                         suffixText: 'years',
//                       ),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Required';
//                         }
//                         int? age = int.tryParse(value);
//                         if (age == null || age < 0 || age > 120) {
//                           return 'Invalid age';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     flex: 3,
//                     child: DropdownButtonFormField<String>(
//                       value: _gender,
//                       decoration: const InputDecoration(
//                         labelText: 'Gender *',
//                         prefixIcon: Icon(Icons.wc),
//                       ),
//                       items: ['Male', 'Female', 'Other']
//                           .map((gender) => DropdownMenuItem(
//                         value: gender,
//                         child: Text(gender),
//                       ))
//                           .toList(),
//                       onChanged: (value) {
//                         setState(() => _gender = value!);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//
//               // Contact Number
//               TextFormField(
//                 controller: _contactController,
//                 decoration: const InputDecoration(
//                   labelText: 'Contact Number *',
//                   prefixIcon: Icon(Icons.phone),
//                   prefixText: '+91 ',
//                 ),
//                 keyboardType: TextInputType.phone,
//                 maxLength: 10,
//                 validator: (value) {
//                   if (value == null || value.trim().length != 10) {
//                     return 'Enter valid 10-digit number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               // Chief Complaint with Voice Input
//               TextFormField(
//                 controller: _complaintController,
//                 decoration: InputDecoration(
//                   labelText: 'Chief Complaint *',
//                   prefixIcon: const Icon(Icons.medical_services),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isListening && _currentVoiceField == 'complaint'
//                           ? Icons.mic
//                           : Icons.mic_none,
//                       color: _isListening && _currentVoiceField == 'complaint'
//                           ? Colors.red
//                           : Colors.grey,
//                     ),
//                     onPressed: () =>
//                         _startVoiceInput('complaint', _complaintController),
//                   ),
//                   helperText: 'Describe the main reason for visit',
//                 ),
//                 maxLines: 3,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please describe the chief complaint';
//                   }
//                   return null;
//                 },
//                 textCapitalization: TextCapitalization.sentences,
//               ),
//
//               // Voice Input Status
//               if (_isListening) ...[
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.red.shade200),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.mic, color: Colors.red),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: const [
//                             Text(
//                               'Listening...',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.red,
//                               ),
//                             ),
//                             Text(
//                               'Speak clearly into the microphone',
//                               style: TextStyle(fontSize: 12),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation(Colors.red),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//
//               const SizedBox(height: 32),
//
//               // Submit Button
//               CustomButton(
//                 text: 'Proceed to Triage Assessment',
//                 onPressed: _registerPatient,
//                 icon: Icons.arrow_forward,
//                 isLoading: _isLoading,
//               ),
//               const SizedBox(height: 16),
//
//               // Help Text
//               Center(
//                 child: Text(
//                   'All fields marked with * are required',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade600,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }