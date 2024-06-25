import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/NavBar.dart';
import 'package:flutter_application_1/pages/basket.dart';
import 'package:flutter_application_1/pages/colors.dart';
import 'package:flutter_application_1/pages/database/FirebaseFirestore/item_collection.dart';
import 'package:flutter_application_1/pages/database/Firebase_storage/image_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_application_1/global.dart' as globals;
import 'package:image_picker/image_picker.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
final ItemCollection itemCollection = ItemCollection();
final items = ['ПК', 'Ноутбук', 'Видеокарта', 'Аксессуар'];

String? typeAction;
XFile? fileName;
ImageStorage imageStorage = ImageStorage();
dynamic userDoc;
UploadTask? uploadTask;
String userId = FirebaseAuth.instance.currentUser!.uid.toString();
final String search = ''; 



void _show(String value){
    Fluttertoast.showToast(
      msg: value,
      gravity: ToastGravity.BOTTOM_LEFT,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }



  DropdownMenuItem<String> buildMenuItem(String item) =>
      DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: const TextStyle(color: Colors.white),
          )
      );


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
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02,)
        ]);
        }
        else{
          return SizedBox(height: MediaQuery.of(context).size.height * 0.03,);
        }
      }
      else{
        return SizedBox(height: MediaQuery.of(context).size.height * 0.03,);
      }
    },);

class _AlertAddEdit extends StatefulWidget {
  const _AlertAddEdit({super.key});

  @override
  State<_AlertAddEdit> createState() => __AlertAddEditState();
}

class __AlertAddEditState extends State<_AlertAddEdit> {

getUserById() async {
    final DocumentSnapshot documentSnapshot = await colRef.doc(userId).get();
    setState(() {
      userDoc = documentSnapshot;
      
    });
  }

selectImageGallery(String typeImageToLoad) async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if(returnImage == null){
      _show("Вы не выбрали изображение!");
      return;
    }

    setState(() {
      uploadFile(returnImage, typeImageToLoad);
      fileName = returnImage;
    });
    _show("вы выбрали изображение");
  }

@override
  void initState() {
    getUserById();
    super.initState();
  }

  Future uploadFile(XFile fileName, String typeImageToLoad) async {
    final path = 'items/${globals.selectedItem?['name']}/${fileName.name}';
    final file = File(fileName.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});

    final pathImageUrl = await snapshot.ref.getDownloadURL();

    if(typeImageToLoad == 'MainImage') {
      globals.selectedItem?.reference.update({'image':pathImageUrl});
    } else {
      globals.selectedItem?.reference.update({'complectation':pathImageUrl});
    }

      setState(() {
        uploadTask = null;
        _show("Успешно!");
      });
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String? dropValue = globals.typeItem;
    if(typeAction == 'edit'){
      nameController.text = globals.selectedItem?['name'];
      priceController.text = globals.selectedItem?['price'];
      descriptionController.text = globals.selectedItem?['description'];
    }

    return AlertDialog(
                  scrollable: true,
                  backgroundColor: appBarBackgroundColor,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(typeAction != 'edit'?
                        'Добавить товар' : 'Редактировать товар',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: dropValue,

                        items: items.map(buildMenuItem).toList(),
                        dropdownColor: appBarBackgroundColor,
                        onChanged: (String? value) {
                            dropValue = value;
                        },
                        onSaved: (value){
                            dropValue = value;
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      if(typeAction != 'add')
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: FloatingActionButton(
                          onPressed: (){
                            selectImageGallery('MainImage');
                          },
                          backgroundColor: buutonBackgroundColor,
                          child: const Text('Загрузить основное изображение',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        )
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                      if(globals.typeItem != 'Аксессуар' && typeAction != 'add')
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: FloatingActionButton(
                          onPressed: (){
                            selectImageGallery('Complectation');
                          },
                          backgroundColor: buutonBackgroundColor,
                          child: const Text('Загрузить комплектацию',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        )
                      ),
                      buildProgress(),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Название',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Цена',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Описание',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child:
                      FloatingActionButton(
                        onPressed: () async {
                          if(typeAction == 'edit'){
                            db.collection('items').doc(globals.selectedItem!.id).update({
                            'name': nameController.text,
                            'price': priceController.text,
                            'description': descriptionController.text,
                            'type': dropValue,
                          });
                            Navigator.pop(context);
                            _show('Успешно изменено!');
                            return;
                          }

                          db.collection('items').add({
                            'name': nameController.text,
                            'price': priceController.text,
                            'description': descriptionController.text,
                            'type': dropValue,
                            'image': '',
                            'complectation': '',
                          });
                          Navigator.pop(context);
                          _show('Товар успешно добавлен!');
                        },
                        backgroundColor: buutonBackgroundColor,
                        child: const Text('Сохранить',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),)
                    ],
                  ),
                );
  }
}





