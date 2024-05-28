import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../data/constants.dart';
import '../routes/app_router.gr.dart';

/// {@category Components}
/// Komponente für die App-Bar
class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustom({
    super.key, required this.showArrow, required this.showProfile,
  });

final bool showArrow;
final bool showProfile;

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showArrow,
      title: const Text(Constants.appName),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        if (showProfile)
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              AutoRouter.of(context).push(const ProfileRoute());
            },
          ),
      ],
    );
  }
}