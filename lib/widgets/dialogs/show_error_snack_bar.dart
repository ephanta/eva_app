import 'package:flutter/material.dart';

import '../../data/constants.dart';

/// {@category Widgets}
/// Zeigt eine Snackbar mit einer Fehlermeldung an
void showErrorSnackBar(context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Constants.warningColor),
  );
}