class ItemsList extends StatefulWidget {
  const ItemsList({super.key});

  @override
  State<ItemsList> createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  getUserById() async {
    if(auth.currentUser == null){
      userDoc = null;
      return;
    }
    final DocumentSnapshot documentSnapshot = await colRef.doc(auth.currentUser!.uid).get();
    setState(() {
      userDoc = documentSnapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    getUserById();
    return Scaffold(
      key: _scaffoldkey,
      floatingActionButton: userDoc != null && userDoc['role'] == 'admin'? FloatingActionButton(
        backgroundColor: buutonBackgroundColor,
        onPressed: () {
          typeAction = 'add';
          showDialog(
              context: context,
              builder: (context) {
                return const _AlertAddEdit();
              });
        },
        child: const Icon(Icons.add, color: Colors.black),
      ) : SizedBox(),
      endDrawer: const Navbar(),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        actions: [
          SizedBox(
            width: 25,
            height: 25,
            child:  FloatingActionButton(onPressed: (){
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
          icon: const Icon(Icons.menu))
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

      body: StreamBuilder(
        stream: db.collection('items').where('type', isEqualTo: globals.typeItem).snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return const Center(child:  CircularProgressIndicator(
              backgroundColor: Colors.white,
            ));
          }
          
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, int index){
              
              return Card(
                margin: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.1,
                    20,
                    MediaQuery.of(context).size.width * 0.1,
                    10
                ),
                color: appBarBackgroundColor,
                key: Key(snapshot.data!.docs[index].id),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                      if (snapshot.data!.docs[index].get('image') == '') 
                      Image.asset(
                        'assets/logo.png',
                         height: MediaQuery.of(context).size.height * 0.3,
                         width: MediaQuery.of(context).size.height * 0.3,
                      ),
                      if (snapshot.data!.docs[index].get('image') != '') 
                      Image.network(
                        snapshot.data!.docs[index].get('image'),
                         height: MediaQuery.of(context).size.height * 0.3,
                         width: MediaQuery.of(context).size.height * 0.3,
                      )
                      ,
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Container(
                        transformAlignment: Alignment.center,
                        child: Text(snapshot.data!.docs[index].get('name'),
                        style: const TextStyle(color: Colors.white),),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Container(
                        transformAlignment: Alignment.center,
                        child: Text(snapshot.data!.docs[index].get('price') + ' руб.',
                            style: const TextStyle(color: Colors.white)),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if(userDoc != null && userDoc['role'] == 'admin')
                            IconButton(onPressed: () async {
                              typeAction = 'edit';
                              globals.selectedItem = snapshot.data!.docs[index];
                              showDialog(
                                context: context,
                                builder: (context) 
                                { 
                                  return const _AlertAddEdit(); 
                                }
                              );
                            }, icon: const Icon(Icons.edit, color: Colors.white,)
                            ),
                              Container(
                                padding: const EdgeInsets.only(bottom: 5),
                                width: MediaQuery.of(context).size.width * 0.4,
                                  height: MediaQuery.of(context).size.width * 0.1,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      globals.selectedItem = snapshot.data!.docs[index];
                                      Navigator.pushNamed(context, '/item');
                                    },
                                    backgroundColor: buutonBackgroundColor,
                                    child: const Text('Подробнее', style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                    ),

                                    ),
                                )
                              ),
                              userDoc != null && userDoc['role'] == 'admin'?
                              IconButton(onPressed: () async {
                                await db.collection('items').doc(snapshot.data!.docs[index].id).delete();
                                _show('Удалено!');
                                }, icon: const Icon(Icons.delete, color: Colors.white,)
                              ):const SizedBox()
                          ]),

                     
                    ],
                  ),
                ),
              );
            }
          );
        },
      ),
      
    );
  }
}
