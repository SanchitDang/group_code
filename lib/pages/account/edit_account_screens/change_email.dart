import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../helper/helper_function.dart';
import '../edit_profile_screen.dart';

class ChangeEmail extends StatefulWidget {
  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  final _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final userCollection = FirebaseFirestore.instance.collection('users');

  late Future<String> emailFuture;

  TextEditingController tC = TextEditingController();

  Future<String> getCurrentUserData() async {
    try {
      DocumentSnapshot ds = await userCollection.doc(uid).get();
      String email = ds.get('email');
      setState(() {
        _email = email;
      });
      return email;
    } catch (e) {
      print(e.toString());
      setState(() {
        _email = "None";
      });
      return "None";
    }
  }
  String? _email;

  @override
  void initState() {
    super.initState();
    emailFuture = getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: emailFuture,
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          // same as last scaffold except function *shown on waiting state*
          return Scaffold(
            appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(
                Icons.close_sharp,
                color: Colors.black,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "" ,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0), // Set border radius to 20.0
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2.5 // Set border thickness to 2.0
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2
                        ), // Set the border color to blue when focused
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width:  double.infinity,
                  height: 44,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      primary: Theme.of(context).primaryColor,
                    ),
                    child: const Text('Update email'),
                    onPressed: () async {

                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        }
        else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        else {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(
                  Icons.close_sharp,
                  color: Colors.black,),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: TextField(
                    controller: tC,
                    decoration: InputDecoration(
                      hintText: snapshot.data ,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0), // Set border radius to 20.0
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2.5 // Set border thickness to 2.0
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2
                        ), // Set the border color to blue when focused
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Container(
                  width:  double.infinity,
                  height: 44,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      primary: Theme.of(context).primaryColor,
                    ),
                    child: const Text('Update email'),
                    onPressed: () async {
                      await _db.collection("Users").doc(FirebaseAuth.instance.currentUser?.uid).update(
                          {'email': tC.text}
                      );
                      HelperFunctions.saveUserEmailSF(tC.text);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  EditProfileScreen()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        }
      },

    );
  }
}