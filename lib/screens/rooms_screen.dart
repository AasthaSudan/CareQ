import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final rooms = List.generate(6, (index) => "Room ${index + 1}");

    return GridView.builder(
      padding: EdgeInsets.all(size.width * 0.02),
      itemCount: rooms.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size.width > 600 ? 3 : 2, // responsive columns
        mainAxisSpacing: size.width * 0.03,
        crossAxisSpacing: size.width * 0.03,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        return Container(
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
          child: Center(
            child: Text(
              rooms[index],
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7A5AF8)),
            ),
          ),
        );
      },
    );
  }
}
