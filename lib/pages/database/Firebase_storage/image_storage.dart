import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageStorage {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore bd = FirebaseFirestore.instance;
  String? pathImageUrl;

  Future addImageStorage(XFile path) async {
    try {
      // Cоздаем путь в бд
      final pathImage = 'userLogo/${path.name}';
      // Для того чтобы название и папка были упорядочены
      Reference storageReference = _firebaseStorage.ref().child(pathImage);
      // Для загрузки картики
      UploadTask uploadTask = storageReference.putFile(File(path.path));
      // Snapshot для того чтобы достать пусть к картинке с облака
      final snapshot = await uploadTask.whenComplete(() {});

      pathImageUrl = await snapshot.ref.getDownloadURL();

      final String userId = auth.currentUser!.uid.toString();
      final DocumentSnapshot documentSnapshot 
      = await bd.collection('profiles').doc(userId).get();
      documentSnapshot.reference.update({'image':pathImageUrl});
    } catch (e) {
      return null;
    }
  }
  Future deleteImageStorage() async {
    try {

      if(auth.currentUser == null)
        return;

      final String userId = auth.currentUser!.uid.toString();
      final DocumentSnapshot documentSnapshot = await bd.collection('profiles').doc(userId).get();
      final storageRef = FirebaseStorage.instance.ref();
      if(documentSnapshot['image'] == ''){
        return;
      }
      final fileUrl = documentSnapshot['image'];
      var filePath = fileUrl.replaceAll(new RegExp(r'https://firebasestorage.googleapis.com/v0/b/todoflutter-b4400.appspot.com/o/'), '');
      filePath = filePath.replaceAll(new RegExp(r'%2F'), '/');
      filePath = filePath.replaceAll(new RegExp(r'(\?alt).*'), '');
      await bd.collection('profiles').doc(userId).get();
      documentSnapshot.reference.update({'image':''});
      final fileRef = storageRef.child(filePath);
      await fileRef.delete();
    } catch (e) {
      return null;
    }
  }
}
