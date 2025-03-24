import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false, // Prevents closing the dialog by tapping outside
    context: context,
    builder: (BuildContext context) {
      return const Dialog(
        backgroundColor: Colors.transparent, // Transparent background
        child: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Colors.blue), // Customize color
          ),
        ),
      );
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context).pop(); // Closes the dialog
}
