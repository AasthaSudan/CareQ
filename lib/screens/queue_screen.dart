// import 'package:flutter/material.dart';
// import '../models/patient.model.dart';
// import '../models/triage.model.dart';
// import '../services/firebase.service.dart';
// import '../models/room_model.dart';
// import '../widgets/patient_card.dart';
//
// class QueueScreen extends StatefulWidget {
//   const QueueScreen({Key? key}) : super(key: key);
//
//   @override
//   State<QueueScreen> createState() => _QueueScreenState();
// }
//
// class _QueueScreenState extends State<QueueScreen> {
//   final FirebaseService _firebaseService = FirebaseService();
//   String _searchQuery = '';
//   String _filterPriority = 'all';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Patient Queue'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             onPressed: _showFilterDialog,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search patients...',
//                 prefixIcon: const Icon(Icons.search),
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value.toLowerCase();
//                 });
//               },
//             ),
//           ),
//
//           // Queue Stream
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: _firebaseService.getQueueStream(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//
//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.error_outline,
//                           size: 64,
//                           color: Colors.red,
//                         ),
//                         const SizedBox(height: 16),
//                         Text('Error: ${snapshot.error}'),
//                       ],
//                     ),
//                   );
//                 }
//
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.inbox,
//                           size: 80,
//                           color: Colors.grey.shade400,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No patients in queue',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Patients will appear here after triage',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 // Apply filters
//                 List<Map<String, dynamic>> filteredQueue = snapshot.data!
//                     .where((data) {
//                   Patient patient = data['patient'];
//                   Triage triage = data['triage'];
//
//                   // Search filter
//                   bool matchesSearch = _searchQuery.isEmpty ||
//                       patient.name.toLowerCase().contains(_searchQuery);
//
//                   // Priority filter
//                   bool matchesPriority = _filterPriority == 'all' ||
//                       triage.priority == _filterPriority;
//
//                   return matchesSearch && matchesPriority;
//                 })
//                     .toList();
//
//                 if (filteredQueue.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.search_off,
//                           size: 64,
//                           color: Colors.grey.shade400,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No matching patients',
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.only(bottom: 16),
//                   itemCount: filteredQueue.length,
//                   itemBuilder: (context, index) {
//                     return PatientCard(
//                       patient: filteredQueue[index]['patient'],
//                       triage: filteredQueue[index]['triage'],
//                       onAssignRoom: () => _showRoomSelection(
//                         context,
//                         filteredQueue[index]['patient'],
//                       ),
//                       onTap: () => _showPatientDetails(
//                         context,
//                         filteredQueue[index]['patient'],
//                         filteredQueue[index]['triage'],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Filter by Priority'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             RadioListTile<String>(
//               title: const Text('All Priorities'),
//               value: 'all',
//               groupValue: _filterPriority,
//               onChanged: (value) {
//                 setState(() => _filterPriority = value!);
//                 Navigator.pop(context);
//               },
//             ),
//             RadioListTile<String>(
//               title: Row(
//                 children: const [
//                   Text('🚨'),
//                   SizedBox(width: 8),
//                   Text('Critical (Red)'),
//                 ],
//               ),
//               value: 'red',
//               groupValue: _filterPriority,
//               onChanged: (value) {
//                 setState(() => _filterPriority = value!);
//                 Navigator.pop(context);
//               },
//             ),
//             RadioListTile<String>(
//               title: Row(
//                 children: const [
//                   Text('⚠️'),
//                   SizedBox(width: 8),
//                   Text('Urgent (Yellow)'),
//                 ],
//               ),
//               value: 'yellow',
//               groupValue: _filterPriority,
//               onChanged: (value) {
//                 setState(() => _filterPriority = value!);
//                 Navigator.pop(context);
//               },
//             ),
//             RadioListTile<String>(
//               title: Row(
//                 children: const [
//                   Text('✓'),
//                   SizedBox(width: 8),
//                   Text('Non-Urgent (Green)'),
//                 ],
//               ),
//               value: 'green',
//               groupValue: _filterPriority,
//               onChanged: (value) {
//                 setState(() => _filterPriority = value!);
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showRoomSelection(BuildContext context, Patient patient) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _RoomSelectionSheet(patient: patient),
//     );
//   }
//
//   void _showPatientDetails(BuildContext context, Patient patient, Triage triage) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(patient.name),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildDetailRow('Age', '${patient.age} years'),
//               _buildDetailRow('Gender', patient.gender),
//               _buildDetailRow('Contact', patient.contact),
//               const Divider(),
//               _buildDetailRow('Chief Complaint', patient.chiefComplaint),
//               const Divider(),
//               _buildDetailRow('Priority', triage.priority.toUpperCase()),
//               _buildDetailRow('Vitals', triage.getVitalsString()),
//               if (triage.symptoms.isNotEmpty)
//                 _buildDetailRow('Symptoms', triage.symptoms.join(', ')),
//               if (triage.aiConfidence != null)
//                 _buildDetailRow(
//                   'AI Confidence',
//                   '${triage.aiConfidence!.toStringAsFixed(1)}%',
//                 ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _RoomSelectionSheet extends StatelessWidget {
//   final Patient patient;
//   final FirebaseService _firebaseService = FirebaseService();
//
//   _RoomSelectionSheet({required this.patient});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.meeting_room, color: Color(0xFF2196F3)),
//               const SizedBox(width: 12),
//               const Text(
//                 'Select Room',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Assign ${patient.name} to available room',
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: StreamBuilder<List<Room>>(
//               stream: _firebaseService.getRoomsStream(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 List<Room> availableRooms = snapshot.data!
//                     .where((room) => room.isAvailable)
//                     .toList();
//
//                 if (availableRooms.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.error_outline,
//                           size: 48,
//                           color: Colors.orange.shade400,
//                         ),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'No rooms available',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Please discharge a patient first',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: availableRooms.length,
//                   itemBuilder: (context, index) {
//                     Room room = availableRooms[index];
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       child: ListTile(
//                         leading: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.green.shade100,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Icon(
//                             Icons.meeting_room,
//                             color: Colors.green.shade700,
//                           ),
//                         ),
//                         title: Text(
//                           room.roomName,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Text('${room.roomNumber} • ${room.specialty}'),
//                         trailing: const Icon(Icons.arrow_forward),
//                         onTap: () async {
//                           try {
//                             await _firebaseService.assignRoom(
//                               patient.id,
//                               patient.name,
//                               room.id,
//                             );
//                             Navigator.pop(context);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   '✅ ${patient.name} assigned to ${room.roomName}',
//                                 ),
//                                 backgroundColor: Colors.green,
//                               ),
//                             );
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text('Error: $e')),
//                             );
//                           }
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }