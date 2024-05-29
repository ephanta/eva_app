import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:eva_app/widgets/navigation/app_bar_custom.dart';
import 'package:flutter/material.dart';

//TODO: Update/Fix BottomNavBarItem
import '../widgets/navigation/bottom_nav_bar_item.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

/// {@category Screens}
/// Ansicht für die Home-Seite
@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Der Zustand für die Home-Seite
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<String> haushaltList = ["Haushalt 1", "Haushalt 2"]; // Initiale Haushaltsliste

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addNewHaushalt() {
    setState(() {
      haushaltList.add("Haushalt ${haushaltList.length + 1}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(showArrow: false, showProfile: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Haushalte',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: haushaltList.length + 1, // Eine zusätzliche Kachel für das Hinzufügen
                  itemBuilder: (context, index) {
                    if (index == haushaltList.length) {
                      // Die Kachel zum Hinzufügen neuer Haushalte
                      return GestureDetector(
                        onTap: _addNewHaushalt,
                        child: Card(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 50.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Die regulären Haushaltskacheln
                      return Card(
                        child: Center(
                          child: Text(
                            haushaltList[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: BottomNavBarCustom(
          pageType: PageType.home,
          showHome: true,
          showShoppingList: true,
          showPlanner: true,
        ),
    );
  }
}
