import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../routes/app_router.gr.dart';
import 'bottom_nav_bar_item.dart';

enum PageType { home, shoppingList, planner, homeDetail, shoppingHistory }

/// {@category Widgets}
/// Widget für die Bottom Navigation Bar
class BottomNavBarCustom extends StatefulWidget implements PreferredSizeWidget {
  const BottomNavBarCustom({
    Key? key,
    required this.pageType,
    required this.showHome,
    required this.showShoppingList,
    required this.showPlanner,
    required this.showShoppingHistory,
    required this.householdId,
  }) : super(key: key);

  final PageType pageType;
  final bool showHome;
  final bool showShoppingList;
  final bool showPlanner;
  final bool showShoppingHistory;
  final String householdId;

  @override
  State<BottomNavBarCustom> createState() => _BottomNavBarCustomState();

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

class _BottomNavBarCustomState extends State<BottomNavBarCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          if (widget.showShoppingList)
            BottomNavBarItem(
              icon: Icons.shopping_basket,
              label: 'Einkaufsliste',
              selected: widget.pageType == PageType.shoppingList,
              onPressed: () {
                AutoRouter.of(context).push(ShoppingListRoute(householdId: widget.householdId));
              },
            ),
          if (widget.showShoppingHistory)
            BottomNavBarItem(
              icon: Icons.history,
              label: 'Einkaufshistorie',
              selected: widget.pageType == PageType.shoppingHistory,
              onPressed: () {
                AutoRouter.of(context).push(ShoppingHistoryRoute(householdId: widget.householdId));
              },
            ),
          if (widget.showHome)
            BottomNavBarItem(
              icon: Icons.home,
              label: 'Haushaltsübersicht',
              selected: widget.pageType == PageType.home,
              onPressed: () {
                AutoRouter.of(context).push(const HomeRoute());
              },
            ),
          if (widget.showPlanner)
            BottomNavBarItem(
              icon: Icons.event,
              label: 'Wochenplan',
              selected: widget.pageType == PageType.planner,
              onPressed: () {
                AutoRouter.of(context).push(PlannerRoute(householdId: widget.householdId));
              },
            ),
        ],
      ),
    );
  }
}