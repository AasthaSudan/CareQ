import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final queueList = List.generate(8, (index) => "Patient #${index + 1}");

    return ListView.builder(
      itemCount: queueList.length,
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Container(
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(queueList[index],
                    style: GoogleFonts.poppins(fontSize: 16)),
                const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
