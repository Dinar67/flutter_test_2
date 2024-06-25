// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/colors.dart';
import 'package:flutter_application_1/pages/database/databaseAuth/auth_service.dart';
import 'package:flutter_application_1/global.dart' as globals;


final colRef = FirebaseFirestore.instance.collection('profiles');

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();

  
}

class _NavbarState extends State<Navbar> {

  final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    dynamic userDoc;


  getUserById() async {
      if(auth.currentUser == null) {
        return;
      }
      final String userId = auth.currentUser!.uid.toString();
      final DocumentSnapshot documentSnapshot = await colRef.doc(userId).get();
      setState(() {
          userDoc = documentSnapshot;
      });
    }

  @override
  void initState() {
    getUserById();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    
    
   
    return Drawer(

      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,

        children: [
          UserAccountsDrawerHeader(
             accountName: Text(
              // "Dinar",
              auth.currentUser != null? userDoc['name'] : '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
             ),
             accountEmail: Text(auth.currentUser == null? '' : auth.currentUser!.email.toString()),
             currentAccountPicture: CircleAvatar(
              child:
              ClipOval(
                child: auth.currentUser != null? 
              userDoc['image'] == ''? 
                    (globals.selectImage == null? Image.asset('assets/person.png') 
                    : 
                    Image.file(globals.selectImage!, width: 200, height: 200, fit: BoxFit.cover,)) 
                    : Image.network(userDoc['image'],
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,)
                :
                Image.asset('assets/person.png')
              ),
             ),
             decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover
              ),
              
             ),
          ),
          ListTile(
            minTileHeight: 50,
            leading: const Icon(Icons.home, color: Colors.white,),
            title: const Text("Главная страница", style: TextStyle(
              color: Colors.white
            ),),
            onTap: (){
              Navigator.pushReplacementNamed(context, '/');
            },
            
          ),
          const Divider(),
          auth.currentUser != null?
          ListTile(
            minTileHeight: 50,
            leading: const Icon(Icons.person, color: Colors.white,),
            title: const Text("Мой профиль", style: TextStyle(
              color: Colors.white
            ),),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            }
          )
          :
              const SizedBox(),
          auth.currentUser != null? const Divider() : const SizedBox(),
          ListTile(
            minTileHeight: 50,
            leading: const SizedBox(),
            title: const Text("Игровые ПК", style: TextStyle(color: Colors.white),),
            onTap: (){
              globals.typeItem = 'ПК';
              Navigator.pushReplacementNamed(context, '/list');
            },
            
          ),
          
          
          ListTile(
            minTileHeight: 50,
            leading: const SizedBox(),
            title: const Text("Ноутбуки", style: TextStyle(color: Colors.white),),
            onTap: (){
              globals.typeItem = 'Ноутбук';
              Navigator.pushReplacementNamed(context, '/list');
            },
            
          ),
          
         
          ListTile(
            minTileHeight: 50,
            leading: const SizedBox(),
            title: const Text("Видеокарты", style: TextStyle(color: Colors.white),),
            onTap: (){
              globals.typeItem = 'Видеокарта';
              Navigator.pushReplacementNamed(context, '/list');
            },
            
          ),
          
          
          ListTile(
            minTileHeight: 50,
            leading: const SizedBox(),
            title: const Text("Аксессуары", style: TextStyle(color: Colors.white),),
            onTap: (){
              globals.typeItem = 'Аксессуар';
              Navigator.pushReplacementNamed(context, '/list');
            },
            
          ),
          
          const Divider(),
          ListTile(
            minTileHeight: 50,
            leading: const SizedBox(),
            title: const Text("О нас", style: TextStyle(color: Colors.white),),
            onTap: (){
              Navigator.pushReplacementNamed(context, '/about');
            },
            
          ),
          const Divider(),
          ListTile(
            minTileHeight: 50,
            leading: const SizedBox(),
            title: const Text("Контакты", style: TextStyle(color: Colors.white),),
            onTap: (){
              Navigator.pushReplacementNamed(context, '/contacts');
            },
            
          ),
          
          const Divider(),

          auth.currentUser != null?
          ListTile(
            minTileHeight: 50,
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text("Выйти", style: TextStyle(color: Colors.white),),
            onTap: (){
              AuthService().logOut();
              Navigator.pushReplacementNamed(context, '/auth');
            },
            
          ) : ListTile(
            leading: const Icon(Icons.login, color: Colors.white),
            title: const Text("Войти", style: TextStyle(color: Colors.white),),
            onTap: (){
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
    );
  }
}