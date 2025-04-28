import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../Services/aws_service.dart';
import '../services/print_job_service.dart';
import '../models/print_job.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;
  bool _isUploading = false;
  String _fileName = '';
  int _copies = 1;
  bool _isColorPrint = false;
  bool _isCollate = true;
  String _selectedPages = 'All';
  final TextEditingController _customPagesController = TextEditingController();
  String _printCode = '';
  bool _uploadComplete = false;
  final AWSService _awsService = AWSService();
  final PrintJobService _printJobService = PrintJobService();

  final List<String> _pageOptions = ['All', 'Custom'];
  final List<String> _copyOptions = ['1', '2', '3', '4', '5'];
  final List<String> _colorOptions = ['Black and White', 'Color'];

  @override
  void dispose() {
    _customPagesController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
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
      _uploadComplete = false;
    });

    String? awsPrintCode;

    try {
      // Get file extension
      final fileExtension = _fileName.split('.').last.toLowerCase();

      // Get presigned URL and print code
      final uploadData =
          await _awsService.getPresignedUrl(_fileName, fileExtension);
      final uploadUrl = uploadData['uploadURL'];
      awsPrintCode = uploadData['printCode'];

      print('Debug: Received print code: $awsPrintCode');

      if (uploadUrl == null || awsPrintCode == null) {
        throw Exception(
            'Failed to get upload URL or print code from AWS service');
      }

      // Upload file to S3
      final fileBytes = await _selectedFile!.readAsBytes();
      final uploadSuccess =
          await _awsService.uploadFileToS3(uploadUrl, fileBytes);

      if (uploadSuccess) {
        // Save to Firestore
        final newJob = PrintJob(
          id: '',
          fileName: _fileName,
          printCode: awsPrintCode!,
          uploadDate: DateTime.now(),
          userId: FirebaseAuth.instance.currentUser!.uid,
        );

        await _printJobService.addPrintJob(newJob);
        print('Print job saved to Firestore!');

        setState(() {
          _printCode = awsPrintCode!;
          _isUploading = false;
          _uploadComplete = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('File uploaded successfully! Print Code: $_printCode'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('S3 Upload failed');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPrintOptions() {
    return Column(
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
        DropdownButtonFormField<String>(
          value: _copyOptions[0],
          decoration: const InputDecoration(
            labelText: 'Number of Copies',
            border: OutlineInputBorder(),
          ),
          items: _copyOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _copies = int.parse(newValue);
              });
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _colorOptions[0],
          decoration: const InputDecoration(
            labelText: 'Print Color',
            border: OutlineInputBorder(),
          ),
          items: _colorOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _isColorPrint = newValue == 'Color';
              });
            }
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Collate'),
          value: _isCollate,
          onChanged: (bool value) {
            setState(() {
              _isCollate = value;
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _pageOptions[0],
          decoration: const InputDecoration(
            labelText: 'Pages',
            border: OutlineInputBorder(),
          ),
          items: _pageOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedPages = newValue;
              });
            }
          },
        ),
        if (_selectedPages == 'Custom') ...[
          const SizedBox(height: 16),
          TextField(
            controller: _customPagesController,
            decoration: const InputDecoration(
              labelText: 'Custom Pages (e.g., 1-5,8,11-13)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadFile,
          child: _isUploading
              ? const CircularProgressIndicator()
              : const Text('Upload and Print'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'I',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Text(
              'nkly',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: _selectFile,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 8),
                    Text(_fileName.isEmpty ? 'Add File' : _fileName),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_fileName.isNotEmpty) ...[
                _buildPrintOptions(),
              ],
              if (_uploadComplete) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Upload Complete!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Print Code: $_printCode',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please save this code to track your print job',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
