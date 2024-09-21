import 'package:flutter/material.dart';

import '../../data/constants.dart';

void showErrorSnackBar(context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Constants.warningColor),
  );
}
