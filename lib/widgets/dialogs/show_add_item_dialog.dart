import 'package:auto_route/auto_route.dart';
import 'package:eva_app/provider/data_provider.dart';
import 'package:flutter/material.dart';

import '../../data/constants.dart';

/// {@category Widgets}
/// Dialog zum Hinzufügen eines neuen Eintrags zur Einkaufsliste
Future<void> showAddItemDialog(BuildContext context,
    {required DataProvider dataProvider,
    required String householdId,
    required ValueNotifier<bool> isLoading}) async {
  final TextEditingController controllerItemName = TextEditingController();
  final TextEditingController controllerAmount = TextEditingController();
  String itemName = '';
  String amount = '';

  final result = await showGeneralDialog<Map<String, String>>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Artikel hinzufügen'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
              TextField(
                controller: controllerItemName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Artikelname',
                ),
                onChanged: (value) {
                  itemName = value;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      AutoRouter.of(context).maybePop(); // Abbrechen
                    },
                    child: const Text('Abbrechen'),
                    style: Constants.elevatedButtonStyleAbort(),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      AutoRouter.of(context).maybePop({
                        'name': itemName,
                        'amount': amount,
                      }); // Artikel hinzufügen
                    },
                    child: const Text('Hinzufügen'),
                    style: Constants.elevatedButtonStyle(),
                  ),
                ],
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

  if (result != null) {
    isLoading.value = true; // Ladezustand aktivieren
    try {
      await dataProvider.addItemToShoppingList(
          householdId, result['name']!, result['amount']!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikel erfolgreich hinzugefügt')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Hinzufügen des Artikels: $e')),
      );
    } finally {
      isLoading.value = false; // Ladezustand deaktivieren
    }
  }
}
