import 'dart:io';
import 'package:flutter/material.dart';

void showProfileImageDialog(
    BuildContext context, String imagePath, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Profile Image", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  imagePath.isNotEmpty ? FileImage(File(imagePath)) : null,
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text("Confirm",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}
