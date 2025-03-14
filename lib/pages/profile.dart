// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic> userData;

  const Profile({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<Profile> {
  final supabase = Supabase.instance.client;
  String? selectedImage;

  @override
  void initState() {
    super.initState();
    fetchProfilePicture();
  }

  Future<void> fetchProfilePicture() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    final response = await supabase
        .from('user_profile_pictures')
        .select('profile_picture')
        .eq('user_id', user.id)
        .maybeSingle();

    if (response == null) {
      print("No profile picture found for this user.");
      return;
    }

    setState(() {
      selectedImage = response['profile_picture'];
    });
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final File imageFile = File(pickedFile.path);
    final user = supabase.auth.currentUser;
    if (user == null) {
      print("⚠️ No user found. Make sure the user is logged in.");
      return;
    }

    final filePath = 'profilepictures/${user.id}.jpg';

    try {
      await supabase.storage.from('profilepictures').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );
      final imageUrl =
          supabase.storage.from('profilepictures').getPublicUrl(filePath);

      await supabase.from('user_profile_pictures').upsert({
        'user_id': user.id,
        'profile_picture': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      setState(() {
        selectedImage = imageUrl;
      });

      print("🎉 Profile picture updated successfully!");
    } catch (e) {
      print("🔥 Error uploading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFD8A8A),
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Color(0xFFFD8A8A),
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: pickAndUploadImage,
              child: CircleAvatar(
                key: ValueKey(selectedImage),
                radius: 50,
                backgroundImage: selectedImage != null
                    ? NetworkImage(selectedImage!)
                    : AssetImage('assets/images/profile.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            Text("Email: ${widget.userData['email']}"),
          ],
        ),
      ),
    );
  }
}
