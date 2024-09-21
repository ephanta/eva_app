import 'package:auto_route/auto_route.dart';
import 'package:eva_app/provider/data_provider.dart';
import 'package:eva_app/widgets/dialogs/pick_color_dialog.dart';
import 'package:flutter/material.dart';

import '../../data/constants.dart';
import '../../routes/app_router.gr.dart';
import '../buttons/custom_text_button.dart';

/// {@category Widgets}
/// Dialog um einen Haushalt zu erstellen
Future<void> createHouseholdDialog(
    BuildContext context, DataProvider dataProvider) async {
  final TextEditingController controller = TextEditingController();
  Color currentColor = Constants.primaryColor;

  return showDialog(
    context: context,
    builder: (BuildContext buildContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Neuen Haushalt erstellen'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
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
                    pickColorDialog(context, currentColor, (color) {
                      setState(() {
                        currentColor =
                            color; // Farbe wird im Zustand aktualisiert
                      });
                    });
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(
                      child: Text(
                        'Farbe wählen',
                        style: TextStyle(
                          color: ThemeData.estimateBrightnessForColor(
                                      currentColor) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              CustomTextButton(buttonType: ButtonType.abort),
              ElevatedButton(
                style: Constants.elevatedButtonStyle(),
                onPressed: () async {
                  final householdName = controller.text;
                  final householdColor =
                      '#${currentColor.value.toRadixString(16).substring(2, 8)}';
                  if (householdName.isNotEmpty) {
                    try {
                      final newHousehold = await dataProvider.createHousehold(
                          householdName, householdColor);

                      if (newHousehold['data'][0]['id'] != null) {
                        const userRole = 'admin'; // Creator is admin
                        AutoRouter.of(context).maybePop();
                        AutoRouter.of(context).push(
                          HomeDetailRoute(
                            householdId: newHousehold['data'][0]['id'],
                            preloadedHouseholdData: newHousehold['data'][0],
                            // Use new household data
                            preloadedUserRole: userRole,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to create household: $e')),
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
          );
        },
      );
    },
  );
}
