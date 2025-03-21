import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_model.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;
  bool _isUploading = false;
  String _fileName = '';
  int _selectedPrintOption = 0;
  int _copies = 1;
  bool _isColorPrint = false;
  bool _isDoubleSided = true;

  final List<String> _printOptions = [
    'A4 - Black & White',
    'A4 - Color',
    'A3 - Black & White',
    'A3 - Color',
  ];

  void _selectFile() async {
    // In a real app, you would use file_picker package
    // For this example, we'll just simulate file selection
    setState(() {
      _fileName = 'Assignment.pdf';
    });
  }

  void _uploadFile() {
    if (_fileName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Simulate upload process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isUploading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      setState(() {
        _fileName = '';
        _selectedPrintOption = 0;
        _copies = 1;
        _isColorPrint = false;
        _isDoubleSided = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUploadSection(),
              if (_fileName.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildPrintOptions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Document',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _selectFile,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _fileName.isEmpty
                            ? 'Tap to select a document'
                            : _fileName,
                        style: TextStyle(
                          color: _fileName.isEmpty
                              ? Colors.grey[600]
                              : Colors.black,
                          fontWeight: _fileName.isEmpty
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Supported formats: PDF, DOC, DOCX, PPT, PPTX, XLS, XLSX, TXT, JPG, PNG',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Print Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Paper Size & Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(
                _printOptions.length,
                (index) => ChoiceChip(
                  label: Text(_printOptions[index]),
                  selected: _selectedPrintOption == index,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPrintOption = index;
                      _isColorPrint = _printOptions[index].contains('Color');
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Copies:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _copies > 1
                      ? () {
                          setState(() {
                            _copies--;
                          });
                        }
                      : null,
                ),
                Text(
                  '$_copies',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      _copies++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Double-sided printing'),
              value: _isDoubleSided,
              onChanged: (value) {
                setState(() {
                  _isDoubleSided = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadFile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Upload & Print'),
            ),
          ],
        ),
      ),
    );
  }
}
