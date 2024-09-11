import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/data_provider.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

/// {@category Screens}
/// Ansicht für die Einkaufshistorie-Seite
@RoutePage()
class ShoppingHistoryScreen extends StatefulWidget {
  final int householdId;

  const ShoppingHistoryScreen({Key? key, required this.householdId})
      : super(key: key);

  @override
  State<ShoppingHistoryScreen> createState() => _ShoppingHistoryScreenState();
}

/// Der Zustand für die EinkaufsHistorien-Seite
class _ShoppingHistoryScreenState extends State<ShoppingHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        showArrow: true,
        showHome: true,
        showProfile: true,
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: dataProvider.getShoppingList(widget.householdId.toString()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Fehler: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Keine gekauften Artikel.'));
              } else {
                final purchasedList = snapshot.data!
                    .where((item) => item['status'] == 'purchased')
                    .toList();

                if (purchasedList.isEmpty) {
                  return const Center(
                      child: Text('Die Einkaufshistorie ist leer.'));
                }

                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Einkaufshistorie',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.orange[50],
                        child: ListView.builder(
                          itemCount: purchasedList.length,
                          itemBuilder: (context, index) {
                            final item = purchasedList[index];
                            final DateTime checkedAt =
                                DateTime.parse(item['checked_at']);
                            final String formattedDate =
                                DateFormat('dd.MM.yyyy HH:mm')
                                    .format(checkedAt);

                            return ListTile(
                              title: Text(item['item_name']),
                              subtitle: Text(
                                  'Menge: ${item['amount']} - Gekauft am $formattedDate'),
                              leading: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteItem(item['id']);
                                },
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_upward),
                                onPressed: () {
                                  _addItemAgain(item['id']);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete_sweep),
                        label: const Text('Einkaufshistorie leeren'),
                        onPressed: () async {
                          await _clearPurchasedList(
                              dataProvider, purchasedList);
                          setState(() {}); // UI-Update nach dem Löschen
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBarCustom(
        pageType: PageType.shoppingHistory,
        showHome: true,
        showShoppingList: true,
        showPlanner: false,
        showShoppingHistory: false,
        householdId: widget.householdId,
      ),
    );
  }

  /// Löscht einen Artikel aus der Einkaufshistorie
  Future<void> _deleteItem(int itemId) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      /// Löschen des Artikels aus der Historie
      await dataProvider.removeItemFromShoppingList(
          widget.householdId.toString(), itemId.toString());
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Löschen des Eintrags: $e'),
        ),
      );
    }
  }

  /// Fügt einen Artikel erneut zur Einkaufsliste hinzu
  Future<void> _addItemAgain(int itemId) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    try {
      /// Artikel aus der Historie finden
      final item = await dataProvider.getShoppingItemById(itemId);

      /// Artikel zur Einkaufsliste hinzufügen
      await dataProvider.addItemToShoppingList(
        widget.householdId.toString(),
        item?['item_name'],
        item?['amount'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${item?['item_name']} wurde der Einkaufsliste hinzugefügt.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Zurücksetzen des Eintrags: $e'),
        ),
      );
    }
  }

  /// Löscht die gesamte Einkaufshistorie
  Future<void> _clearPurchasedList(DataProvider dataProvider,
      List<Map<String, dynamic>> purchasedList) async {
    try {
      for (var item in purchasedList) {
        /// Löschen der Artikel aus der Historie
        await dataProvider.removeItemFromShoppingList(
            widget.householdId.toString(), item['id'].toString());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Löschen der Einkaufshistorie: $e'),
        ),
      );
    }
  }
}
