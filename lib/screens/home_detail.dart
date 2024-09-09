import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../provider/data_provider.dart';
import '../routes/app_router.gr.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

@RoutePage()
class HomeDetailScreen extends StatefulWidget {
  final int householdId;

  const HomeDetailScreen({Key? key, required this.householdId}) : super(key: key);

  @override
  State<HomeDetailScreen> createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends State<HomeDetailScreen> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final userId = dataProvider.currentUserId;

    if (userId != null) {
      try {
        final role = await dataProvider.getUserRoleInHousehold(widget.householdId, userId);
        setState(() {
          userRole = role;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Abrufen der Benutzerrolle: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Benutzer-ID ist nicht verfügbar.')),
      );
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
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return FutureBuilder<Map<String, dynamic>>(
            future: dataProvider.getCurrentHousehold(widget.householdId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return const Text('Keine Daten gefunden.');
              } else {
                final household = snapshot.data!;
                Color householdColor = Color(int.parse(household['color'].substring(1, 7), radix: 16) + 0xFF000000);
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // The rest of your UI remains unchanged...
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBarCustom(
        pageType: PageType.homeDetail,
        showHome: false,
        showShoppingList: false,
        showPlanner: true,
      ),
    );
  }
}