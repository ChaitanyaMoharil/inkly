// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      'https://sw14dz8xh0.execute-api.us-east-1.amazonaws.com/dev';

  // Get upload URL and print code
  Future<Map<String, dynamic>> getUploadUrl(
      String fileName, String fileType) async {
    final response = await http.post(
      Uri.parse('$baseUrl/process'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fileName': fileName, 'fileType': fileType}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get upload URL');
    }
  }

  // Upload file to S3 using presigned URL
  Future<bool> uploadFileToS3(
      String uploadUrl, List<int> fileBytes, String fileType) async {
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {
        'Content-Type': fileType,
      },
      body: fileBytes,
    );

    return response.statusCode == 200;
  }

  // Get download URL using print code
  Future<String> getDownloadUrl(String printCode) async {
    final response = await http.post(
      Uri.parse('$baseUrl/download'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'printCode': printCode}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['downloadURL'];
    } else {
      throw Exception('Failed to get download URL');
    }
  }
}
