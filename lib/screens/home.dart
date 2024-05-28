import 'package:flutter/material.dart';

import '../components/bottom_nav_bar_item.dart';

/// {@category Screens}
/// Ansicht für die Home-Seite
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Der Zustand für die Home-Seite
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Rezept des Tages',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Container(
              color: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              child: Text(
                'Name des Gerichts',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BottomNavBarItem(
              icon: Icons.home,
              label: 'Startseite',
              selected: _selectedIndex == 0,
              onPressed: () => _onItemTapped(0),
            ),
            BottomNavBarItem(
              icon: Icons.search,
              label: 'Suche',
              selected: _selectedIndex == 1,
              onPressed: () => _onItemTapped(1),
            ),
            BottomNavBarItem(
              icon: Icons.person,
              label: 'Profil',
              selected: _selectedIndex == 2,
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}
