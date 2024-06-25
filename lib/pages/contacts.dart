import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/NavBar.dart';
import 'package:flutter_application_1/pages/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
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
        child: 
        Container(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 0.1, 
            MediaQuery.of(context).size.width * 0.12,
            MediaQuery.of(context).size.width * 0.1,
            MediaQuery.of(context).size.width * 0.06
          ),
          child: Column(
            children: [
              Image.asset('assets/Contact1.png', width: MediaQuery.of(context).size.width * 0.8),
              SizedBox(height: MediaQuery.of(context).size.width * 0.12),
              Image.asset('assets/Contact2.png', width: MediaQuery.of(context).size.width * 0.8),
              SizedBox(height: MediaQuery.of(context).size.width * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      final Uri _url = Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ&pp=ygUN0YDQuNC6INGA0L7Quw%3D%3D');
                      await launchUrl(_url);
                    },
                    backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                    child: Image.asset('assets/WK.png'),
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      final Uri _url = Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ&pp=ygUN0YDQuNC6INGA0L7Quw%3D%3D');
                      await launchUrl(_url);
                    },
                    backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                    child: Image.asset('assets/YouTube.png'),
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      final Uri _url = Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ&pp=ygUN0YDQuNC6INGA0L7Quw%3D%3D');
                      await launchUrl(_url);
                      
                    },
                    backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                    child: Image.asset('assets/Telegram.png'),
                  )
              ],)
            ],
          ),
        )
      )
    );
  }
}