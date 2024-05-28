import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../components/app_bar_custom.dart';

/// {@category Screens}
/// Ansicht für die Einkaufsliste
@RoutePage()
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

/// Der Zustand für die Wochenplan-Seite
class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(showArrow: true, showProfile: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Wochenplaner',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

          ],
        ),
      ),
    );
  }
}
