import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../helper/helper_function.dart';
import '../../widgets/widgets.dart';
import '../auth/login_page.dart';
import '../home_page.dart';
import './edit_account_screens/change_email.dart';
import './edit_account_screens/change_first_name.dart';
import './edit_account_screens/change_profile_picture.dart';
import 'package:group_code/service/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
   EditProfileScreen({Key? key,});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  AuthService authService = AuthService();

  String userName = "";
  String email = "";
  String imgUrl = "";

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    await HelperFunctions.getUserProfilePicFromSF().then((val) {
      setState(() {
        imgUrl = val!;
      });
    });

  }


  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final userCollection = FirebaseFirestore.instance.collection('users');

  void refresh() {
    setState(() {
      detailsFuture = getCurrentUserData();
    });
  }
  late Future<String> detailsFuture;

  Future<String> getCurrentUserData() async {
    try {
      DocumentSnapshot ds = await userCollection.doc(uid).get();
      String imageUr = ds.get('profilePic');

      setState(() {
        _imageUr = imageUr;
      });

      return _imageUr;
    } catch (e) {
      setState(() {
        _imageUr = "https://cdn-icons-png.flaticon.com/512/552/552721.png";
      });
      return "None";
    }
  }

  String _imageUr = "";

  @override
  void initState() {
    super.initState();
    detailsFuture = getCurrentUserData();
    gettingUserData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // execute your desired code here
        Navigator.pop(context, true);
        return true; // return true to allow the back navigation
      },
      child: FutureBuilder<String>(
        future: detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                title: const Text(
                  "Profile",
                  style: TextStyle(
                      color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
              body: const Center(
                  child: CircularProgressIndicator(color: Colors.black)),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                title: const Text(
                  "Profile",
                  style: TextStyle(
                      color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
                ),
              ),
              drawer: Drawer(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    children: <Widget>[
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(imgUrl),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        userName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Divider(
                        height: 2,
                      ),
                      ListTile(
                        onTap: () {
                          nextScreen(context, const HomePage());
                        },
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        leading: const Icon(Icons.group),
                        title: const Text(
                          "Groups",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        selected: true,
                        selectedColor: Theme.of(context).primaryColor,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        leading: const Icon(Icons.group),
                        title: const Text(
                          "Profile",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      ListTile(
                        onTap: () async {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Logout"),
                                  content: const Text("Are you sure you want to logout?"),
                                  actions: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await authService.signOut();
                                        Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                                builder: (context) => const LoginPage()),
                                                (route) => false);
                                      },
                                      icon: const Icon(
                                        Icons.done,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        leading: const Icon(Icons.exit_to_app),
                        title: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    ],
                  )),
              body: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                physics: const BouncingScrollPhysics(),
                children: [
                  //UI
                  Container(
                    alignment: Alignment.topCenter,
                    child: IconButton(
                      iconSize: 120.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChangeProfilePicture())
                        ).then((result) {
                          if (result != null && result) {
                            refresh(); // Call the function to refresh the state
                          }
                        });
                      },
                      icon: CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(_imageUr),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 56,
                        child: ListTile(
                          title: const Text('Name'),
                          subtitle: Text(userName),
                          trailing: const Icon(Icons.edit),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangeFirstName()),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 56,
                        child: ListTile(
                          title: const Text('Email'),
                          subtitle: Text(email),
                          trailing: const Icon(Icons.edit),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangeEmail()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 56,
                        child: ListTile(
                          title: Text('Skills'),
                          subtitle: Text('Flutter, Dart, Python, Java'),
                          trailing: Icon(Icons.edit),
                        ),
                      ),
                      const SizedBox(
                        height: 56,
                        child: ListTile(
                          title: Text('Community Stars'),
                          subtitle: Text('4.6/5'),
                        ),
                      ),
                      const SizedBox(
                        height: 56,
                        child: ListTile(
                          title: Text('Reward Points'),
                          subtitle: Text('165'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
