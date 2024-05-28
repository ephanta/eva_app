import 'package:flutter/material.dart';
import '../../data/constants.dart';

/// {@category Components}
/// Komponente für die App-Bar
class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustom({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true, // Deaktiviere den Pfeil zurück
      title: const Text(Constants.appName),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }
}