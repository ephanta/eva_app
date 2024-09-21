import 'package:auto_route/auto_route.dart';
import 'package:eva_app/widgets/dialogs/pick_color_dialog.dart';
import 'package:eva_app/widgets/dialogs/showErrorSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/constants.dart';
import '../../provider/data_provider.dart';

/// {@category Widgets}
/// Dialog zum Bearbeiten eines Haushalts
Future<Future<Object?>> editHouseholdDialog(
    BuildContext context, Map<String, dynamic> household) async {
  final TextEditingController nameController =
      TextEditingController(text: household['name'] ?? '');
  final TextEditingController inviteCodeController =
      TextEditingController(text: household['invite_code'] ?? '');
  Color currentColor;
  try {
    currentColor = Color(
        int.parse(household['color']?.substring(1, 7) ?? 'FFFFFF', radix: 16) +
            0xFF000000);
  } catch (e) {
    currentColor = Colors.grey;
  }

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Scaffold(
            appBar: AppBar(title: const Text('Haushalt bearbeiten')),
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
                      pickColorDialog(context, currentColor, (color) {
                        setState(() {
                          currentColor = color;
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
                  const SizedBox(height: 20),
                  TextField(
                    controller: inviteCodeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Einladungscode',
                      suffixIcon: Icon(Icons.copy),
                    ),
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: inviteCodeController.text));
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
                      if (householdName.isNotEmpty &&
                          householdColor.isNotEmpty) {
                        try {
                          final dataProvider =
                              Provider.of<DataProvider>(context, listen: false);
                          await dataProvider.updateHousehold(
                            household['id'],
                            name: householdName,
                            color: householdColor,
                          );
                          AutoRouter.of(context).maybePop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Haushalt erfolgreich bearbeitet.')),
                          );
                        } catch (e) {
                          showErrorSnackBar(context,
                              'Fehler beim Bearbeiten des Haushalts: $e');
                        }
                      } else {
                        showErrorSnackBar(
                            context, 'Bitte alle Felder ausfüllen');
                      }
                    },
                    style: Constants.elevatedButtonStyle(),
                    child: const Text('Speichern'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(animation),
        child: child,
      );
    },
  );
}
