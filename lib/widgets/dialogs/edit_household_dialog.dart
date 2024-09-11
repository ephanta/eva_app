import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';

/// {@category Widgets}
/// Dialog zum Bearbeiten eines Haushalts
Future<Future<Object?>> showEditHouseholdDialog(
    BuildContext context, Map<String, dynamic> household) async {
  final TextEditingController nameController =
      TextEditingController(text: household['name']);
  Color currentColor = Color(
      int.parse(household['color'].substring(1, 7), radix: 16) + 0xFF000000);

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Haushalt verwalten'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name des Haushalts',
                ),
                maxLength: 25,
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
              TextField(
                controller:
                    TextEditingController(text: household['invite_code']),
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Einladungscode',
                  suffixIcon: Icon(Icons.copy),
                ),
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: household['invite_code']));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Einladungscode kopiert')),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final householdName = nameController.text;
                  final householdColor =
                      '#${currentColor.value.toRadixString(16).substring(2, 8)}';
                  if (householdName.isNotEmpty && householdColor.isNotEmpty) {
                    try {
                      final dataProvider =
                          Provider.of<DataProvider>(context, listen: false);
                      await dataProvider.updateHousehold(
                        household['id'].toString(),
                        name: householdName,
                        color: householdColor,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Haushalt erfolgreich bearbeitet.')),
                      );

                      AutoRouter.of(context).maybePop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Fehler beim Bearbeiten des Haushalts: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Bitte alle Felder ausfüllen')),
                    );
                  }
                },
                child: const Text('Speichern'),
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
