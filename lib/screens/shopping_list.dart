import 'package:auto_route/auto_route.dart';
import 'package:eva_app/data/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/data_provider.dart';
import '../widgets/dialogs/delete_confirmation_dialog.dart';
import '../widgets/dialogs/show_add_item_dialog.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';
import '../widgets/text/custom_text.dart';

/// {@category Screens}
/// Ansicht der Einkaufsliste
@RoutePage()
class ShoppingListScreen extends StatefulWidget {
  final String householdId;

  const ShoppingListScreen({Key? key, required this.householdId})
      : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

/// Der Zustand für die Einkaufsliste
class _ShoppingListScreenState extends State<ShoppingListScreen> {
  late DataProvider _dataProvider;
  bool _isLoading = false;
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _dataProvider = Provider.of<DataProvider>(context, listen: false);
  }

  Future<List<Map<String, dynamic>>> _getShoppingList() async {
    final shoppingList =
        await _dataProvider.getShoppingList(widget.householdId);
    return shoppingList.where((item) => item['status'] == 'pending').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        showArrow: true,
        showHome: true,
        showProfile: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Constants.secondaryBackgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Center(
                      child: CustomText(
                        text: 'Einkaufsliste',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : FutureBuilder<List<Map<String, dynamic>>>(
                            future: _getShoppingList(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Fehler: ${snapshot.error}'));
                              }
                              final shoppingList = snapshot.data ?? [];
                              if (shoppingList.isEmpty) {
                                return const Center(
                                    child: Text('Die Einkaufsliste ist leer.'));
                              }
                              return ListView.builder(
                                itemCount: shoppingList.length,
                                itemBuilder: (context, index) {
                                  final item = shoppingList[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    color: Constants.primaryBackgroundColor,
                                    child: ListTile(
                                      title: Text(
                                        item['item_name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Constants.primaryTextColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Menge: ${item['amount']}',
                                        style: const TextStyle(
                                            color: Constants.primaryTextColor),
                                      ),
                                      leading: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Constants.warningColor),
                                        onPressed: () =>
                                            _deleteItem(item['id']),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.shopping_cart,
                                            color: Constants.successColor),
                                        onPressed: () =>
                                            _updateItemStatus(item['id'], true),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _clearShoppingList,
            backgroundColor: Constants.warningColor,
            child: const Icon(Icons.delete_sweep, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'addItem',
            onPressed: () async {
              await showAddItemDialog(
                context,
                dataProvider: _dataProvider,
                householdId: widget.householdId,
                isLoading: isLoading,
              );
              setState(() {});
            },
            backgroundColor: Constants.primaryBackgroundColor,
            child: ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, child) {
                return loading
                    ? CircularProgressIndicator(
                        color: Constants.primaryTextColor,
                      )
                    : Icon(Icons.add, color: Constants.primaryTextColor);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBarCustom(
        pageType: PageType.shoppingList,
        showHome: false,
        showShoppingList: false,
        showShoppingHistory: true,
        showPlanner: true,
        householdId: widget.householdId,
      ),
    );
  }

  Future<void> _updateItemStatus(String itemId, bool isPurchased) async {
    setState(() => _isLoading = true);
    try {
      await _dataProvider.updateShoppingItemStatus(itemId, isPurchased);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikelstatus aktualisiert')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Fehler beim Aktualisieren des Artikelstatus: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final confirmed = await deleteConfirmationDialog(
      context,
      'Eintrag',
      'Sind Sie sicher, dass Sie diesen Eintrag löschen möchten?',
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _dataProvider.removeItemFromShoppingList(itemId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel erfolgreich gelöscht')),
        );
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen des Artikels: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearShoppingList() async {
    final confirmed = await deleteConfirmationDialog(
      context,
      'Einkaufsliste leeren',
      'Sind Sie sicher, dass Sie die gesamte Einkaufsliste leeren möchten?',
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final shoppingList = await _getShoppingList();
        for (var item in shoppingList) {
          await _dataProvider.removeItemFromShoppingList(item['id'].toString());
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Einkaufsliste erfolgreich geleert')),
        );
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Leeren der Einkaufsliste: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
