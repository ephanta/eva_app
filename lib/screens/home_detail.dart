import 'package:auto_route/auto_route.dart';
import 'package:eva_app/widgets/dialogs/delete_household_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/constants.dart';
import '../provider/data_provider.dart';
import '../widgets/dialogs/edit_household_dialog.dart';
import '../widgets/dialogs/leave_confirmation_dialog.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';
import '../widgets/text/custom_text.dart';

/// {@category Screens}
/// Ansicht für die Detailansicht eines Haushalts
@RoutePage()
class HomeDetailScreen extends StatefulWidget {
  final String householdId;
  final Map<String, dynamic> preloadedHouseholdData;
  final String preloadedUserRole;

  const HomeDetailScreen({
    Key? key,
    required this.householdId,
    required this.preloadedHouseholdData,
    required this.preloadedUserRole,
  }) : super(key: key);

  @override
  State<HomeDetailScreen> createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends State<HomeDetailScreen> {
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        showArrow: true,
        showHome: true,
        showProfile: true,
      ),
      body: _isLoading
          ? _buildSkeletonLoader()
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContent(context),
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

  Widget _buildContent(BuildContext context) {
    final household = widget.preloadedHouseholdData;
    final userRole = widget.preloadedUserRole;
    Color householdColor;
    try {
      householdColor = Color(
          int.parse(household['color'].substring(1, 7), radix: 16) +
              0xFF000000);
    } catch (e) {
      householdColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            color: Constants.secondaryBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child:
                  CustomText(text: household['name'] ?? 'Unbenannter Haushalt'),
            ),
          ),
          const SizedBox(height: 20),
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
            future: Provider.of<DataProvider>(context, listen: false)
                .getHouseholdMembers(widget.householdId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Fehler: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Keine Mitglieder gefunden.');
              } else {
                final members = snapshot.data!;
                return Column(
                  children: members
                      .map(
                        (member) => ListTile(
                          title: Center(
                            child: Text(
                              member['username'] ?? 'Unbekanntes Mitglied',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          subtitle: Center(
                            child: Text(
                              member['role'] ?? '',
                              style: const TextStyle(color: Colors.black),
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
              Clipboard.setData(
                  ClipboardData(text: household['invite_code'] ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Einladungscode kopiert')),
              );
            },
            style: Constants.elevatedButtonStyle(),
          ),
          const Spacer(),
          if (userRole == 'admin') ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Haushalt bearbeiten'),
              onPressed: () {
                editHouseholdDialog(context, household);
              },
              style: Constants.elevatedButtonStyle(),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Haushalt löschen'),
              onPressed: () {
                deleteHouseholdConfirmationDialog(context, household);
              },
              style: Constants.elevatedButtonStyle(),
            ),
          ],
          if (userRole == 'member') ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Haushalt verlassen'),
              onPressed: () {
                leaveConfirmationDialog(context, household['id']);
              },
              style: Constants.elevatedButtonStyle(),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(height: 30, width: 200, color: Colors.grey[300]),
        const SizedBox(height: 20),
        CircleAvatar(radius: 30, backgroundColor: Colors.grey[300]),
        const SizedBox(height: 20),
        Container(height: 20, width: 100, color: Colors.grey[300]),
        const SizedBox(height: 20),
        const CircularProgressIndicator(),
        const Spacer(),
      ],
    );
  }
}
