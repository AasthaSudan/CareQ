import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedDocument;

  Future<void> _pickDocument() async {
    // Use ImagePicker to pick a document (image or PDF can be handled)
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedDocument = File(pickedFile.path);
      });
    }
  }

  void _uploadDocument() {
    if (_selectedDocument != null) {
      // Upload logic goes here (e.g., save to database or cloud storage)
      print('Document uploaded: ${_selectedDocument?.path}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a document to upload.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        backgroundColor: const Color(0xFF7A5AF8), // Your theme color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Medical Document',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickDocument,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A5AF8), // Your theme color
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedDocument != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected Document:', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    _selectedDocument!.path.split('/').last, // Display the document name
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _uploadDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A5AF8), // Your theme color
                ),
                child: const Text('Upload Document'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
