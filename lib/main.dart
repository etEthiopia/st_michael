import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:st_michael/classes.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
CollectionReference classes = firestore.collection('classes');
CollectionReference students = firestore.collection('students');
FirebaseApp firebaseApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  firebaseApp = await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void initFirebaseApp() async {
    firebaseApp = await Firebase.initializeApp();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "St. Michael",
        debugShowCheckedModeBanner: false,
        routes: {'/classess_page': (context) => ClassesPage()},
        home: ClassesPage(),
        theme: Theme.of(context).copyWith(
          appBarTheme: Theme.of(context)
              .appBarTheme
              .copyWith(brightness: Brightness.dark),
        ));
  }
}
