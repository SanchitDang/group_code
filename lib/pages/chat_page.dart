import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:group_code/MessageModel.dart';
import 'package:group_code/pages/code_editor_screen.dart';
import 'package:group_code/pages/group_info.dart';
import 'package:group_code/service/database_service.dart';
import 'package:group_code/widgets/message_tile.dart';
import 'package:group_code/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:uuid/uuid.dart';
import '../widgets/code_tile.dart';
import '../widgets/image_tile.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';

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
  String userId = FirebaseAuth.instance.currentUser!.uid;
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
              title: const Text('Send as code'),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
            ),
          ],
        );
      },
    );
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
  void initState() {
    super.initState();
    connectServer();
    // getChatAndAdmin();
  }

  List<MessageModel> chatsList = [];
  late Socket socket;

  // void connectServer() {
  //   String ip = 'http://192.168.1.31:3000';
  //   socket = io(
  //       ip,
  //       OptionBuilder()
  //           .setTransports(['websocket']) // for Flutter or Dart VM
  //           .disableAutoConnect() // disable auto-connection
  //           .setExtraHeaders({'foo': 'bar'}) // optional
  //           .build());
  //   socket.connect();
  //   socket.onConnect((data) {
  //     print('connected with backend...');
  //     socket.on("sendMsgFromServer", (msg) {
  //       //print(msg);
  //
  //       socket.emit('sendGrpId', {'grpId': widget.groupId});
  //
  //       if (msg['userId'] != userId) {
  //         setState(() {
  //           chatsList.add(MessageModel(
  //               message: msg['message'],
  //               sender: msg['sender'],
  //               type: msg['type'],
  //               time: msg['time']));
  //           //print(chatsList);
  //         });
  //       }
  //     });
  //   });
  // }

  void connectServer() {
    String ip = 'http://192.168.1.31:3000';
    socket = io(
      ip,
      OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'foo': 'bar'})
          .build(),
    );

    socket.connect();

    socket.emit('joinGroup', widget.groupId);

    socket.onConnect((_) {
      print('Connected with backend...');

      socket.on("sendMsgFromServer", (msg)
      {
        if (msg['groupName'] == widget.groupId) {
        if (msg['userId'] != userId) {
          setState(() {
            chatsList.add(MessageModel(
              message: msg['message'],
              sender: msg['sender'],
              type: msg['type'],
              time: msg['time'],
            ));
          });
        }
      }
      });


    });
  }


  void sendMsgServer(String grpId, String msg, String type) {
    MessageModel sentMsg = MessageModel(
      message: messageController.text,
      sender: widget.userName,
      type: type,
      time: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    socket.emit("sendMsg", {
      'message': messageController.text,
      'sender': widget.userName,
      'type': type,
      'time': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'groupName': grpId, // Change 'grpId' to 'groupName'
    });

    setState(() {
      chatsList.add(sentMsg);
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
         // chatMessagesServer(),

          // message writing area
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: MediaQuery.of(context).size.width,
              height: 70,
              color: Color.fromRGBO(255, 255, 255, 1),
              child: Row(children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: IconButton(
                      icon: Icon(Icons.add,
                          color: Theme.of(context).primaryColor),
                      onPressed: () {
                        _showOptions(context);
                      }),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: "Send a message...",
                    hintStyle: TextStyle(color: Colors.black, fontSize: 16),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    if (messageController.text.isNotEmpty) {
                      sendMessage();
                      // sendMsgServer(
                      //     widget.groupId, messageController.text, 'text');
                      messageController.clear();
                      setState(() {});
                    }
                  },
                  child: Container(
                    height: 40,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 72),
      child: StreamBuilder(
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
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ShowImage(
                                    imgUrl: snapshot.data.docs[index]
                                        ['message']))),
                        child: ImageTile(
                            message: snapshot.data.docs[index]['message'],
                            sender: snapshot.data.docs[index]['sender'],
                            sentByMe: widget.userName ==
                                snapshot.data.docs[index]['sender']),
                      );
                    } else if (snapshot.data.docs[index]['type'] == 'code') {
                      return CodeTile(
                          message: snapshot.data.docs[index]['message'],
                          sender: snapshot.data.docs[index]['sender'],
                          sentByMe: widget.userName ==
                              snapshot.data.docs[index]['sender']);
                    }
                  },
                )
              : Container();
        },
      ),
    );
  }

  chatMessagesServer() {
    return chatsList.length != 0
        ? ListView.builder(
            itemCount: chatsList.length,
            itemBuilder: (context, index) {
              return MessageTile(
                  message: chatsList[index].message,
                  sender: chatsList[index].sender,
                  sentByMe: widget.userName == chatsList[index].sender);
            },
          )
        : Container();
  }

  sendMessage() {
    Map<String, dynamic> chatMessageMap = {
      "message": messageController.text,
      "sender": widget.userName,
      "type": "text",
      "time": DateTime.now().millisecondsSinceEpoch,
    };

    DatabaseService().sendMessage(widget.groupId, chatMessageMap);
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

      groupCollection
          .doc(widget.groupId)
          .collection("messages")
          .add(chatMessageMap);
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
      ),
    );
  }
}
