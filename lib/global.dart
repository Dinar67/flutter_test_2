library globals;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

File? selectImage;
UploadTask? uploadTask;
String? typeItem;
DocumentSnapshot? selectedItem;
