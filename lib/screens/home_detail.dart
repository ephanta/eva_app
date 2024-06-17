import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/data_provider.dart';
import '../routes/app_router.gr.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

/// {@category Screens}
/// Ansicht für die Detailseite eines Haushalts
@RoutePage()
class HomeDetailScreen extends StatelessWidget {
  final int householdId;

  const HomeDetailScreen({Key? key, required this.householdId})
      : super(key: key);

  void _showEditHouseholdDialog(
      BuildContext context, Map<String, dynamic> household) {
    final TextEditingController _nameController =
        TextEditingController(text: household['name']);
    final TextEditingController _colorController =
        TextEditingController(text: household['color']);

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
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name des Haushalts',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _colorController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Farbe des Haushalts',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final householdName = _nameController.text;
                    final householdColor = _colorController.text;
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
                        AutoRouter.of(context).push(
                          HomeDetailRoute(householdId: household['id']),
                        );
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
        showProfile: true,
      ),
      body: Consumer<DataProvider>(builder: (context, dataProvider, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future: dataProvider.getCurrentHousehold(householdId.toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const Text('Keine Daten gefunden.');
            } else {
              final household = snapshot.data!;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Haushalt Details',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text('Haushalt ID: $householdId'),
                    Text('Name: ${household['name']}'),
                    Text('Farbe: ${household['color']}'),
                    const Spacer(),
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
                              .deleteHousehold(householdId.toString());
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
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }
          },
        );
      }),
      bottomNavigationBar: BottomNavBarCustom(
        pageType: PageType.homeDetail,
        showHome: true,
        showShoppingList: true,
        showPlanner: true,
      ),
    );
  }
}
