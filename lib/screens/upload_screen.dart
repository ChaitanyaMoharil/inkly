import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
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
  int _copies = 1;
  bool _isColorPrint = false;
  bool _isCollate = true;
  String _selectedPages = 'All';
  final TextEditingController _customPagesController = TextEditingController();

  // Add these new variables
  String _printCode = '';
  bool _uploadComplete = false;

  final List<String> _pageOptions = [
    'All',
    'Custom',
  ];

  final List<String> _copyOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  final List<String> _colorOptions = [
    'Black and White',
    'Color',
  ];

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

    try {
      // Prepare the request parameters
      String pages =
          _selectedPages == 'All' ? 'all' : _customPagesController.text;

      String colorMode = _isColorPrint ? 'color' : 'bw';

      // Step 1: Call the Lambda function to get the upload URL
      final response = await http.post(
        Uri.parse(
            'https://sw14dz8xh0.execute-api.us-east-1.amazonaws.com/dev'), // Replace with your actual invoke URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'copies': _copies,
          'pages': pages,
          'colorMode': colorMode,
          'fileName': _fileName,
          'collate': _isCollate,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        String uploadUrl = jsonResponse['uploadURL'];
        String printCode = jsonResponse['printCode'];

        // Step 2: Upload the file to S3 using the presigned URL
        final uploadResponse = await http.put(
          Uri.parse(uploadUrl),
          headers: {
            'Content-Type':
                'application/pdf', // Adjust based on file type if needed
          },
          body: await _selectedFile!.readAsBytes(),
        );

        if (uploadResponse.statusCode >= 200 &&
            uploadResponse.statusCode < 300) {
          setState(() {
            _printCode = printCode;
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
          throw Exception('Upload failed: ${uploadResponse.statusCode}');
        }
      } else {
        throw Exception(
            'API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

              // Add this section to show the print code after upload
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

  Widget _buildPrintOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Copies',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            value: _copies.toString(),
            items: _copyOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _copies = int.parse(newValue!);
              });
            },
            isExpanded: true,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Colour',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            value: _isColorPrint ? 'Color' : 'Black and White',
            items: _colorOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _isColorPrint = newValue == 'Color';
              });
            },
            isExpanded: true,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Collate',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _isCollate,
              onChanged: (bool? value) {
                setState(() {
                  _isCollate = value!;
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            const Text('Yes'),
            const SizedBox(width: 24),
            Checkbox(
              value: !_isCollate,
              onChanged: (bool? value) {
                setState(() {
                  _isCollate = !value!;
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            const Text('No'),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Pages',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            value: _selectedPages,
            items: _pageOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedPages = newValue!;
              });
            },
            isExpanded: true,
          ),
        ),
        if (_selectedPages == 'Custom') ...[
          const SizedBox(height: 16),
          TextField(
            controller: _customPagesController,
            decoration: InputDecoration(
              hintText: 'Page number(s)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            keyboardType: TextInputType.text,
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadFile,
          child: _isUploading
              ? const CircularProgressIndicator()
              : const Text('Upload & Print'),
        ),
      ],
    );
  }
}
