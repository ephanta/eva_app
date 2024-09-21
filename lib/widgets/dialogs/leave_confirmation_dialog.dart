import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';
import '../../routes/app_router.gr.dart';

/// {@category Widgets}
/// Dialog zum Bestätigen des Verlassens eines Haushalts
Future<void> showLeaveConfirmationDialog(
    BuildContext context, int householdId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Haushalt verlassen'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'Sind Sie sicher, dass Sie diesen Haushalt verlassen möchten?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () {
              AutoRouter.of(context).maybePop();
            },
          ),
          TextButton(
            child: const Text('Verlassen'),
            onPressed: () async {
              final dataProvider =
                  Provider.of<DataProvider>(context, listen: false);
              try {
                await dataProvider.leaveHousehold(householdId.toString());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Haushalt verlassen')),
                );
                AutoRouter.of(context).maybePop();
                AutoRouter.of(context).push(const HomeRoute());
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Fehler beim Verlassen des Haushalts: $e')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
