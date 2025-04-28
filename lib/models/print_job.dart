import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrintJob {
  final String id;
  final String fileName;
  final String printCode;
  final DateTime uploadDate;
  final String userId;

  PrintJob({
    required this.id,
    required this.fileName,
    required this.printCode,
    required this.uploadDate,
    required this.userId,
  });

  factory PrintJob.fromMap(Map<String, dynamic> map, String documentId) {
    return PrintJob(
      id: documentId,
      fileName: map['fileName'] ?? '',
      printCode: map['printCode'] ?? '',
      uploadDate: (map['uploadDate'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'printCode': printCode,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'userId': userId,
    };
  }
}
