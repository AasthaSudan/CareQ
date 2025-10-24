// import 'package:flutter/material.dart';
// import '../models/patient_model.dart';
// import '../models/triage_model.dart';
// import '../services/firebase.service.dart';
// import '../services/firebase_service.dart';
// import '../services/ai_priority_service.dart';
// import '../config/constants.dart';
// import '../widgets/custom_button.dart';
//
// class TriageAssessmentScreen extends StatefulWidget {
//   final Patient patient;
//
//   const TriageAssessmentScreen({
//     Key? key,
//     required this.patient,
//   }) : super(key: key);
//
//   @override
//   State<TriageAssessmentScreen> createState() => _TriageAssessmentScreenState();
// }
//
// class _TriageAssessmentScreenState extends State<TriageAssessmentScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseService _firebaseService = FirebaseService();
//
//   // Vital signs controllers
//   final TextEditingController _bpController = TextEditingController();
//   final TextEditingController _pulseController = TextEditingController();
//   final TextEditingController _tempController = TextEditingController();
//   final TextEditingController _oxygenController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
//
//   List<String> _selectedSymptoms = [];
//   Map<String, dynamic>? _aiPrediction;
//   bool _isLoading = false;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     );
//
//     // Add listeners to recalculate priority on changes
//     _pulseController.addListener(_recalculatePriority);
//     _tempController.addListener(_recalculatePriority);
//     _oxygenController.addListener(_recalculatePriority);
//     _bpController.addListener(_recalculatePriority);
//   }
//
//   @override
//   void dispose() {
//     _bpController.dispose();
//     _pulseController.dispose();
//     _tempController.dispose();
//     _oxygenController.dispose();
//     _notesController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _recalculatePriority() {
//     // Only calculate if we have essential values
//     int? pulse = int.tryParse(_pulseController.text);
//     double? temp = double.tryParse(_tempController.text);
//     int? oxygen = int.tryParse(_oxygenController.text);
//
//     if (pulse == null || temp == null || oxygen == null) return;
//     if (pulse == 0 || temp == 0 || oxygen == 0) return;
//
//     Map<String, dynamic> prediction = AIPriorityService.predictPriority(
//       age: widget.patient.age,
//       pulse: pulse,
//       bloodPressure: _bpController.text.trim(),
//       temperature: temp,
//       oxygenLevel: oxygen,
//       symptoms: _selectedSymptoms,
//     );
//
//     setState(() {
//       _aiPrediction = prediction;
//     });
//
//     // Trigger animation
//     _animationController.forward(from: 0.0);
//   }
//
//   Future<void> _completeTriage() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     if (_aiPrediction == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all vital signs first')),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       Triage triage = Triage(
//         id: '',
//         patientId: widget.patient.id,
//         priority: _aiPrediction!['priority'],
//         vitals: {
//           'bloodPressure': _bpController.text.trim(),
//           'pulse': int.parse(_pulseController.text),
//           'temperature': double.parse(_tempController.text),
//           'oxygenLevel': int.parse(_oxygenController.text),
//         },
//         symptoms: _selectedSymptoms,
//         triageTime: DateTime.now(),
//         triageNotes: _notesController.text.trim(),
//         aiConfidence: double.parse(_aiPrediction!['confidence']),
//         riskScore: double.parse(_aiPrediction!['riskScore']),
//       );
//
//       await _firebaseService.addTriage(triage);
//
//       setState(() => _isLoading = false);
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('✅ Patient added to queue successfully!'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
//
//         // Go back to home
//         Navigator.of(context).popUntil((route) => route.isFirst);
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
//         title: const Text('Triage Assessment'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.help_outline),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('🤖 AI-Powered Triage'),
//                   content: const Text(
//                     'Our AI analyzes vital signs and symptoms to calculate '
//                         'priority automatically. The system uses multi-factor risk '
//                         'assessment for accurate triage.',
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
//               // Patient Info Card
//               _buildPatientInfoCard(),
//               const SizedBox(height: 24),
//
//               // Vital Signs Section
//               _buildSectionTitle('Vital Signs', Icons.monitor_heart),
//               const SizedBox(height: 16),
//               _buildVitalSignsInputs(),
//               const SizedBox(height: 24),
//
//               // Symptoms Section
//               _buildSectionTitle('Symptoms Checklist', Icons.checklist),
//               const SizedBox(height: 16),
//               _buildSymptomsChecklist(),
//               const SizedBox(height: 24),
//
//               // AI Prediction Display
//               if (_aiPrediction != null) ...[
//                 _buildAIPredictionCard(),
//                 const SizedBox(height: 24),
//               ],
//
//               // Additional Notes
//               _buildSectionTitle('Additional Notes (Optional)', Icons.note),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _notesController,
//                 decoration: const InputDecoration(
//                   hintText: 'Any additional observations or notes...',
//                   prefixIcon: Icon(Icons.edit_note),
//                 ),
//                 maxLines: 3,
//                 textCapitalization: TextCapitalization.sentences,
//               ),
//               const SizedBox(height: 32),
//
//               // Complete Button
//               CustomButton(
//                 text: 'Complete Triage & Add to Queue',
//                 onPressed: _completeTriage,
//                 icon: Icons.check_circle,
//                 isLoading: _isLoading,
//                 color: Colors.green,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPatientInfoCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.purple.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.person,
//                   color: Colors.white,
//                   size: 32,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.patient.name,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${widget.patient.age} years • ${widget.patient.gender}',
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.medical_services,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     widget.patient.chiefComplaint,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, color: const Color(0xFF2196F3)),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildVitalSignsInputs() {
//     return Column(
//       children: [
//         // Blood Pressure and Pulse
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: _bpController,
//                 decoration: const InputDecoration(
//                   labelText: 'Blood Pressure',
//                   hintText: '120/80',
//                   prefixIcon: Icon(Icons.favorite),
//                   suffixText: 'mmHg',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Required';
//                   }
//                   if (!value.contains('/')) {
//                     return 'Format: 120/80';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: TextFormField(
//                 controller: _pulseController,
//                 decoration: const InputDecoration(
//                   labelText: 'Pulse',
//                   hintText: '72',
//                   prefixIcon: Icon(Icons.monitor_heart),
//                   suffixText: 'bpm',
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Required';
//                   }
//                   int? pulse = int.tryParse(value);
//                   if (pulse == null || pulse < 30 || pulse > 200) {
//                     return 'Invalid';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//
//         // Temperature and Oxygen
//         Row(
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: _tempController,
//                 decoration: const InputDecoration(
//                   labelText: 'Temperature',
//                   hintText: '98.6',
//                   prefixIcon: Icon(Icons.thermostat),
//                   suffixText: '°F',
//                 ),
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Required';
//                   }
//                   double? temp = double.tryParse(value);
//                   if (temp == null || temp < 90 || temp > 110) {
//                     return 'Invalid';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: TextFormField(
//                 controller: _oxygenController,
//                 decoration: const InputDecoration(
//                   labelText: 'Oxygen Level',
//                   hintText: '98',
//                   prefixIcon: Icon(Icons.air),
//                   suffixText: '%',
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Required';
//                   }
//                   int? oxygen = int.tryParse(value);
//                   if (oxygen == null || oxygen < 50 || oxygen > 100) {
//                     return 'Invalid';
//                   }
//                   return null;
//                 },
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSymptomsChecklist() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(
//         children: AppConstants.symptoms.map((symptom) {
//           bool isSelected = _selectedSymptoms.contains(symptom['id']);
//           return CheckboxListTile(
//             title: Row(
//               children: [
//                 Text(
//                   symptom['icon']!,
//                   style: const TextStyle(fontSize: 20),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(symptom['label']!),
//                 ),
//               ],
//             ),
//             value: isSelected,
//             activeColor: const Color(0xFF2196F3),
//             onChanged: (bool? value) {
//               setState(() {
//                 if (value == true) {
//                   _selectedSymptoms.add(symptom['id']!);
//                 } else {
//                   _selectedSymptoms.remove(symptom['id']);
//                 }
//                 _recalculatePriority();
//               });
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildAIPredictionCard() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0xFF9C27B0), Color(0xFF2196F3)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.purple.withOpacity(0.4),
//               blurRadius: 15,
//               spreadRadius: 2,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: const [
//                 Icon(Icons.psychology, color: Colors.white, size: 28),
//                 SizedBox(width: 8),
//                 Text(
//                   '🤖 AI-Powered Analysis',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             // Risk Score
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     'Risk Score',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${_aiPrediction!['riskScore']}/100',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Confidence
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
//                   const SizedBox(width: 6),
//                   Text(
//                     'Confidence: ${_aiPrediction!['confidence']}%',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // Priority Display
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AIPriorityService.getPriorityColor(
//                   _aiPrediction!['priority'],
//                 ).withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AIPriorityService.getPriorityColor(
//                     _aiPrediction!['priority'],
//                   ),
//                   width: 2,
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     AIPriorityService.getPriorityIcon(_aiPrediction!['priority']),
//                     style: const TextStyle(fontSize: 24),
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     'Priority: ${AIPriorityService.getPriorityLabel(_aiPrediction!['priority'])}',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // Probability Bars
//             _buildProbabilityBar(
//               'CRITICAL',
//               _aiPrediction!['probabilities']['red'],
//               Colors.red,
//             ),
//             const SizedBox(height: 8),
//             _buildProbabilityBar(
//               'URGENT',
//               _aiPrediction!['probabilities']['yellow'],
//               Colors.orange,
//             ),
//             const SizedBox(height: 8),
//             _buildProbabilityBar(
//               'NON-URGENT',
//               _aiPrediction!['probabilities']['green'],
//               Colors.green,
//             ),
//
//             // Risk Factors
//             if (_aiPrediction!['riskFactors'].isNotEmpty) ...[
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Key Risk Factors:',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     ...(_aiPrediction!['riskFactors'] as List).map<Widget>(
//                           (factor) => Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 2),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.warning_amber,
//                               color: Colors.yellowAccent,
//                               size: 16,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 factor,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProbabilityBar(String label, String percentage, Color color) {
//     double percent = double.parse(percentage) / 100;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               '$percentage%',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: LinearProgressIndicator(
//             value: percent,
//             minHeight: 10,
//             backgroundColor: Colors.white.withOpacity(0.3),
//             valueColor: AlwaysStoppedAnimation<Color>(color),
//           ),
//         ),
//       ],
//     );
//   }
// }