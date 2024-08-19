import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../routes/app_router.gr.dart';
import 'bottom_nav_bar_item.dart';

enum PageType { home, shoppingList, planner, homeDetail }

/// {@category Widgets}
/// Widget für die Bottom Navigation Bar
class BottomNavBarCustom extends StatefulWidget implements PreferredSizeWidget {
  const BottomNavBarCustom({
    super.key,
    required this.pageType,
    required this.showHome,
    required this.showShoppingList,
    required this.showPlanner,
    required this.householdId,
  });

  final int householdId;
  final PageType pageType;
  final bool showHome;
  final bool showShoppingList;
  final bool showPlanner;

  @override
  State<BottomNavBarCustom> createState() => _BottomNavBarCustomState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _BottomNavBarCustomState extends State<BottomNavBarCustom> {
  Size get preferredSize => const Size.fromHeight(50.0);

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
              selected: widget.pageType == PageType.shoppingList ? true : false,
              onPressed: () {
                AutoRouter.of(context)
                    .push(ShoppingListRoute(householdId: widget.householdId));
              },
            ),
          if (widget.showHome)
            BottomNavBarItem(
              icon: Icons.home,
              label: 'Haushaltsübersicht',
              selected: widget.pageType == PageType.home ? true : false,
              onPressed: () {
                AutoRouter.of(context).push(const HomeRoute());
              },
            ),
          if (widget.showPlanner)
            BottomNavBarItem(
              icon: Icons.event,
              label: 'Wochenplan',
              selected: widget.pageType == PageType.planner ? true : false,
              onPressed: () {
                AutoRouter.of(context)
                    .push(PlannerRoute(householdId: widget.householdId));
              },
            ),
        ],
      ),
    );
  }
}
