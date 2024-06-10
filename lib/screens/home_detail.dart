import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/data_provider.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

/// {@category Screens}
/// Ansicht für die Detailseite eines Haushalts
@RoutePage()
class HomeDetailScreen extends StatelessWidget {
  final int householdId;

  const HomeDetailScreen({Key? key, required this.householdId})
      : super(key: key);

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
                      icon: Icon(Icons.delete),
                      label: Text('Haushalt löschen'),
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
                    // TODO: Add edit household button
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
