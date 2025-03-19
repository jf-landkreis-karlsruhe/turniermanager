import 'package:flutter/material.dart';

void showError(context, String errorText) {
  if (!context.mounted) {
    return;
  }

  var scaffoldMessenger = ScaffoldMessenger.maybeOf(context);

  scaffoldMessenger?.showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          'Fehler: $errorText',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
