import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/NavBar.dart';
import 'package:flutter_application_1/pages/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore db = FirebaseFirestore.instance;
final String userId = auth.currentUser!.uid;




void _show(String value){
    Fluttertoast.showToast(
      msg: value,
      gravity: ToastGravity.BOTTOM_LEFT,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

Future<DocumentSnapshot> getItemDocument(String id) async {
  final DocumentSnapshot doc = await db.collection('items').doc(id).get();
  return doc;
}

class BasketPage extends StatefulWidget {
  const BasketPage({super.key});

  @override
  State<BasketPage> createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double totalPrice = 0;

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    refreshTotalPrice();
  });
}

  void refreshTotalPrice() async {
      totalPrice = 0;

    
     final querySnapshot = await db.collection('profiles').doc(userId).collection('basket');
     final docs = await querySnapshot.get();
     for(var doc in docs.docs){
        double? price = double.tryParse(doc.get('price').toString().replaceAll(' ', ''));
        if(price == null){
          _show('Неверный формат цены товара!');
          return;
        }
       setState(() {
         totalPrice += price * doc.get('count');
       });
     }
  }

  void takeOrder() async{

    await db.collection('orders').add({
      'price':totalPrice,
      'dateOrder': DateTime.now(),
      'userId':userId
    });

      final querySnapshot = await db.collection('profiles').doc(userId).collection('basket');
     final docs = await querySnapshot.get();
     for(var doc in docs.docs){
      doc.reference.delete();
     }
     refreshTotalPrice();
     Navigator.popAndPushNamed(context, '/');
     _show('Заказ успешно оформлен! Скоро наш менеджер свяжется с вами');
  }

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

      body:
      SingleChildScrollView(child: 
      Container(
        padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.05,
          MediaQuery.of(context).size.height * 0.05,
          MediaQuery.of(context).size.width * 0.05,
          MediaQuery.of(context).size.height * 0.05
        ),
        child: 
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.67,
                child: 
                StreamBuilder(
                  stream: db.collection('profiles').doc(userId).collection('basket').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, int index) {
                        final itemId = snapshot.data!.docs[index].get('itemId');
                        return FutureBuilder(
                          future: getItemDocument(itemId),
                          builder: (context, snapshot1) {
                          if (snapshot1.hasData) {
                            
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    snapshot1.data?.get('image') == ''?
                                    Image.asset('assets/logo.png', 
                                    width: MediaQuery.of(context).size.width * 0.25)
                                    :
                                    Image.network(snapshot1.data?.get('image'), 
                                    width: MediaQuery.of(context).size.width * 0.25),
                                    SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(snapshot1.data?.get('name'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 50,
                                              height: 20,
                                              child: 
                                              OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(color: buutonBackgroundColor),
                                                ),
                                                onPressed: () async {
                                                  if(snapshot.data!.docs[index].get('count') == 1)
                                                    return;
                                                  await snapshot.data!.docs[index].reference.update({
                                                    'count': snapshot.data!.docs[index].get('count') - 1,
                                                  });

                                                  refreshTotalPrice();
                                                },
                                                child: const Text('-', style: TextStyle(color: Colors.white))
                                              )
                                            ),
                                            const SizedBox(width: 10),
                                            Text(snapshot.data!.docs[index].get('count').toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            SizedBox(
                                              width: 50,
                                              height: 20,
                                              child: 
                                              OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(color: buutonBackgroundColor),
                                                ),
                                                onPressed: () async {
                                                  await snapshot.data!.docs[index].reference.update({
                                                    'count': snapshot.data!.docs[index].get('count') + 1
                                                  });
                                                   refreshTotalPrice();
                                                },
                                                child: const Text('+', style: TextStyle(color: Colors.white))
                                              )
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),

                                        Row(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.4,
                                              child: Text('Цена:  ${snapshot1.data?.get('price')} руб.',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                              width: 60,
                                              child: FloatingActionButton(
                                                onPressed: () async {
                                                  await snapshot.data!.docs[index].reference.delete();
                                                  _show('Товар успешно удален из корзины!');
                                                },
                                                backgroundColor: buutonBackgroundColor,
                                                child: const Text(
                                                  'удалить',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10
                                                  ),
                                                ),
                                              )
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Divider(
                                  color: buutonBackgroundColor,
                                )
                              ],
                            );
                            
                          } else {
                          return const Center(child: CircularProgressIndicator());
                          }
                        },
                      );
                    },
                  );
                },
              ),
              ),
              SizedBox(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Итого:', style: 
                        TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),),
                        Text(totalPrice.toStringAsFixed(0) + ' руб.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),)
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: 
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: buutonBackgroundColor)
                        ),
                        onPressed: () async{
                          takeOrder();
                        },
                        child: const Text('К оформлению',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),)
                      )
                    )
                  ],
                ),
              )
            ]
          )
        )
      )
    );
  }
}