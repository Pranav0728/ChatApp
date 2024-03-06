// ignore_for_file: use_build_context_synchronously

import 'package:chatapp/CompleteProfile.dart';
import 'package:chatapp/HomePage.dart';
import 'package:chatapp/UiHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  signUp(String email, String password) async {
    UIHelper.showLoadingDialog(context, "Creating new account...");
    UserCredential? credential;
    if (email.isEmpty || password.isEmpty) {
      Navigator.pop(context);
      showCustomAlert(context, "Enter Required Fields", Colors.red);
    } else {
      try {
        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential != null) {
          String uid = credential.user!.uid;
          UserModel newuser = UserModel(
            uid: uid,
            email: email,
            fullname: "",
            profilepic: "",
          );

          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .set(newuser.toMap());

          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) {
              return CompleteProfile(
                  userModel: newuser, firebaseUser: credential!.user!);
            }),
          );
        } else {
          Navigator.pop(context);
          showCustomAlert(context, "Error", Colors.red);
        }
      } on FirebaseAuthException catch (ex) {
        Navigator.pop(context);
        showCustomAlert(context, ex.message ?? "An error occurred", Colors.red);
      } catch (e) {
        Navigator.pop(context);
        showCustomAlert(context, e.toString(), Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
              child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Text(
                "SignUp Page",
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
                obscureText: true,
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
                    signUp(emailController.text.toString().trim(),
                        passwordController.text.toString().trim());
                  },
                  child: const Text(
                    "Signup",
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
      ))),
    );
  }
}
