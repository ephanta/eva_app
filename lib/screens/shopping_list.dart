import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        _shoppingList = list;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden der Einkaufsliste: $e'),
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
          : _shoppingList!.isEmpty
              ? const Center(child: Text('Die Einkaufsliste ist leer.'))
              : ListView.builder(
                  itemCount: _shoppingList!.length,
                  itemBuilder: (context, index) {
                    final item = _shoppingList![index];
                    return CheckboxListTile(
                      title: Text(item['item_name']),
                      subtitle: Text('Menge: ${item['amount']}'),
                      value: false,
                      onChanged: (bool? value) {
                        // Hier kannst du den Status des Items ändern
                      },
                      secondary: IconButton(
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
                    );
                  },
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
        householdId: widget.householdId,
      ),
    );
  }
}
