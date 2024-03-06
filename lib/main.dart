import 'package:chatapp/HomePage.dart';
import 'package:chatapp/LoginPage.dart';
import 'package:chatapp/models/FirebaseHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(myAppLogedin(userModel: thisUserModel, firebaseUser: currentUser));
    } else {
      runApp(const myApp());
    }
  } else {
    runApp(const myApp());
  }
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ChatApp",
      home: LoginPage(),
    );
  }
}

class myAppLogedin extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const myAppLogedin(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ChatApp",
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
