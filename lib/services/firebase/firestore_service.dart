import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String name) =>
      _db.collection(name);

  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collectionName,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _db.collection(collectionName).add(data);
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    }
  }

  Future<void> deleteDocument(String collectionName, String docId) async {
    try {
      await _db.collection(collectionName).doc(docId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collectionName, {
    String? whereField,
    dynamic whereValue,
  }) {
    var ref = _db.collection(collectionName);
    if (whereField != null && whereValue != null) {
      return ref.where(whereField, isEqualTo: whereValue).snapshots();
    }
    return ref.snapshots();
  }
}
