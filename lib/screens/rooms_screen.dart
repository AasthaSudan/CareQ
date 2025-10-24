// import 'package:flutter/material.dart';
// import '../services/firebase.service.dart';
// import '../models/room_model.dart';
// import '../widgets/room_card.dart';
//
// class RoomsScreen extends StatefulWidget {
//   const RoomsScreen({Key? key}) : super(key: key);
//
//   @override
//   State<RoomsScreen> createState() => _RoomsScreenState();
// }
//
// class _RoomsScreenState extends State<RoomsScreen> {
//   final FirebaseService _firebaseService = FirebaseService();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Emergency Rooms'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('Room Management'),
//                   content: const Text(
//                     'Green rooms are available for patient assignment.\n\n'
//                         'Red rooms are currently occupied.\n\n'
//                         'Tap on an occupied room to discharge the patient.',
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
//       body: StreamBuilder<List<Room>>(
//         stream: _firebaseService.getRoomsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//
//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.error_outline,
//                     size: 64,
//                     color: Colors.red,
//                   ),
//                   const SizedBox(height: 16),
//                   Text('Error: ${snapshot.error}'),
//                 ],
//               ),
//             );
//           }
//
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.meeting_room,
//                     size: 80,
//                     color: Colors.grey.shade400,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No rooms configured',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   ElevatedButton.icon(
//                     onPressed: () async {
//                       try {
//                         await _firebaseService.initializeRooms();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Rooms initialized successfully!'),
//                           ),
//                         );
//                       } catch (e) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Error: $e')),
//                         );
//                       }
//                     },
//                     icon: const Icon(Icons.add),
//                     label: const Text('Initialize Rooms'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           List<Room> rooms = snapshot.data!;
//           int availableCount = rooms.where((r) => r.isAvailable).length;
//           int occupiedCount = rooms.length - availableCount;
//
//           return Column(
//             children: [
//               // Statistics Banner
//               Container(
//                 margin: const EdgeInsets.all(16),
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildStat(
//                       'Total',
//                       '${rooms.length}',
//                       Icons.meeting_room,
//                     ),
//                     Container(
//                       width: 1,
//                       height: 40,
//                       color: Colors.white30,
//                     ),
//                     _buildStat(
//                       'Available',
//                       '$availableCount',
//                       Icons.check_circle,
//                     ),
//                     Container(
//                       width: 1,
//                       height: 40,
//                       color: Colors.white30,
//                     ),
//                     _buildStat(
//                       'Occupied',
//                       '$occupiedCount',
//                       Icons.person,
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Rooms Grid
//               Expanded(
//                 child: GridView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                     childAspectRatio: 0.85,
//                   ),
//                   itemCount: rooms.length,
//                   itemBuilder: (context, index) {
//                     return RoomCard(
//                       room: rooms[index],
//                       onTap: rooms[index].isAvailable
//                           ? null
//                           : () => _confirmDischarge(context, rooms[index]),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildStat(String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.white, size: 28),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _confirmDischarge(BuildContext context, Room room) {
//     if (room.assignedPatientId == null) return;
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Discharge Patient'),
//         content: Text(
//           'Are you sure you want to discharge ${room.assignedPatientName ?? "this patient"} from ${room.roomName}?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               try {
//                 await _firebaseService.dischargePatient(
//                   room.assignedPatientId!,
//                   room.id,
//                 );
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('✅ Patient discharged successfully'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Error: $e')),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//             ),
//             child: const Text('Discharge'),
//           ),
//         ],
//       ),
//     );
//   }
// }