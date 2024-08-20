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

/// Der Zustand für die EinkaufsHistoryen-Seite
class _ShoppingHistoryScreenState extends State<ShoppingHistoryScreen> {
  List<Map<String, dynamic>>? _purchasedList;

  @override
  void initState() {
    super.initState();
    _loadShoppingHistory();
  }

  Future<void> _loadShoppingHistory() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      final list =
          await dataProvider.getShoppingList(widget.householdId.toString());
      setState(() {
        _purchasedList =
            list.where((item) => item['status'] == 'purchased').toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden der Einkaufsliste: $e'),
        ),
      );
    }
  }

  Future<void> _deleteItem(int itemId) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.removeItemFromShoppingList(
          widget.householdId.toString(), itemId.toString());
      _loadShoppingHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Löschen des Eintrags: $e'),
        ),
      );
    }
  }

  Future<void> _addItemAgain(int itemId) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    try {
      /// Artikel aus der Historie
      final item = _purchasedList!.firstWhere((item) => item['id'] == itemId);

      await dataProvider.addItemToShoppingList(
        widget.householdId.toString(),
        item['item_name'],
        item['amount'],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${item['item_name']} wurde der Einkaufsliste hinzugefügt.'),
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

  Future<void> _clearPurchasedList() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      for (var item in _purchasedList!) {
        await dataProvider.removeItemFromShoppingList(
            widget.householdId.toString(), item['id'].toString());
      }
      _loadShoppingHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Löschen der Einkaufshistorie: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
          showArrow: true, showHome: true, showProfile: true),
      body: _purchasedList == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child:
                      Text('Einkaufshistorie:', style: TextStyle(fontSize: 24)),
                ),
                Expanded(
                  child: Container(
                    color: Colors.orange[50],
                    child: _purchasedList!.isEmpty
                        ? const Center(child: Text('Keine gekauften Artikel.'))
                        : Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _purchasedList!.length,
                                  itemBuilder: (context, index) {
                                    final item = _purchasedList![index];

                                    final DateTime checkedAt =
                                        DateTime.parse(item['checked_at']);
                                    final String formattedDateDate =
                                        DateFormat('dd.MM.yyyy')
                                            .format(checkedAt);
                                    final String formattedDateTime =
                                        DateFormat('HH:mm').format(checkedAt);

                                    return ListTile(
                                      title: Text(item['item_name']),
                                      subtitle: Text(
                                          'Menge: ${item['amount']} - Gekauft am $formattedDateDate um $formattedDateTime Uhr'),
                                      leading: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          _deleteItem(item['id']);
                                        },
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(Icons.arrow_upward),
                                        onPressed: () {
                                          _addItemAgain(item['id']);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.delete_sweep),
                                  label: Text('Einkaufshistorie leeren'),
                                  onPressed: _clearPurchasedList,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
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
}
