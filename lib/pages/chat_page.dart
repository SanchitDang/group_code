import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:group_code/pages/group_info.dart';
import 'package:group_code/service/database_service.dart';
import 'package:group_code/widgets/message_tile.dart';
import 'package:group_code/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/theme_map.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? imageFile;

  Future getImage() async {
    ImagePicker picker = ImagePicker();

    await picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  //have to complete
  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;

    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .doc(fileName)
        .set({
      "sender": widget.userName,
      "message": "",
      "type": "img",
      "time": DateTime.now().millisecondsSinceEpoch,
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(fileName)
          .update({"message": imageUrl});

    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                //captureImage('profile');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                // _pickImage(ImageSource.gallery, 'profile');
                getImage();
                // Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Add code'),
              onTap: () {
                // _pickImage(ImageSource.gallery, 'profile');
                sendCode();
                // Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Code EDITOR'),
              onTap: () {
                // _pickImage(ImageSource.gallery, 'profile');
                sendCode();
                // Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }



  @override
  void initState() {
    getChatAndAdmin();
    super.initState();
  }

  getChatAndAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: <Widget>[
          // chat messages here
          chatMessages(),

          // message writing area
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              width: MediaQuery.of(context).size.width,
              height: 80,
              color: Colors.grey[700],
              child: Row(children: [
                IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      //captureImage('profile');
                      _showOptions(context);
                    }),
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.send,
                      color: Colors.white,
                    )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  if (snapshot.data.docs[index]['type'] == 'text') {
                    return MessageTile(
                        message: snapshot.data.docs[index]['message'],
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index]['sender']);
                  } else if (snapshot.data.docs[index]['type'] == 'img') {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowImage(imgUrl: snapshot.data.docs[index]['message']))),
                      child:
                      Container(
                        height: 100,
                        width: 100,
                        alignment:
                            widget.userName == snapshot.data.docs[index]['sender']
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Container(
                            height: 100,
                            width: 100,
                            alignment: Alignment.center,
                            child: snapshot.data.docs[index]['message'] != ""
                                ? Image.network(
                                    snapshot.data.docs[index]['message'])
                                : const CircularProgressIndicator(color: Colors.grey,)),
                      ),
                    );

                  }
                  else if (snapshot.data.docs[index]['type'] == 'code') {
                    return Container(
                      alignment:
                      widget.userName == snapshot.data.docs[index]['sender']
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: snapshot.data.docs[index]['message'] != ""
                          ?  HighlightView(
                        snapshot.data.docs[index]['message'],
                        language: 'python', // Enable automatic language detection
                      )
                          : const CircularProgressIndicator(color: Colors.grey,),
                    );
                  }
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "type": "text",
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }

  sendCode() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "type": "code",
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

      groupCollection.doc(widget.groupId).collection("messages").add(chatMessageMap);
      groupCollection.doc(widget.groupId).update({
        "recentMessage": chatMessageMap['message'],
        "recentMessageSender": chatMessageMap['sender'],
        "recentMessageTime": chatMessageMap['time'].toString(),
      });


      setState(() {
        messageController.clear();
      });
    }
  }
}


class ShowImage extends StatelessWidget {
  const ShowImage({required this.imgUrl, Key? key}) : super(key: key);

  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imgUrl),
      ),    );
  }
}
