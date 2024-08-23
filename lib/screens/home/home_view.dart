// ignore_for_file: avoid_print
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  CollectionReference firestore =
      FirebaseFirestore.instance.collection('imageUrl');

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
      sendImageToFirebase(imageFile!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image is Selected'),
        ),
      );
    }
  }

  //Sending Images to Firebase
  sendImageToFirebase(File uploadFile) async {
    try {
      final String fileName =
          "abc_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final mountainImagesRef = storage.child(fileName);

      await mountainImagesRef.putFile(uploadFile);

      final imageUrl = await mountainImagesRef.getDownloadURL();

      await firestore.add({
        'imageUrl': imageUrl,
        'time': FieldValue.serverTimestamp(),
      });

      print('Image URL added to Firestore');
    } catch (e) {
      print('Error uploading image: $e');
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
      body: SingleChildScrollView(
        child: Container(
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
              StreamBuilder(
                stream: firestore.orderBy('time', descending: true).snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        Map data = snapshot.data.docs[0].data();
                        String imageUrl = data['imageUrl'];
                        return Container(
                          margin: const EdgeInsets.only(top: 40),
                          child: CircleAvatar(
                            radius: 100,
                            child: Image.network(imageUrl),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('${snapshot.error}'),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
