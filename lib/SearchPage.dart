// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:chatapp/ChatRoomPage.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SearchPage extends StatefulWidget {
  final User firebaseUser;
  final UserModel userModel;
  const SearchPage(
      {super.key, required this.firebaseUser, required this.userModel});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existinngChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existinngChatroom;
      log("Chatroom already created");
    } else {
      ChatRoomModel newChatroom =
          ChatRoomModel(chatroomid: uuid.v1(), lastMessage: "", participants: {
        widget.userModel.uid.toString(): true,
        targetUser.uid.toString(): true,
      });
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());
      log("Chatroom Created");
      chatRoom = newChatroom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Search",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CupertinoButton(
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  setState(() {});
                },
                child: const Text(
                  "Search",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: searchController.text)
                    .where("email", isNotEqualTo: widget.userModel.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      if (dataSnapshot.docs.isNotEmpty) {
                        Map<String, dynamic> userMap =
                            dataSnapshot.docs[0].data() as Map<String, dynamic>;
                        UserModel searchUser = UserModel.fromMap(userMap);

                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatroomModel =
                                await getChatroomModel(searchUser);
                            if (chatroomModel != null) {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                          targetUser: searchUser,
                                          chatroom: chatroomModel,
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser)));
                            }
                          },
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            backgroundImage:
                                NetworkImage(searchUser.profilepic!),
                          ),
                          title: Text(searchUser.fullname!),
                          subtitle: Text(searchUser.email!),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                        );
                      } else {
                        return const Text("No result Found");
                      }
                    } else if (snapshot.hasError) {
                      return const Text("An Error Occured!");
                    } else {
                      return const Text("No result Found");
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                })
          ],
        ),
      )),
    );
  }
}
