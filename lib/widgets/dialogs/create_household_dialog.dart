import 'package:auto_route/auto_route.dart';
import 'package:eva_app/provider/data_provider.dart'; // Passe diesen Import an dein Projekt an.
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../../routes/app_router.gr.dart';

/// {@category Widgets}
/// Dialog zum Erstellen eines neuen Haushalts
Future<Future<Object?>> showCreateHouseholdDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();
  Color currentColor = Colors.orange; // Default color

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Neuen Haushalt erstellen'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name des Haushalts',
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Wähle eine Farbe'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: currentColor,
                            onColorChanged: (color) {
                              currentColor = color;
                            },
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Fertig'),
                            onPressed: () {
                              AutoRouter.of(context).maybePop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Farbe wählen',
                  ),
                  child: Container(
                    height: 50,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final householdName = controller.text;
                  final householdColor =
                      '#${currentColor.value.toRadixString(16).substring(2, 8)}';
                  if (householdName.isNotEmpty) {
                    try {
                      final dataProvider =
                          Provider.of<DataProvider>(context, listen: false);
                      final household = await dataProvider.createHousehold(
                        householdName,
                        householdColor,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Haushalt erfolgreich erstellt.')),
                      );
                      AutoRouter.of(context).maybePop();
                      AutoRouter.of(context).push(
                        HomeDetailRoute(
                            householdId: household['id'],
                            preloadedHouseholdData: household,
                            preloadedUserRole: household['role']),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Fehler beim Erstellen des Haushalts: $e')),
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
