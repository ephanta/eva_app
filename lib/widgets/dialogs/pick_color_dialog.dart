import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../buttons/custom_text_button.dart';

/// {@category Widgets}
/// Dialog um eine Farbe auszuwählen
Future<void> pickColorDialog(BuildContext context, Color currentColor,
    ValueChanged<Color> onColorChanged) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Wähle eine Farbe'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          CustomTextButton(buttonType: ButtonType.done),
        ],
      );
    },
  );
}
