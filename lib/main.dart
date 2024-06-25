import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/about_us.dart';
import 'package:flutter_application_1/pages/auth.dart';
import 'package:flutter_application_1/pages/basket.dart';
import 'package:flutter_application_1/pages/colors.dart';
import 'package:flutter_application_1/pages/contacts.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:flutter_application_1/pages/item.dart';
import 'package:flutter_application_1/pages/item_list.dart';
import 'package:flutter_application_1/pages/main_screen.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/reg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBxzoLj2LR4a1cDG50mLm_rzjq4vLlA9eI',
      appId: '1:393047326133:android:30c83466a44380fafcedfc',
      messagingSenderId: '393047326133',
      projectId: 'todoflutter-b4400',
      storageBucket: 'todoflutter-b4400.appspot.com',)
  );
  FirebaseAuth auth = FirebaseAuth.instance;
  runApp(MaterialApp(
    theme: ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity
    ),
    debugShowCheckedModeBanner: false,
    initialRoute: auth.currentUser == null? '/auth' : '/',
    routes: {
      '/': (context) => const MainScreen(),
      '/toDoList': (context) => const Home(),
      '/auth':(context) => const AuthPage(),
      '/reg':(context) => const RegistrationPage(),
      '/profile':(context) => const ProfilePage(),
      '/list':(context) => ItemsList(),
      '/about':(context) => const AboutUs(),
      '/contacts':(context) => const Contacts(),
      '/item':(context) => const ItemPage(),
      '/basket':(context) => const BasketPage()
      },
    )
  );
}

