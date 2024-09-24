import 'package:flutter/material.dart';

/// {@category Widgets}
/// Bottom Navigation Bar Item
class BottomNavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const BottomNavBarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        color: selected ? Colors.deepOrange : Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          //children do link to Route

          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
