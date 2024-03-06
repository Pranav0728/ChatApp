import 'dart:io';
import 'package:chatapp/HomePage.dart';
import 'package:chatapp/UiHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final nameController = TextEditingController();
  File? imageFile;

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  cropImage(XFile file) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: file.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 20);
      if (croppedFile != null) {
        setState(() {
          imageFile = File(croppedFile.path);
        });
      }
    } catch (e) {
      // Handle any exceptions that might occur during cropping
      showCustomAlert(context, "Error cropping image: $e", Colors.red);
    }
  }

  checkValue() {
    if (nameController == "" || imageFile == null) {
      showCustomAlert(context, "Enter Required Fields", Colors.red);
    } else {
      uploadData();
    }
  }

  uploadData() async {
    UIHelper.showLoadingDialog(context, "Uploading Image...");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("ProfilePic")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = await nameController.text.toString();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) =>
            showCustomAlert(context, "Successfull Profile Set", Colors.green))
        .then((value) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(
              userModel: widget.userModel, firebaseUser: widget.firebaseUser);
        }),
      );
    });
  }

  showAlertBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Pick Image from"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text("Camera"),
                  onTap: () {
                    selectImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo),
                  title: Text("Gallery"),
                  onTap: () {
                    selectImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Profile"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: showAlertBox,
              child: CircleAvatar(
                radius: 60,
                child: imageFile != null
                    ? CircleAvatar(
                        radius: 60,
                        backgroundImage: FileImage(imageFile!),
                      )
                    : Icon(
                        Icons.person,
                        size: 60,
                      ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              decoration: const InputDecoration(label: Text("Enter Name")),
              controller: nameController,
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  checkValue();
                },
                child: const Text(
                  "Set",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )),
          ],
        ),
      )),
    );
  }
}
