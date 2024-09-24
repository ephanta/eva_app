import 'package:flutter/material.dart';

/// {@category Constants}
/// In Constants werden Konstanten gespeichert, die im Projekt verwendet werden.
class Constants {
  static const String appName = 'FamilyFeast';

  /// Farben
  static const Color primaryTextColor = Color(0xFF3A0B01);
  static const Color primaryBackgroundColor = Color(0xFFFDD9CF);
  static const Color secondaryBackgroundColor = Color(0xFFFFECE7);
  static const Color warningBackgroundColor = Colors.redAccent;
  static const Color warningColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color primaryColor = Colors.orange;

  /// Styles
  static ButtonStyle elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Constants.primaryBackgroundColor,
      foregroundColor: Constants.primaryTextColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static ButtonStyle elevatedButtonStyleAbort() {
    return ElevatedButton.styleFrom(
      backgroundColor: Constants.warningBackgroundColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
