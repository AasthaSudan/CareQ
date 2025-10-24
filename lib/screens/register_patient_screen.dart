import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPatientScreen extends StatelessWidget {
  const RegisterPatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Register New Patient",
                style: GoogleFonts.poppins(
                    fontSize: size.width * 0.045, fontWeight: FontWeight.w600)),
            SizedBox(height: size.height * 0.015),
            _buildTextField("Full Name"),
            _buildTextField("Age", keyboardType: TextInputType.number),
            _buildTextField("Contact Number", keyboardType: TextInputType.phone),
            _buildTextField("Symptoms", maxLines: 3),
            SizedBox(height: size.height * 0.02),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A5AF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                ),
                child: Text("Register",
                    style: GoogleFonts.poppins(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
