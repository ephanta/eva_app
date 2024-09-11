import 'package:auto_route/auto_route.dart';
import 'package:eva_app/provider/data_provider.dart';
import 'package:eva_app/routes/app_router.gr.dart';
import 'package:eva_app/widgets/navigation/app_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DataProvider _dataProvider;

  @override
  void initState() {
    super.initState();
    _dataProvider = Provider.of<DataProvider>(context, listen: false);
  }

  void _createHouseholdDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    Color currentColor = Colors.blue; // Default color

    showGeneralDialog(
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
                    _pickColorDialog(context, currentColor, (color) {
                      setState(() {
                        currentColor = color;
                      });
                    });
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
                        final householdId = await _dataProvider.createHousehold(
                          householdName,
                          householdColor,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Haushalt erfolgreich erstellt.')),
                        );
                        Navigator.pop(context);
                        AutoRouter.of(context).push(
                          HomeDetailRoute(householdId: householdId),
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

  // Helper function to open the color picker dialog
  void _pickColorDialog(BuildContext context, Color initialColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wähle eine Farbe'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: initialColor,
              onColorChanged: onColorChanged,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fertig'),
              onPressed: () {
                Navigator.pop(context);
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
          showArrow: false, showHome: false, showProfile: true),
      body: Consumer<DataProvider>(builder: (context, dataProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Haushalte',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: dataProvider.fetchUserHouseholds(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Fehler beim Laden der Haushalte: ${snapshot.error}'),
                    );
                  } else {
                    final households = snapshot.data ?? [];
                    if (households.isEmpty) {
                      return const Center(
                        child: Text('Keine Haushalte gefunden'),
                      );
                    }
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: households.length,
                          itemBuilder: (context, index) {
                            final household = households[index];

                            if (household['id'] != null && household['id'] is String) {
                              String colorString = household['color'] ?? '#ffffff';
                              Color householdColor;

                              try {
                                householdColor = Color(
                                    int.parse(colorString.substring(1, 7), radix: 16) + 0xFF000000
                                );
                              } catch (e) {
                                householdColor = Colors.grey; // Fallback color
                              }

                              return InkWell(
                                onTap: () {
                                  AutoRouter.of(context).push(
                                    HomeDetailRoute(householdId: household['id']),
                                  );
                                },
                                child: Card(
                                  color: householdColor,
                                  child: Center(
                                    child: Text(
                                      household['name'] ?? 'Unbenannter Haushalt',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        );
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'joinHousehold',
            onPressed: () {
              _joinHouseholdDialog(context);
            },
            child: const Icon(Icons.group_add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'createHousehold',
            onPressed: () => _createHouseholdDialog(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _joinHouseholdDialog(BuildContext context) {
    final TextEditingController inviteCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Haushalt beitreten'),
          content: TextField(
            controller: inviteCodeController,
            decoration: const InputDecoration(
              labelText: 'Einladungscode',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Beitreten'),
              onPressed: () async {
                final inviteCode = inviteCodeController.text;

                if (inviteCode.isNotEmpty) {
                  try {
                    final householdId = await _dataProvider.joinHousehold(inviteCode);
                    Navigator.pop(context);
                    AutoRouter.of(context).push(
                      HomeDetailRoute(householdId: householdId),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erfolgreich dem Haushalt beigetreten.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fehler beim Beitreten des Haushalts: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bitte geben Sie einen Einladungscode ein')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
