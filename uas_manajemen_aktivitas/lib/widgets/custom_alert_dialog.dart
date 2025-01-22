import 'package:flutter/material.dart';

class CustomAlertDialog {
  static void show(
      BuildContext context, {
        required String title,
        required String message,
        String? positiveButtonText,
        VoidCallback? onPositiveButtonPressed,
        String? negativeButtonText,
        VoidCallback? onNegativeButtonPressed,
      }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (negativeButtonText != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onNegativeButtonPressed != null) {
                    onNegativeButtonPressed();
                  }
                },
                child: Text(negativeButtonText),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onPositiveButtonPressed != null) {
                  onPositiveButtonPressed();
                }
              },
              child: Text(positiveButtonText ?? 'OK'),
            ),
          ],
        );
      },
    );
  }
}
