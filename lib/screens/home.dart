import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:eva_app/widgets/navigation/app_bar_custom.dart';
import 'package:flutter/material.dart';
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
  /// Methode zum Anzeigen eines Fullscreen-Dialogs, zum Erstellen eines neuen Haushalts
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
                        final response = await Supabase.instance.client
                            .from('households')
                            .insert({
                          'name': householdName,
                          'color': '#FF0000'
                        }).select();

                        final data = response as List<dynamic>;
                        try {
                          final householdId = data[0]['id'];
                          print(householdId);
                          await Supabase.instance.client
                              .from('household_member')
                              .insert({
                            'household_id': householdId,
                            'member_uid':
                                Supabase.instance.client.auth.currentUser!.id,
                          }).select();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Haushalt erfolgreich erstellt.')),
                          );
                          Navigator.of(context).pop();
                        } catch (e) {
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Fehler beim Erstellen des Haushalts. Sie konnten Ihrem Haushalt nicht zugewiesen werden.')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Fehler beim Erstellen des Haushalts.')),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Haushalte',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            // TODO: Cards pro Haushalt der von dem aktuellen User erstellt wurde
          ],
        ),
      ),

      /// Button zum Erstellen eines neuen Haushalts
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /// Fullscreen Dialog zum Erstellen eines neuen Haushalts
          _showFullScreenDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
