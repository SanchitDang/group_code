import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupEditorScreen extends StatefulWidget {
  const GroupEditorScreen({Key? key}) : super(key: key);

  @override
  State<GroupEditorScreen> createState() => _GroupEditorScreenState();
}

class _GroupEditorScreenState extends State<GroupEditorScreen> {
  final TextEditingController _controller = TextEditingController();

  final CollectionReference _textRef =
  FirebaseFirestore.instance.collection('text');

  @override
  void initState() {
    super.initState();
    // listen for changes to the text in the database
    _textRef.doc('Common').snapshots().listen((snapshot) {
      String text = (snapshot.data() as Map<String, dynamic>)['data'] ?? '';
      setState(() {
        // update the text in the text field
        final cursorPos = _controller.selection.end;
        _controller.text = text;
        if (cursorPos == _controller.text.length) {
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
    title: const Text("Group Editor"),),
      body: TextField(
        controller: _controller,
        onChanged: (value) {
          // update the text in the database when the user types
          _textRef.doc('Common').set({'data': value});
        },
      ),
    );


  }
}
