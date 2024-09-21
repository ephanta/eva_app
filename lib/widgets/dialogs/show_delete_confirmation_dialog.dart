import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';

/// {@category Widgets}
/// Dialog zum Bestätigen des Löschens eines Haushalts oder eines Eintrags aus der Einkaufsliste
Future<void> showDeleteConfirmationDialog(
  BuildContext context,
  int householdId,
  int? id,
  String subject,
  String question,
  String delete, {
  required VoidCallback onDeleted, // Callback hinzufügen
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('$subject löschen'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(question),
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
            child: const Text('Löschen'),
            onPressed: () async {
              final dataProvider =
                  Provider.of<DataProvider>(context, listen: false);
              try {
                if (delete == 'household') {
                  await dataProvider.deleteHousehold(householdId.toString());
                } else if (delete == 'shoppinglist') {
                  await dataProvider.removeItemFromShoppingList(id.toString());
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$subject erfolgreich gelöscht.')),
                );
                AutoRouter.of(context).maybePop();
                onDeleted();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Fehler beim Löschen des $subject : $e')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
