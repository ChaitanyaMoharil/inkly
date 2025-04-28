import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/print_job.dart';

class PrintJobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'printJobs';

  Stream<List<PrintJob>> getPrintJobsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: currentUserId)
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PrintJob.fromMap(
                doc.data(),
                doc.id,
              ))
          .toList();
    });
  }

  Future<List<PrintJob>> getPrintJobs() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: currentUserId)
        .orderBy('uploadDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PrintJob.fromMap(
              doc.data(),
              doc.id,
            ))
        .toList();
  }

  Future<void> addPrintJob(PrintJob job) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final jobWithUserId = PrintJob(
      id: job.id,
      fileName: job.fileName,
      printCode: job.printCode,
      uploadDate: job.uploadDate,
      userId: currentUserId,
    );

    await _firestore.collection(_collection).add(jobWithUserId.toMap());
  }

  Future<void> updatePrintJob(PrintJob job) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    if (job.userId != currentUserId) {
      throw Exception('Not authorized to update this job');
    }

    await _firestore.collection(_collection).doc(job.id).update(job.toMap());
  }

  Future<void> deletePrintJob(String jobId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final jobDoc = await _firestore.collection(_collection).doc(jobId).get();
    if (!jobDoc.exists || jobDoc.data()?['userId'] != currentUserId) {
      throw Exception('Not authorized to delete this job');
    }

    await _firestore.collection(_collection).doc(jobId).delete();
  }
}
