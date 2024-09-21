import 'package:flutter/material.dart';

import '../../data/constants.dart';

/// {@category Widgets}
/// CustomText wird verwendet um das Layout von Text-Widgets zu vereinheitlichen.
class CustomText extends StatefulWidget {
  const CustomText({
    super.key,
    required this.text,
    this.fontSize,
    this.textColor,
    this.fontWeight,
    this.textAlign,
  });

  final String text;
  final double? fontSize;
  final Color? textColor;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;

  @override
  State<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      textAlign: widget.textAlign,
      style: TextStyle(
        fontSize: widget.fontSize ?? 22,
        fontWeight: widget.fontWeight ?? FontWeight.bold,
        color: widget.textColor ?? Constants.primaryTextColor,
      ),
    );
  }
}
