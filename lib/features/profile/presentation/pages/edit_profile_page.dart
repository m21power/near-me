import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfilePage({super.key, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController universityController;
  late TextEditingController majorController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user['name']);
    bioController = TextEditingController(text: widget.user['bio'] ?? "");
    universityController =
        TextEditingController(text: widget.user['University']);
    majorController = TextEditingController(text: widget.user['Major']);
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    universityController.dispose();
    majorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Bio
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // University
            TextField(
              controller: universityController,
              decoration: const InputDecoration(
                labelText: "University",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Major
            TextField(
              controller: majorController,
              decoration: const InputDecoration(
                labelText: "Major",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(
                        UpdateProfileEvent(
                          profileImage: widget.user["photoUrl"],
                          backgroundImage: widget.user["backgroundUrl"],
                          fullName: nameController.text == ""
                              ? widget.user["name"]
                              : nameController.text,
                          bio: bioController.text,
                          university: universityController.text,
                          major: majorController.text,
                        ),
                      );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child:
                    const Text("Save Changes", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
