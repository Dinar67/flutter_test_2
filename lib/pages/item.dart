// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/NavBar.dart';
import 'package:flutter_application_1/pages/colors.dart';
import 'package:flutter_application_1/global.dart' as globals;

final FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

class complectation extends StatefulWidget {
  const complectation({super.key});

  @override
  State<complectation> createState() => _complectationState();
}

class _complectationState extends State<complectation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Комплектация', style: 
                    TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16
                    ),
                  ),
        SizedBox(height: MediaQuery.of(context).size.width * 0.03,),
        Image.network(globals.selectedItem?.get('complectation'),
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.75,
          alignment: Alignment.centerLeft,
        )
      ],
    );
  }
}

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
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

      body: SingleChildScrollView(child: 
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: (){ Navigator.pop(context); },
             icon: const Icon(Icons.arrow_back_sharp, color: Colors.white,)
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(globals.selectedItem?.get('name'), style: 
                    const TextStyle(
                    color: buutonBackgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(globals.selectedItem?.get('description'), style: 
                    const TextStyle(
                    color: Colors.white,
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.1,
                      MediaQuery.of(context).size.height * 0.02,
                      MediaQuery.of(context).size.width * 0.1,
                      MediaQuery.of(context).size.height * 0.02
                    ),
                    child: globals.selectedItem?.get('image') == ''?
                      Image.asset('assets/logo.png',
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.8,
                        )
                      :
                      Image.network(globals.selectedItem?.get('image'),
                        height: MediaQuery.of(context).size.height * 0.37,
                        width: MediaQuery.of(context).size.width * 0.8,
                      ),
                  ),
                  

                  globals.selectedItem?.get('complectation') != ''?
                  const complectation() : const SizedBox(),
                  
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                  // ignore: prefer_interpolation_to_compose_strings
                  Text('Цена: ${globals.selectedItem?.get('price')} руб.', style: 
                    const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 30,
                    width: 130,
                    child: 
                    FloatingActionButton(
                      onPressed: (){
                        
                        var user = auth.currentUser;
                        if(user == null){
                          Navigator.popAndPushNamed(context, '/auth');
                          return;
                        }

                        db.collection('profiles').doc(user.uid).collection('basket').add({
                          'itemId': globals.selectedItem?.id,
                          'count': 1,
                          'price':  globals.selectedItem?.get('price')
                        });
                        Navigator.popAndPushNamed(context, '/basket');
                      },
                      backgroundColor: buutonBackgroundColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        const Text(
                          'В КОРЗИНУ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 10
                          ),
                        ),
                        SizedBox(width: 5),
                        Image.asset('assets/BasketBlack.png', height: 18,)
                      ]
                      )
                    )
                  ),

                ],
                ),
            )
        ],
        ),
      )
    );

  
  }
}