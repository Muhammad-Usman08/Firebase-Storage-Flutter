// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? imageFile;
  final storage = FirebaseStorage.instance.ref();

  //Selecting Image using Image Picker Package
  selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(
        () {
          imageFile = File(image.path);
          print("this is image path ${image.path}");
          print("this is image name ${image.name}");
        },
      );
      sendImageToFirebase(imageFile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image is Selected'),
        ),
      );
    }
  }

  //Sending Images to Firebase
  sendImageToFirebase(uploadFile) {
    try {
      final mountainImagesRef = storage.child("abc.jpg${DateTime.now()}");
      mountainImagesRef.putFile(uploadFile);
    } catch (e) {
      print(e);
    }
  }

  //Getting Images to Firebase
  getImageFromFirebase() async {
    try {
      final imageUrl =
          await storage.child('abc.jpg${DateTime.now()}').getDownloadURL();
      print(imageUrl);
      return imageUrl;
    } catch (e) {
      print('error is found to get image');
      return 'not found';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Firebase Storage',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[400],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 40, bottom: 40),
        child: Column(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  selectImage();
                },
                child: const Text('Select Image'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 40),
              child: const CircleAvatar(
                radius: 100,
              ),
            )
          ],
        ),
      ),
    );
  }
}
