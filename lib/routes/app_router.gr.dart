// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:eva_app/screens/auth.dart' as _i1;
import 'package:eva_app/screens/home.dart' as _i3;
import 'package:eva_app/screens/home_detail.dart' as _i2;
import 'package:eva_app/screens/planner.dart' as _i4;
import 'package:eva_app/screens/profile.dart' as _i5;
import 'package:eva_app/screens/recipe_management.dart' as _i6;
import 'package:eva_app/screens/shopping_history.dart' as _i7;
import 'package:eva_app/screens/shopping_list.dart' as _i8;
import 'package:flutter/material.dart' as _i10;

abstract class $AppRouter extends _i9.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i9.PageFactory> pagesMap = {
    AuthRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AuthScreen(),
      );
    },
    HomeDetailRoute.name: (routeData) {
      final args = routeData.argsAs<HomeDetailRouteArgs>();
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.HomeDetailScreen(
          key: args.key,
          householdId: args.householdId,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.HomeScreen(),
      );
    },
    PlannerRoute.name: (routeData) {
      final args = routeData.argsAs<PlannerRouteArgs>();
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.PlannerScreen(
          key: args.key,
          householdId: args.householdId,
        ),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.ProfileScreen(),
      );
    },
    RecipeManagementRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.RecipeManagementScreen(),
      );
    },
    ShoppingHistoryRoute.name: (routeData) {
      final args = routeData.argsAs<ShoppingHistoryRouteArgs>();
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.ShoppingHistoryScreen(
          key: args.key,
          householdId: args.householdId,
        ),
      );
    },
    ShoppingListRoute.name: (routeData) {
      final args = routeData.argsAs<ShoppingListRouteArgs>();
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.ShoppingListScreen(
          key: args.key,
          householdId: args.householdId,
        ),
      );
    },
  };
}

/// generated route for
/// [_i1.AuthScreen]
class AuthRoute extends _i9.PageRouteInfo<void> {
  const AuthRoute({List<_i9.PageRouteInfo>? children})
      : super(
          AuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i2.HomeDetailScreen]
class HomeDetailRoute extends _i9.PageRouteInfo<HomeDetailRouteArgs> {
  HomeDetailRoute({
    _i10.Key? key,
    required String householdId,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          HomeDetailRoute.name,
          args: HomeDetailRouteArgs(
            key: key,
            householdId: householdId,
          ),
          initialChildren: children,
        );

  static const String name = 'HomeDetailRoute';

  static const _i9.PageInfo<HomeDetailRouteArgs> page =
      _i9.PageInfo<HomeDetailRouteArgs>(name);
}

class HomeDetailRouteArgs {
  const HomeDetailRouteArgs({
    this.key,
    required this.householdId,
  });

  final _i10.Key? key;

  final String householdId;

  @override
  String toString() {
    return 'HomeDetailRouteArgs{key: $key, householdId: $householdId}';
  }
}

/// generated route for
/// [_i3.HomeScreen]
class HomeRoute extends _i9.PageRouteInfo<void> {
  const HomeRoute({List<_i9.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i4.PlannerScreen]
class PlannerRoute extends _i9.PageRouteInfo<PlannerRouteArgs> {
  PlannerRoute({
    _i10.Key? key,
    required String householdId,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          PlannerRoute.name,
          args: PlannerRouteArgs(
            key: key,
            householdId: householdId,
          ),
          initialChildren: children,
        );

  static const String name = 'PlannerRoute';

  static const _i9.PageInfo<PlannerRouteArgs> page =
      _i9.PageInfo<PlannerRouteArgs>(name);
}

class PlannerRouteArgs {
  const PlannerRouteArgs({
    this.key,
    required this.householdId,
  });

  final _i10.Key? key;

  final String householdId;

  @override
  String toString() {
    return 'PlannerRouteArgs{key: $key, householdId: $householdId}';
  }
}

/// generated route for
/// [_i5.ProfileScreen]
class ProfileRoute extends _i9.PageRouteInfo<void> {
  const ProfileRoute({List<_i9.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i6.RecipeManagementScreen]
class RecipeManagementRoute extends _i9.PageRouteInfo<void> {
  const RecipeManagementRoute({List<_i9.PageRouteInfo>? children})
      : super(
          RecipeManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'RecipeManagementRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i7.ShoppingHistoryScreen]
class ShoppingHistoryRoute extends _i9.PageRouteInfo<ShoppingHistoryRouteArgs> {
  ShoppingHistoryRoute({
    _i10.Key? key,
    required String householdId,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          ShoppingHistoryRoute.name,
          args: ShoppingHistoryRouteArgs(
            key: key,
            householdId: householdId,
          ),
          initialChildren: children,
        );

  static const String name = 'ShoppingHistoryRoute';

  static const _i9.PageInfo<ShoppingHistoryRouteArgs> page =
      _i9.PageInfo<ShoppingHistoryRouteArgs>(name);
}

class ShoppingHistoryRouteArgs {
  const ShoppingHistoryRouteArgs({
    this.key,
    required this.householdId,
  });

  final _i10.Key? key;

  final String householdId;

  @override
  String toString() {
    return 'ShoppingHistoryRouteArgs{key: $key, householdId: $householdId}';
  }
}

/// generated route for
/// [_i8.ShoppingListScreen]
class ShoppingListRoute extends _i9.PageRouteInfo<ShoppingListRouteArgs> {
  ShoppingListRoute({
    _i10.Key? key,
    required String householdId,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          ShoppingListRoute.name,
          args: ShoppingListRouteArgs(
            key: key,
            householdId: householdId,
          ),
          initialChildren: children,
        );

  static const String name = 'ShoppingListRoute';

  static const _i9.PageInfo<ShoppingListRouteArgs> page =
      _i9.PageInfo<ShoppingListRouteArgs>(name);
}

class ShoppingListRouteArgs {
  const ShoppingListRouteArgs({
    this.key,
    required this.householdId,
  });

  final _i10.Key? key;

  final String householdId;

  @override
  String toString() {
    return 'ShoppingListRouteArgs{key: $key, householdId: $householdId}';
  }
}
