import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/NavBar.dart';
import 'package:flutter_application_1/pages/colors.dart';
import 'package:flutter_application_1/pages/database/FirebaseFirestore/profile_collection.dart';
import 'package:flutter_application_1/pages/database/Firebase_storage/image_storage.dart';
import 'package:flutter_application_1/pages/database/databaseAuth/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/global.dart' as globals;


final colRef = FirebaseFirestore.instance.collection('profiles');


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userId = FirebaseAuth.instance.currentUser!.uid.toString();
  dynamic userDoc;
  UploadTask? uploadTask;

  XFile? fileName;
  ImageStorage imageStorage = ImageStorage();
  ProfileCollection profileCollection = ProfileCollection();

  



  TextEditingController surnameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController patronymicController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  AuthService authService = AuthService();

  bool visibility = false;
  


  void _show(String value){
    Fluttertoast.showToast(
                      msg: value,
                      gravity: ToastGravity.BOTTOM_LEFT,
                      timeInSecForIosWeb: 1,
                      textColor: Colors.white,
                      fontSize: 16.0,              
                    );
  }

  selectImageGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if(returnImage == null){
      _show("Вы не выбрали изображение!");
      return;
    }

    setState(() {
      globals.selectImage = File(returnImage.path);
      uploadFile(returnImage);
      fileName = returnImage;
    });
    _show("вы выбрали изображение");
  }

  ////////Метод отправки на облако//////////////

  

  getUserById() async {
    final DocumentSnapshot documentSnapshot = await colRef.doc(userId).get();
    setState(() {
      userDoc = documentSnapshot;
      
    });
  }

  void deleteImage() async {
    setState(() {
      globals.selectImage = null;
      visibility = false;
    });
  }
  

  @override
  void initState() {
    getUserById();
    super.initState();
  }

  Future uploadFile(XFile fileName) async {
    imageStorage.deleteImageStorage();
    final path = 'userLogo/${fileName.name}';
    final file = File(fileName.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});

    final pathImageUrl = await snapshot.ref.getDownloadURL();
  
      final DocumentSnapshot documentSnapshot = await colRef.doc(userId).get();
      documentSnapshot.reference.update({'image':pathImageUrl});

      setState(() {
        uploadTask = null;
        visibility = true;
        _show("Успешно!");
      });
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
    stream: uploadTask?.snapshotEvents,
    builder: (context, snapshot)
    {
      if(snapshot.hasData){
        final data = snapshot.data!;
        double progress = data.bytesTransferred / data.totalBytes;
        if(progress != 1){
        return Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
            SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
          width: MediaQuery.of(context).size.width * 0.6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey,
                color: buutonBackgroundColor,

              ),
              Center(
                child: Text(
                  '${(100 * progress).roundToDouble()}%',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        )]);
        }
        else{
          return SizedBox(height: MediaQuery.of(context).size.height * 0.03,);
        }
      }
      else{
        return SizedBox(height: MediaQuery.of(context).size.height * 0.03,);
      }
    },);


  @override
  Widget build(BuildContext context) {
    surnameController.text = userDoc['surname'];
    nameController.text = userDoc['name'];
    patronymicController.text = userDoc['patronymic'];
    phoneController.text = userDoc['phone'];
    final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return Scaffold(
      key: _scaffoldkey,
      endDrawer: const Navbar(),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        actions: [
          SizedBox(
            width: 25,
            height: 25,
            child: FloatingActionButton(onPressed: (){
              if(_auth.currentUser == null){
                Navigator.popAndPushNamed(context, '/auth');
              }
              else{
                Navigator.popAndPushNamed(context, '/basket');
              }
            },
            child: Image.asset('assets/Basket.png'),
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
            ),
          ),
          IconButton(onPressed: (){
            _scaffoldkey.currentState?.openEndDrawer();
          },
          icon: Icon(Icons.menu))
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        leadingWidth: 120,
        leading: Row(
          children: 
        [
          const SizedBox(width: 20,),
          SizedBox(
             child: 
          Image.asset('assets/logo.png',
            height: MediaQuery.of(context).size.height * 0.025, // Установите высоту
            width: 100, // Установите ширину
            fit: BoxFit.cover,),
          )
        ]
      ),
        
        backgroundColor: appBarBackgroundColor,
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                  child: ClipOval(
                    child: userDoc['image'] == ''? 
                    (globals.selectImage == null? Image.asset('assets/person.png') 
                    : 
                    Image.file(globals.selectImage!, width: 200, height: 200, fit: BoxFit.cover,)) 
                    : Image.network(userDoc['image'],
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,)
                    
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(onPressed: () async {
                        selectImageGallery();
                          
                      }, icon: const Icon(
                        Icons.add, color: Colors.white,
                        )
                      ),
                      IconButton(onPressed: (){
                        imageStorage.deleteImageStorage();
                        deleteImage();
                        initState();
                      }, icon: const Icon(
                        Icons.delete, color: Colors.white,
                        )
                      )
                    ],
                  )
                ],
              ),
              buildProgress(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: surnameController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.face,
                      color: Colors.white70,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    labelText: 'Фамилия',
                    labelStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    hintText: 'Фамилия',
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.face,
                      color: Colors.white70,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    labelText: 'Имя',
                    labelStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    hintText: 'Имя',
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: patronymicController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.face,
                      color: Colors.white70,
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    labelText: 'Отчество',
                    labelStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    hintText: 'Отчество',
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: phoneController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Colors.white70,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    labelText: 'Телефон',
                    labelStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    hintText: 'Телефон',
                    hintStyle: const TextStyle(color: Colors.white38),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: FloatingActionButton(
                  onPressed: () async {
                    if (surnameController.text.isEmpty ||
                        nameController.text.isEmpty ||
                        patronymicController.text.isEmpty ||
                        phoneController.text.isEmpty) {
                      _show("Заполните все поля!");
                    } else {
                    profileCollection.editProfile(
                      userDoc['uid'], surnameController.text, nameController.text,
                       patronymicController.text, phoneController.text
                      );
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    }
                  },
                  backgroundColor: buutonBackgroundColor,
                  child: const Text('Сохранить',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
