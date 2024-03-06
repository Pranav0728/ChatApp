// ignore_for_file: use_build_context_synchronously
import 'package:chatapp/CompleteProfile.dart';
import 'package:chatapp/HomePage.dart';
import 'package:chatapp/SigupPage.dart';
import 'package:chatapp/UiHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Login(String email, String password) async {
    UIHelper.showLoadingDialog(context, "Logging In...");
    if (email == "" || password == "") {
      Navigator.pop(context);
      showCustomAlert(context, "Enter Required fields", Colors.red);
    } else {
      UserCredential? userCredential;
      try {
        userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        if (userCredential != null) {
          String uid = userCredential.user!.uid;
          DocumentSnapshot userData = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          UserModel userModel =
              UserModel.fromMap(userData.data() as Map<String, dynamic>);

          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                    userModel: userModel, firebaseUser: userCredential!.user!)),
          );
        } else {
          Navigator.pop(context);
          showCustomAlert(context, "Unsuccessful", Colors.red);
        }
      } on FirebaseAuthException catch (ex) {
        Navigator.pop(context);
        showCustomAlert(context, ex.code.toString(), Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Text(
                "Login Page",
                style: TextStyle(
                    fontSize: 30, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                decoration: const InputDecoration(label: Text("Enter email")),
                controller: emailController,
              ),
              TextField(
                decoration:
                    const InputDecoration(label: Text("Enter Password")),
                controller: passwordController,
              ),
              const SizedBox(
                height: 30,
              ),
              CupertinoButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    Login(emailController.text.toString().trim(),
                        passwordController.text.toString().trim());
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      )),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't Have an Account? ",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
              child: const Text(
                "Sign Up",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignupPage()));
              })
        ],
      ),
    );
  }
}
