import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../provider/data_provider.dart';
import '../widgets/dialogs/show_add_item_dialog.dart';
import '../widgets/dialogs/show_delete_confirmation_dialog.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

/// {@category Screens}
/// Ansicht für die Einkaufsliste
@RoutePage()
class ShoppingListScreen extends StatefulWidget {
  final int householdId;

  const ShoppingListScreen({Key? key, required this.householdId})
      : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

/// Der Zustand für die Einkaufslisten-Seite
class _ShoppingListScreenState extends State<ShoppingListScreen> {
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
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Fehler: ${snapshot.error}'),
                );
              }
              final shoppingList = snapshot.data!
                  .where((item) => item['status'] == 'pending')
                  .toList();
              if (shoppingList.isEmpty) {
                return const Center(
                  child: Text('Die Einkaufsliste ist leer.'),
                );
              } else {
                return Center(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Einkaufsliste',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.orange[50],
                          child: ListView.builder(
                            itemCount: shoppingList.length,
                            itemBuilder: (context, index) {
                              final item = shoppingList[index];
                              return ListTile(
                                title: Text(item['item_name']),
                                subtitle: Text('Menge: ${item['amount']}'),
                                leading: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDeleteConfirmationDialog(
                                      context,
                                      widget.householdId,
                                      item['id'],
                                      'Eintrag',
                                      'Sind Sie sicher, dass Sie diesen Eintrag löschen möchten?',
                                      'shoppinglist',
                                      onDeleted: () => setState(() {}),
                                    );
                                  },
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.shopping_cart),
                                  onPressed: () {
                                    _updateItemStatus(item['id'], true);
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
                          label: const Text('Einkaufsliste leeren'),
                          onPressed: () async {
                            await _clearShoppingList(
                                dataProvider, shoppingList);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addItem',
        onPressed: () async {
          await showAddItemDialog(context, widget.householdId);
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBarCustom(
        pageType: PageType.shoppingList,
        showHome: true,
        showShoppingList: false,
        showPlanner: false,
        showShoppingHistory: true,
        householdId: widget.householdId,
      ),
    );
  }

  /// Aktualisiert den Status eines Einkaufslisten-Eintrags
  Future<void> _updateItemStatus(int itemId, bool isChecked) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final timestamp = DateTime.now();

    try {
      await dataProvider.updateShoppingItemStatus(
          itemId, userId, timestamp, isChecked);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Aktualisieren des Eintrags: $e'),
        ),
      );
    }
  }

  /// Löscht die Einkaufsliste
  Future<void> _clearShoppingList(DataProvider dataProvider,
      List<Map<String, dynamic>> shoppingList) async {
    try {
      for (var item in shoppingList) {
        await dataProvider.removeItemFromShoppingList(
            widget.householdId.toString(), item['id'].toString());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Löschen der Einkaufsliste: $e'),
        ),
      );
    }
  }
}
