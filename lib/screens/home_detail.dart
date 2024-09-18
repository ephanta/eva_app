import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../provider/data_provider.dart';
import '../routes/app_router.gr.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

@RoutePage()
class HomeDetailScreen extends StatefulWidget {
  final String householdId;

  const HomeDetailScreen({Key? key, required this.householdId}) : super(key: key);

  @override
  State<HomeDetailScreen> createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends State<HomeDetailScreen> {
  String? userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      final role = await dataProvider.getUserRoleInHousehold(widget.householdId);
      setState(() {
        userRole = role;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Fehler beim Abrufen der Benutzerrolle: $e');
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Haushalt löschen'),
          content: const Text('Sind Sie sicher, dass Sie diesen Haushalt löschen möchten?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Löschen'),
              onPressed: () async {
                final dataProvider = Provider.of<DataProvider>(context, listen: false);
                try {
                  await dataProvider.deleteHousehold(widget.householdId);
                  Navigator.of(context).pop();
                  AutoRouter.of(context).replace(const HomeRoute());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Haushalt erfolgreich gelöscht.')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  _showErrorSnackBar('Fehler beim Löschen des Haushalts: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLeaveConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Haushalt verlassen'),
          content: const Text('Sind Sie sicher, dass Sie diesen Haushalt verlassen möchten?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Verlassen'),
              onPressed: () async {
                final dataProvider = Provider.of<DataProvider>(context, listen: false);
                try {
                  await dataProvider.leaveHousehold(widget.householdId);
                  Navigator.of(context).pop();
                  AutoRouter.of(context).replace(const HomeRoute());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Haushalt erfolgreich verlassen.')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  _showErrorSnackBar('Fehler beim Verlassen des Haushalts: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showEditHouseholdDialog(BuildContext context, Map<String, dynamic> household) {
    final TextEditingController nameController = TextEditingController(text: household['name'] ?? '');
    final TextEditingController inviteCodeController = TextEditingController(text: household['invite_code'] ?? '');
    Color currentColor;
    try {
      currentColor = Color(int.parse(household['color']?.substring(1, 7) ?? 'FFFFFF', radix: 16) + 0xFF000000);
    } catch (e) {
      currentColor = Colors.grey;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
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
                        _pickColorDialog(context, currentColor, (color) {
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
                              color: ThemeData.estimateBrightnessForColor(currentColor) == Brightness.dark
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
                        Clipboard.setData(ClipboardData(text: inviteCodeController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Einladungscode kopiert')),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final householdName = nameController.text;
                        final householdColor = '#${currentColor.value.toRadixString(16).substring(2, 8)}';
                        if (householdName.isNotEmpty && householdColor.isNotEmpty) {
                          try {
                            final dataProvider = Provider.of<DataProvider>(context, listen: false);
                            await dataProvider.updateHousehold(
                              widget.householdId,
                              name: householdName,
                              color: householdColor,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Haushalt erfolgreich bearbeitet.')),
                            );
                          } catch (e) {
                            _showErrorSnackBar('Fehler beim Bearbeiten des Haushalts: $e');
                          }
                        } else {
                          _showErrorSnackBar('Bitte alle Felder ausfüllen');
                        }
                      },
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
      transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
          child: child,
        );
      },
    );
  }

  void _pickColorDialog(BuildContext context, Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wähle eine Farbe'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fertig'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        showArrow: true,
        showHome: true,
        showProfile: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return FutureBuilder<Map<String, dynamic>>(
            future: dataProvider.getCurrentHousehold(widget.householdId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('Keine Daten gefunden.'));
              } else {
                final household = snapshot.data!;
                Color householdColor;
                try {
                  householdColor = Color(int.parse(household['color'].substring(1, 7), radix: 16) + 0xFF000000);
                } catch (e) {
                  householdColor = Colors.grey;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${household['name'] ?? 'Unbenannter Haushalt'}',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: householdColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Mitglieder:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: dataProvider.getHouseholdMembers(widget.householdId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Fehler: ${snapshot.error}');
                          } else
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Keine Mitglieder gefunden.');
                          } else {
                            final List<Map<String, dynamic>> members = snapshot
                                .data!;
                            return Column(
                              children: members
                                  .map(
                                    (member) =>
                                    ListTile(
                                      title: Center(
                                        child: Text(
                                          member['username'] ??
                                              'Unbekanntes Mitglied',
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                      subtitle: Center(
                                        child: Text(
                                          member['role'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                              )
                                  .toList(),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text('Einladungscode kopieren'),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: household['invite_code'] ?? ''));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Einladungscode kopiert')),
                          );
                        },
                      ),
                      const Spacer(),
                      // This pushes everything above towards the top
                      if (userRole == 'admin') ...[
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Haushalt bearbeiten'),
                          onPressed: () {
                            _showEditHouseholdDialog(context, household);
                          },
                        ),
                        const SizedBox(height: 10),
                        // Add spacing between buttons
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete),
                          label: const Text('Haushalt löschen'),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context);
                          },
                        ),
                      ],
                      if (userRole == 'member') ...[
                        ElevatedButton.icon(
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text('Haushalt verlassen'),
                          onPressed: () {
                            _showLeaveConfirmationDialog(context);
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Add space between buttons and bottom of the screen
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBarCustom(
        pageType: PageType.homeDetail,
        showHome: false,
        showShoppingList: true,
        showShoppingHistory: false,
        showPlanner: true,
        householdId: widget.householdId,
      ),
    );
  }
}

