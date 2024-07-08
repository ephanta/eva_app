import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../provider/data_provider.dart';
import '../routes/app_router.gr.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

@RoutePage()
class HomeDetailScreen extends StatefulWidget {
  final int householdId;

  const HomeDetailScreen({Key? key, required this.householdId})
      : super(key: key);

  @override
  State<HomeDetailScreen> createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends State<HomeDetailScreen> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    try {
      final role = await dataProvider.getUserRoleInHousehold(
          widget.householdId.toString(), userId);
      setState(() {
        userRole = role;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Abrufen der Benutzerrolle: $e')),
      );
    }
  }

  void _showEditHouseholdDialog(
      BuildContext context, Map<String, dynamic> household) {
    final TextEditingController nameController =
        TextEditingController(text: household['name']);
    Color currentColor = Color(
        int.parse(household['color'].substring(1, 7), radix: 16) + 0xFF000000);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Haushalt bearbeiten'),
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
                                setState(() {
                                  currentColor = color;
                                });
                              },
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Fertig'),
                              onPressed: () {
                                AutoRouter.of(context).maybePop();
                                AutoRouter.of(context).replace(HomeDetailRoute(
                                    householdId: widget.householdId));
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
                              content:
                                  Text('Haushalt erfolgreich bearbeitet.')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        showArrow: true,
        showHome: true,
        showProfile: true,
      ),
      body: Consumer<DataProvider>(builder: (context, dataProvider, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future:
              dataProvider.getCurrentHousehold(widget.householdId.toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const Text('Keine Daten gefunden.');
            } else {
              final household = snapshot.data!;
              Color householdColor = Color(
                  int.parse(household['color'].substring(1, 7), radix: 16) +
                      0xFF000000);
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${household['name']}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: householdColor,
                      ),
                    ),
                    const Text(
                      'Mitglieder:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: dataProvider
                          .getHouseholdMembers(widget.householdId.toString()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Fehler: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('Keine Mitglieder gefunden.');
                        } else {
                          final List<Map<String, dynamic>> members =
                              snapshot.data!;
                          return Column(
                            children: members
                                .map((member) => Text(member['username']))
                                .toList(),
                          );
                        }
                      },
                    ),
                    const Spacer(),
                    if (userRole == 'admin') ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Haushalt bearbeiten'),
                        onPressed: () {
                          _showEditHouseholdDialog(context, household);
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Haushalt löschen'),
                        onPressed: () async {
                          final dataProvider =
                              Provider.of<DataProvider>(context, listen: false);
                          try {
                            await dataProvider
                                .deleteHousehold(widget.householdId.toString());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Haushalt erfolgreich gelöscht.')),
                            );
                            AutoRouter.of(context)
                                .popUntilRouteWithName('HomeRoute');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Fehler beim Löschen des Haushalts: $e')),
                            );
                          }
                        },
                      ),
                    ],
                    if (userRole == 'member') ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text('Einladungscode kopieren'),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: household['invite_code']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Einladungscode kopiert')),
                          );
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Haushalt verlassen'),
                        onPressed: () async {
                          final dataProvider =
                              Provider.of<DataProvider>(context, listen: false);
                          try {
                            // Fügen Sie hier den Code hinzu, um den Haushalt zu verlassen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Haushalt verlassen')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Fehler beim Verlassen des Haushalts: $e')),
                            );
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }
          },
        );
      }),
      bottomNavigationBar: const BottomNavBarCustom(
        pageType: PageType.homeDetail,
        showHome: false,
        showShoppingList: false,
        showPlanner: true,
      ),
    );
  }
}
