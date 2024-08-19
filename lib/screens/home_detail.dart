import 'package:auto_route/auto_route.dart';
import 'package:eva_app/widgets/dialogs/leave_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../provider/data_provider.dart';
import '../routes/app_router.gr.dart';
import '../widgets/dialogs/edit_household_dialog.dart';
import '../widgets/dialogs/show_delete_confirmation_dialog.dart';
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
                          showEditHouseholdDialog(context, household);
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Haushalt löschen'),
                        onPressed: () {
                          showDeleteConfirmationDialog(
                            context,
                            widget.householdId,
                            null,
                            'Haushalt',
                            'Sind Sie sicher, dass Sie diesen Haushalt löschen möchten?',
                            'household',
                            onDeleted: () {
                              AutoRouter.of(context).replace(const HomeRoute());
                            },
                          );
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
                        onPressed: () {
                          showLeaveConfirmationDialog(
                              context, widget.householdId);
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
      bottomNavigationBar: BottomNavBarCustom(
        pageType: PageType.homeDetail,
        showHome: false,
        showShoppingList: true,
        showPlanner: true,
        householdId: widget.householdId,
      ),
    );
  }
}
