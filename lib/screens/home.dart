import 'package:auto_route/auto_route.dart';
import 'package:eva_app/provider/data_provider.dart';
import 'package:eva_app/routes/app_router.gr.dart';
import 'package:eva_app/widgets/navigation/app_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/constants.dart';
import '../widgets/dialogs/create_household_dialog.dart';
import '../widgets/dialogs/join_household_dialog.dart';
import '../widgets/text/custom_text.dart';

/// {@category Screens}
/// Ansicht des Home Screen mit einer Übersicht aller Haushalte
@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Der State des Home Screens
class _HomeScreenState extends State<HomeScreen> {
  late DataProvider _dataProvider;
  Color currentColor = Constants.primaryColor;

  @override
  void initState() {
    super.initState();
    _dataProvider = Provider.of<DataProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        showArrow: false,
        showHome: false,
        showProfile: true,
      ),
      body: Consumer<DataProvider>(builder: (context, dataProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Constants.secondaryBackgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Center(
                  child: CustomText(
                    text: 'Haushalte',
                  ),
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: dataProvider.fetchUserHouseholds(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          'Fehler beim Laden der Haushalte: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: households.length,
                          itemBuilder: (context, index) {
                            final household = households[index];
                            String colorString =
                                household['color'] ?? '#ffffff';
                            Color householdColor = Color(
                              int.parse(colorString.substring(1, 7),
                                      radix: 16) +
                                  0xFF000000,
                            );
                            return InkWell(
                              onTap: () async {
                                try {
                                  final householdData = await dataProvider
                                      .getCurrentHousehold(household['id']);
                                  final userRole = await dataProvider
                                      .getUserRoleInHousehold(household['id']);
                                  AutoRouter.of(context).push(
                                    HomeDetailRoute(
                                      householdId: household['id'],
                                      preloadedHouseholdData: householdData,
                                      preloadedUserRole: userRole,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Fehler beim Laden der Haushaltsdaten: $e')),
                                  );
                                }
                              },
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                color: householdColor,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomText(
                                        text: household['name'] ??
                                            'Unbenannter Haushalt',
                                        textAlign: TextAlign.center,
                                        fontSize: 20.0,
                                        textColor: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
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
              joinHouseholdDialog(context, _dataProvider);
            },
            backgroundColor: Constants.primaryBackgroundColor,
            child:
                const Icon(Icons.group_add, color: Constants.primaryTextColor),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'createHousehold',
            onPressed: () => createHouseholdDialog(context, _dataProvider),
            backgroundColor: Constants.primaryBackgroundColor,
            // Use the same color as the background
            child: const Icon(Icons.add, color: Constants.primaryTextColor),
          ),
        ],
      ),
    );
  }
}
