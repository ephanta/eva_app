import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// {@category Widgets}
/// Button-Typen
/// - abort: Abbrechen-Button
/// - done: Fertig-Button
enum ButtonType { abort, done }

class CustomTextButton extends StatelessWidget {
  final ButtonType? buttonType;
  final String? buttonText;
  final VoidCallback? onPressed;

  CustomTextButton({
    Key? key,
    this.buttonType,
    this.buttonText,
    this.onPressed,
  }) : super(key: key) {
    /// Assertion: Wenn buttonType nicht definiert ist, müssen buttonText und onPressed angegeben werden
    assert(
      buttonType != null || (buttonText != null && onPressed != null),
      'Wenn kein ButtonType angegeben ist, müssen buttonText und onPressed definiert werden.',
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Standardwerte für Button-Text und -Funktion abhängig vom ButtonType
    String text = '';
    VoidCallback? callback = onPressed;

    /// Setze den Text und Callback je nach ButtonType
    if (buttonType == ButtonType.abort) {
      text = 'Abbrechen';
      callback = callback ?? () => AutoRouter.of(context).maybePop();
    } else if (buttonType == ButtonType.done) {
      text = 'Fertig';
      callback = callback ?? () => AutoRouter.of(context).maybePop();
    } else if (buttonText != null) {
      text = buttonText!;
    }

    /// Callback darf nicht null sein, falls buttonType nicht gesetzt wurde
    callback = callback ??
        () {
          if (kDebugMode) {
            print('Standardaktion ausgeführt!');
          }
        };

    return TextButton(
      onPressed: callback,
      child: Text(text),
    );
  }
}
