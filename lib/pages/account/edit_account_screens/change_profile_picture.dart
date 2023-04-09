import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';


class ChangeProfilePicture extends StatefulWidget {
  const ChangeProfilePicture({Key? key}) : super(key: key);

  @override
  State<ChangeProfilePicture> createState() => _ChangeProfilePictureState();
}

class _ChangeProfilePictureState extends State<ChangeProfilePicture> {
  @override
  void initState() {
    super.initState();
    profilePicFuture = getProfilePic();
  }

  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final userCollection = FirebaseFirestore.instance.collection('Users');
  final _db = FirebaseFirestore.instance;


  late Future<String> profilePicFuture;

  Future<String> getProfilePic() async {
    try {
      DocumentSnapshot ds = await userCollection.doc(uid).get();
      String imageUr = ds.get('imagePath');

      var rng = Random();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File file = File('$tempPath${rng.nextInt(100)}.png');
      http.Response response = await http.get(Uri.parse(imageUr));
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _tempFirebaseImage = file;
      });

      return imageUr;

    } catch (e) {

      return "None";
    }
  }

  File? _rcFrontImage;
  File? _tempFirebaseImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, String imageType) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;

      // Compress the image
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        '$path/img_$imageType.jpg',
        quality: 70,
      );

      setState(() {
        if (imageType == 'profile') {
          _rcFrontImage = compressedImage;
        }
      });
    }
  }

  Future<void> captureImage(String imageName) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;

      // Compress the image
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        '$path/img_$imageName.jpg',
        quality: 70,
      );

      setState(() {
        if (imageName == 'profile') {
          _rcFrontImage = compressedImage;
        }
      });
    }
  }

  Future<void> _uploadImages() async {
    setState(() {
      _isUploading = true;
    });

    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child(FirebaseAuth.instance.currentUser?.uid ?? "NoId")
        .child('profile_images');

    const String rcFrontFileName = 'profile.jpg';

    final UploadTask rcFrontUploadTask =
        storageReference.child(rcFrontFileName).putFile(_rcFrontImage!);

    final TaskSnapshot rcFrontSnapshot = await rcFrontUploadTask;

    final rcFrontDownloadUrl = await rcFrontSnapshot.ref.getDownloadURL();

    await _db
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({'imagePath': rcFrontDownloadUrl});

    setState(() {
      _isUploading = false;
    });

    _showSuccessDialog(context);
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
                captureImage('profile');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery, 'profile');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Method to show success dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Image uploaded successfully.'),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // execute your desired code here
        Navigator.pop(context, true);
        return true; // return true to allow the back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: const Text(
            "Change Profile Photo",
            style: TextStyle(
                color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Profile Photo',
                          style: TextStyle(
                            fontSize: 20.0, // set the font size to 20
                            fontWeight: FontWeight.bold, // make the text bold
                          ),
                        ),
                      ),
                    ),

                    IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          //captureImage('profile');
                          _showOptions(context);
                        }),
                  ],
                ),
                Row(
                  children: [
                    if (_rcFrontImage != null && _tempFirebaseImage != null) ...[
                      Expanded(
                        child: SizedBox(
                            height: 300,
                            width: 300,
                            child: Image.file(_rcFrontImage!)),
                      ),
                    ]
                    else if (_rcFrontImage != null) ...[
                      Expanded(
                        child: SizedBox(
                            height: 300,
                            width: 300,
                            child: Image.file(_rcFrontImage!)),
                      ),
                    ]
                    else if (_tempFirebaseImage != null) ...[
                      Expanded(
                        child: SizedBox(
                            height: 300,
                            width: 300,
                            child: Image.file(_tempFirebaseImage!)),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    if (_rcFrontImage != null) ...[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: _isUploading ? null : _uploadImages,
                          child: _isUploading
                              ? const CircularProgressIndicator()
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
