import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../widgets/navigation/app_bar_custom.dart';

/// {@category Screens}
/// Ansicht für den Wochenplaner
@RoutePage()
class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

/// Der Zustand für die Wochenplan-Seite
class _PlannerScreenState extends State<PlannerScreen> {
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
