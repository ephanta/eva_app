import 'package:auto_route/auto_route.dart';
import 'package:eva_app/provider/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// {@category Widgets}
/// Dialog zum Hinzufügen eines neuen Eintrags zur Einkaufsliste
Future<Future<Object?>> showAddItemDialog(
    BuildContext context, int householdId) async {
  final TextEditingController controllerItemName = TextEditingController();
  final TextEditingController controllerAmount = TextEditingController();
  String itemName = '';
  String amount = '';

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Neuen Eintrag erstellen'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: controllerItemName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Was brauchst du?',
                ),
                onChanged: (value) {
                  itemName = value;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controllerAmount,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Menge',
                ),
                onChanged: (value) {
                  amount = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final itemName = controllerItemName.text;
                  final amount = controllerAmount.text;
                  if (itemName.isNotEmpty) {
                    try {
                      final dataProvider =
                          Provider.of<DataProvider>(context, listen: false);
                      await dataProvider.addItemToShoppingList(
                        householdId.toString(),
                        itemName,
                        amount,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Eintrag erfolgreich erstellt.')),
                      );
                      AutoRouter.of(context).maybePop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Fehler beim Erstellen des Eintrags: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Bitte geben Sie einen Namen ein')),
                    );
                  }
                },
                child: const Text('Erstellen'),
              ),
            ],
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}
