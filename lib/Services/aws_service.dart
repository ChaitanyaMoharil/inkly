import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document.dart';

class AWSService {
  static const String _baseUrl =
      'https://sw14dz8xh0.execute-api.us-east-1.amazonaws.com/dev';
  static const String _uploadEndpoint = '/generate-upload-url';
  static const String _documentsEndpoint = '/documents';
  static const String _downloadEndpoint = '/download';

  Future<Map<String, dynamic>> getPresignedUrl(
      String fileName, String fileType) async {
    try {
      // Encode the file name to handle special characters
      final encodedFileName = Uri.encodeComponent(fileName);
      print('Requesting presigned URL for file: $encodedFileName');

      final response = await http.post(
        Uri.parse('$_baseUrl$_uploadEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fileName': encodedFileName,
          'fileType': fileType,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Received presigned URL data: $data');
        return data;
      } else {
        throw Exception(
            'Failed to get presigned URL: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getPresignedUrl: $e');
      throw Exception('Error getting presigned URL: $e');
    }
  }

  Future<bool> uploadFileToS3(String presignedUrl, List<int> fileBytes) async {
    try {
      print('Uploading file to S3 using presigned URL');
      print('Presigned URL: $presignedUrl');

      final response = await http.put(
        Uri.parse(presignedUrl),
        headers: {
          'Content-Type': 'application/pdf',
        },
        body: fileBytes,
      );

      print('Upload response status: ${response.statusCode}');
      print('Upload response headers: ${response.headers}');
      if (response.statusCode != 200) {
        print('Upload error response: ${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      print('Error in uploadFileToS3: $e');
      throw Exception('Error uploading file to S3: $e');
    }
  }

  Future<List<Document>> getDocuments() async {
    try {
      print('Fetching documents list');
      final response = await http.get(
        Uri.parse('$_baseUrl$_documentsEndpoint'),
      );

      print('Documents response status: ${response.statusCode}');
      print('Documents response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Document.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to get documents: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getDocuments: $e');
      throw Exception('Error getting documents: $e');
    }
  }

  Future<String> getDownloadUrl(String printCode) async {
    try {
      print('Getting download URL for print code: $printCode');
      final response = await http.get(
        Uri.parse('$_baseUrl$_downloadEndpoint/$printCode'),
      );

      print('Download URL response status: ${response.statusCode}');
      print('Download URL response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['downloadUrl'];
      } else {
        throw Exception(
            'Failed to get download URL: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getDownloadUrl: $e');
      throw Exception('Error getting download URL: $e');
    }
  }
}
