import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileCollection {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future<void> addProfile(
    String id,
    String surname,
    String name,
    String patronymic,
    String phone,
    String email,
    String password,
    String image,
  ) async {
    try {
      CollectionReference profiles = _firebaseFirestore.collection('profiles');
      await profiles.doc(id).set({
        'uid': id,
        'surname': surname,
        'name': name,
        'patronymic': patronymic,
        'phone': phone,
        'email': email,
        'password': password,
        'image': image,
        'role':'user'
      });
    } catch (e) {
      return;
    }
  }

  Future<void> editImageProfile(
    dynamic docs,
    String image,
  ) async {
    try {
      await _firebaseFirestore.collection("profiles").doc(docs.id).update({
        'image': image,
      });
    } catch (e) {
      return;
    }
  }

  Future<void> editProfile(String id,
    String surname,
    String name,
    String patronymic,
    String phone,
  ) async {
    try {
      await _firebaseFirestore.collection("profiles").doc(id).update({
        'surname': surname,
        'name': name,
        'patronymic': patronymic,
        'phone': phone,
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
          .collection('profiles')
          .doc(
            docs.id,
          )
          .delete();
    } catch (e) {
      return;
    }
  }
}