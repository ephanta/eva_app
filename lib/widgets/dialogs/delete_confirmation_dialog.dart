import 'package:auto_route/auto_route.dart';
import 'package:eva_app/widgets/buttons/custom_text_button.dart';
import 'package:flutter/material.dart';

/// {@category Widgets}
/// Dialog zur Bestätigung einer Löschaktion
Future<bool> deleteConfirmationDialog(
    BuildContext context, String title, String content) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CustomTextButton(
                buttonType: ButtonType.abort,
                onPressed: () {
                  AutoRouter.of(context).maybePop(false);
                },
              ),
              CustomTextButton(
                buttonText: 'Löschen',
                onPressed: () {
                  AutoRouter.of(context).maybePop(true);
                },
              ),
            ],
          );
        },
      ) ??
      false; // Return false if dialog is dismissed
}
