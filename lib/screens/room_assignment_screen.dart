import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomAssignmentScreen extends StatelessWidget {
  const RoomAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final rooms = List.generate(6, (index) => "Room ${index + 1}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Assignment'),
        backgroundColor: const Color(0xFF7A5AF8),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(size.width * 0.02),
        itemCount: rooms.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size.width > 600 ? 3 : 2, // responsive columns
          mainAxisSpacing: size.width * 0.03,
          crossAxisSpacing: size.width * 0.03,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Show a dialog or navigate when a room is tapped
              _showRoomDialog(context, rooms[index]);
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF7A5AF8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  rooms[index],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7A5AF8),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Show a dialog when a room is tapped
  void _showRoomDialog(BuildContext context, String roomName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Room Assignment'),
          content: Text('You have selected $roomName. Do you want to assign a patient?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add further action to assign a patient or proceed
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Proceed with room assignment logic
                _assignPatientToRoom(roomName);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Handle patient assignment to the selected room
  void _assignPatientToRoom(String roomName) {
    // Logic to assign patient to room
    print('Patient assigned to $roomName');
    // You can replace this with a navigation to another screen or save the room assignment to a provider
  }
}
