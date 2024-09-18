import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/data_provider.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

@RoutePage()
class ShoppingListScreen extends StatefulWidget {
  final String householdId;

  const ShoppingListScreen({Key? key, required this.householdId})
      : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  late DataProvider _dataProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataProvider = Provider.of<DataProvider>(context, listen: false);
  }

  Future<List<Map<String, dynamic>>> _getShoppingList() async {
    final shoppingList = await _dataProvider.getShoppingList(widget.householdId);
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
        future: _getShoppingList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }
          final shoppingList = snapshot.data ?? [];
          if (shoppingList.isEmpty) {
            return const Center(child: Text('Die Einkaufsliste ist leer.'));
          }
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Einkaufsliste',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: shoppingList.length,
                  itemBuilder: (context, index) {
                    final item = shoppingList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        title: Text(item['item_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Menge: ${item['amount']}'),
                        leading: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(item['id']),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.shopping_cart, color: Colors.green),
                          onPressed: () => _updateItemStatus(item['id'], true),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Einkaufsliste leeren'),
                  onPressed: _clearShoppingList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addItem',
        onPressed: () async {
          await _showAddItemDialog(context);
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBarCustom(
        pageType: PageType.shoppingList,
        showHome: true,
        showShoppingList: false,
        showShoppingHistory:true,
        showPlanner: false,
        householdId: widget.householdId,
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        String itemName = '';
        String amount = '';
        return AlertDialog(
          title: const Text('Artikel hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Artikelname'),
                onChanged: (value) => itemName = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Menge'),
                onChanged: (value) => amount = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Hinzufügen'),
              onPressed: () => Navigator.of(context).pop({'name': itemName, 'amount': amount}),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await _dataProvider.addItemToShoppingList(widget.householdId, result['name']!, result['amount']!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel erfolgreich hinzugefügt')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hinzufügen des Artikels: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
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
        SnackBar(content: Text('Fehler beim Aktualisieren des Artikelstatus: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final confirmed = await showDeleteConfirmationDialog(
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
    final confirmed = await showDeleteConfirmationDialog(
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

  Future<bool> showDeleteConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Löschen'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed
  }
}