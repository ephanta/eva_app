import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:eva_app/widgets/navigation/app_bar_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/data_provider.dart';
import '../widgets/navigation/bottom_navigation_bar.dart';

/// {@category Screens}
/// Ansicht für die Detailseite eines Haushalts
@RoutePage()
class HomeDetailScreen extends StatelessWidget {
  final int householdId;

  const HomeDetailScreen({Key? key, required this.householdId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lade die Details des Haushalts basierend auf der householdId
    return Scaffold(
      appBar: const AppBarCustom(showArrow: true, showProfile: true),
      body: Consumer<DataProvider>(builder: (context, dataProvider, child) {
        /// Lade die Details des Haushalts basierend auf der householdId
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Haushalt Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text('Haushalt ID: $householdId'),
            ],
          ),
        );
      }),
      bottomNavigationBar: BottomNavBarCustom(
        pageType: PageType.homeDetail,
        showHome: true,
        showShoppingList: true,
        showPlanner: true,
      ),
    );
  }
}
