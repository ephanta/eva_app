import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/constants.dart';
import '../provider/data_provider.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';
import '../widgets/text/custom_text.dart';

/// {@category Screens}
/// Ansicht der Einkaufshistorie
@RoutePage()
class ShoppingHistoryScreen extends StatefulWidget {
  final String householdId;

  const ShoppingHistoryScreen({Key? key, required this.householdId})
      : super(key: key);

  @override
  State<ShoppingHistoryScreen> createState() => _ShoppingHistoryScreenState();
}

/// Der Zustand für die Einkaufshistorie
class _ShoppingHistoryScreenState extends State<ShoppingHistoryScreen> {
  List<Map<String, dynamic>> _purchasedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShoppingHistory();
  }

  Future<void> _loadShoppingHistory() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      final items = await dataProvider.getShoppingList(widget.householdId);
      setState(() {
        _purchasedItems =
            items.where((item) => item['status'] == 'purchased').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Einkaufshistorie: $e')),
      );
    }
  }

  void _deleteItem(String itemId) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.removeItemFromShoppingList(itemId);
      _loadShoppingHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Löschen des Eintrags: $e')),
      );
    }
  }

  void _addItemAgain(Map<String, dynamic> item) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.addItemToShoppingList(
          widget.householdId, item['item_name'], item['amount']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${item['item_name']} wurde der Einkaufsliste hinzugefügt.')),
      );
      _loadShoppingHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Hinzufügen des Artikels: $e')),
      );
    }
  }

  Future<void> _clearPurchasedList() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      for (var item in _purchasedItems) {
        await dataProvider.removeItemFromShoppingList(item['id'].toString());
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einkaufshistorie erfolgreich geleert')),
      );
      _loadShoppingHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Löschen der Einkaufshistorie: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Styling
                  Container(
                    color: Constants.secondaryBackgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Center(
                      child: CustomText(text: 'Einkaufshistorie'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _purchasedItems.isEmpty
                      ? const Center(
                          child: Text('Keine gekauften Artikel vorhanden.'))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _purchasedItems.length,
                            itemBuilder: (context, index) {
                              return _buildShoppingHistoryCard(
                                  _purchasedItems[index]);
                            },
                          ),
                        ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearPurchasedList,
        backgroundColor: Constants.warningColor,
        // Matching red color for delete actions
        child: const Icon(Icons.delete_sweep, color: Colors.white),
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

  Widget _buildShoppingHistoryCard(Map<String, dynamic> item) {
    final DateTime purchasedAt = DateTime.parse(item['purchased_at']);
    final String formattedDate =
        DateFormat('dd.MM.yyyy HH:mm').format(purchasedAt);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Constants.primaryBackgroundColor,
      // Consistent background color for cards
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: CustomText(
          text: item['item_name'] ?? '',
          fontSize: 18,
        ),
        subtitle: Text('Menge: ${item['amount']} - Gekauft am $formattedDate'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_shopping_cart,
                  color: Constants.successColor),
              onPressed: () => _addItemAgain(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Constants.warningColor),
              onPressed: () => _deleteItem(item['id'].toString()),
            ),
          ],
        ),
      ),
    );
  }
}
