import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../helper/helper_function.dart';
import '../edit_profile_screen.dart';

class ChangeFirstName extends StatefulWidget {
  @override
  State<ChangeFirstName> createState() => _ChangeFirstNameState();
}

class _ChangeFirstNameState extends State<ChangeFirstName> {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final userCollection = FirebaseFirestore.instance.collection('users');

  final _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController tC = TextEditingController();

  late Future<String> fNameFuture;
  Future<String> getCurrentUserData() async {
    try {
      DocumentSnapshot ds = await userCollection.doc(uid).get();
      String firstname = ds.get('fullName');
      setState(() {
        _fName = firstname;
      });
      return firstname;
    } catch (e) {
      setState(() {
        _fName = "None";
      });
      return "None";
    }
  }
  String? _fName;

  @override
  void initState() {
    super.initState();
    fNameFuture = getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fNameFuture,
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
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
                    child: const Text('Update Name'),
                    onPressed: () async {

                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
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
                    child: const Text('Update first name'),
                    onPressed: () async {
                      await _db.collection("Users").doc(FirebaseAuth.instance.currentUser?.uid).update(
                          {'firstname': tC.text}
                      );
                      HelperFunctions.saveUserNameSF(tC.text);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen()),
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