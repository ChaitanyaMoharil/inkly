// lib/screens/download_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Services/aws_service.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final TextEditingController _printCodeController = TextEditingController();
  final AWSService _awsService = AWSService();
  bool _isLoading = false;
  String? _downloadUrl;
  String? _errorMessage;

  @override
  void dispose() {
    _printCodeController.dispose();
    super.dispose();
  }

  Future<void> _getDownloadUrl() async {
    final printCode = _printCodeController.text.trim();

    if (printCode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a print code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _downloadUrl = null;
    });

    try {
      final downloadUrl = await _awsService.getDownloadUrl(printCode);
      setState(() {
        _downloadUrl = downloadUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _openDownloadUrl() async {
    if (_downloadUrl != null) {
      final uri = Uri.parse(_downloadUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        setState(() {
          _errorMessage = 'Could not open download URL';
        });
      }
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Download Document',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter Print Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _printCodeController,
              decoration: InputDecoration(
                hintText: 'e.g., ABC123',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _getDownloadUrl,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Find Document'),
            ),
            if (_downloadUrl != null) ...[
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
                      'Document Found!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _openDownloadUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Open Document'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
