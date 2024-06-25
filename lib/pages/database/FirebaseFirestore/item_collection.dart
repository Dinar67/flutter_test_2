import 'package:cloud_firestore/cloud_firestore.dart';

class ItemCollection {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future<void> addItem(
    String type,
    String name,
    String price,
    String description,
  ) async {
    try {
      CollectionReference profiles = _firebaseFirestore.collection('items');
      await profiles.doc().set({
        'type': type,
        'name': name,
        'price': price,
        'phone': description,
        'image': '',
      });
    } catch (e) {
      return;
    }
  }

  Future<void> editImageItem(
    dynamic docs,
    String image,
  ) async {
    try {
      await _firebaseFirestore.collection("items").doc(docs.id).update({
        'image': image,
      });
    } catch (e) {
      return;
    }
  }

  Future<void> editItem(dynamic docs,
    String surname,
    String name,
    String price,
    String description,
  ) async {
    try {
      await _firebaseFirestore.collection("profiles").doc(docs.id).update({
        'name': name,
        'price': price,
        'phone': description,
      });
    } catch (e) {
      return;
    }
  }

  Future<void> deleteProfile(
    dynamic docs,
  ) async {
    try {
      await _firebaseFirestore
          .collection('items')
          .doc(
            docs.id,
          )
          .delete();
    } catch (e) {
      return;
    }
  }
}