import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skypeclone/resources/firebase_rapository.dart';
import 'package:skypeclone/screens/HomeScreen.dart';
import 'package:skypeclone/screens/LoginScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    FirebaseRepository firebaseRepository = FirebaseRepository();
//    firebaseRepository.signOut();
    return MaterialApp(
      title: "Skype App",
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: firebaseRepository.getCurrentUser(),
        builder: (context, snapshot){
          print("Snapshot ${snapshot.data}");
          if(snapshot.hasData){
            return LoginScreen();
          }else{
            return LoginScreen();
          }
        },
      )
    );
  }
}

