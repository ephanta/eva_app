import 'package:auto_route/auto_route.dart';
import 'package:eva_app/provider/data_provider.dart';
import 'package:eva_app/routes/app_router.gr.dart';
import 'package:eva_app/widgets/navigation/app_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// {@category Screens}
/// Ansicht für die Home-Seite
@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Der Zustand für die Home-Seite
class _HomeScreenState extends State<HomeScreen> {
  late DataProvider _dataProvider;

  @override
  void initState() {
    super.initState();
    _dataProvider = DataProvider(Supabase.instance.client);
  }

  void _showFullScreenDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

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
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name des Haushalts',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final householdName = _controller.text;
                    if (householdName.isNotEmpty) {
                      try {
                        final householdId = await _dataProvider.createHousehold(
                          householdName,
                          Supabase.instance.client.auth.currentUser!.id,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Haushalt erfolgreich erstellt.')),
                        );
                        AutoRouter.of(context).maybePop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(showArrow: false, showProfile: true),
      body: Consumer<DataProvider>(builder: (context, dataProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Haushalte',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              FutureBuilder<List<dynamic>>(
                future: dataProvider.fetchUserHouseholds(
                    Supabase.instance.client.auth.currentUser!.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final households = snapshot.data ?? [];
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
                            return InkWell(
                              onTap: () {
                                AutoRouter.of(context).push(
                                  HomeDetailRoute(householdId: household['id']),
                                );
                              },
                              child: Card(
                                child: Center(
                                  child: Text(
                                    household['name'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFullScreenDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
