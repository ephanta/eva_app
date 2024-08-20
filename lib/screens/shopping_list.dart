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
  List<Map<String, dynamic>>? _shoppingList;

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      final list =
          await dataProvider.getShoppingList(widget.householdId.toString());
      setState(() {
        _shoppingList =
            list.where((item) => item['status'] == 'pending').toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden der Einkaufsliste: $e'),
        ),
      );
    }
  }

  Future<void> _updateItemStatus(int itemId, bool isChecked) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final timestamp = DateTime.now();

    try {
      await dataProvider.updateShoppingItemStatus(
          itemId, userId, timestamp, isChecked);
      _loadShoppingList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Aktualisieren des Eintrags: $e'),
        ),
      );
    }
  }

  Future<void> _deleteItem(int itemId) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.removeItemFromShoppingList(
          widget.householdId.toString(), itemId.toString());
      _loadShoppingList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Löschen des Eintrags: $e'),
        ),
      );
    }
  }

  Future<void> _clearShoppingList() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      for (var item in _shoppingList!) {
        await dataProvider.removeItemFromShoppingList(
            widget.householdId.toString(), item['id'].toString());
      }
      _loadShoppingList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Löschen der Einkaufsliste: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
          showArrow: true, showHome: true, showProfile: true),
      body: _shoppingList == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Einkaufsliste', style: TextStyle(fontSize: 24)),
                ),
                Expanded(
                  child: Container(
                    color: Colors.orange[50],
                    child: _shoppingList!.isEmpty
                        ? const Center(
                            child: Text('Die Einkaufsliste ist leer.'))
                        : ListView.builder(
                            itemCount: _shoppingList!.length,
                            itemBuilder: (context, index) {
                              final item = _shoppingList![index];
                              return ListTile(
                                title: Text(item['item_name']),
                                subtitle: Text('Menge: ${item['amount']}'),
                                leading: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDeleteConfirmationDialog(
                                      context,
                                      widget.householdId,
                                      item['id'],
                                      'Eintrag',
                                      'Sind Sie sicher, dass Sie diesen Eintrag löschen möchten?',
                                      'shoppinglist',
                                      onDeleted: _loadShoppingList,
                                    );
                                  },
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.shopping_cart),
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
                    icon: Icon(Icons.delete_sweep),
                    label: Text('Einkaufsliste leeren'),
                    onPressed: _clearShoppingList,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addItem',
        onPressed: () => showAddItemDialog(context, widget.householdId),
        child: Icon(Icons.add),
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
}
