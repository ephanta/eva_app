// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:eva_app/screens/auth.dart' as _i1;
import 'package:eva_app/screens/home.dart' as _i3;
import 'package:eva_app/screens/home_detail.dart' as _i2;
import 'package:eva_app/screens/planner.dart' as _i4;
import 'package:eva_app/screens/profile.dart' as _i5;
import 'package:eva_app/screens/recipe_management.dart' as _i6;
import 'package:eva_app/screens/shopping_list.dart' as _i7;
import 'package:flutter/material.dart' as _i9;

abstract class $AppRouter extends _i8.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i8.PageFactory> pagesMap = {
    AuthRoute.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AuthScreen(),
      );
    },
    HomeDetailRoute.name: (routeData) {
      final args = routeData.argsAs<HomeDetailRouteArgs>();
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.HomeDetailScreen(
          key: args.key,
          householdId: args.householdId,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.HomeScreen(),
      );
    },
    PlannerRoute.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.PlannerScreen(),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.ProfileScreen(),
      );
    },
    RecipeManagementRoute.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.RecipeManagementScreen(),
      );
    },
    ShoppingListRoute.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.ShoppingListScreen(),
      );
    },
  };
}

/// generated route for
/// [_i1.AuthScreen]
class AuthRoute extends _i8.PageRouteInfo<void> {
  const AuthRoute({List<_i8.PageRouteInfo>? children})
      : super(
          AuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthRoute';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}

/// generated route for
/// [_i2.HomeDetailScreen]
class HomeDetailRoute extends _i8.PageRouteInfo<HomeDetailRouteArgs> {
  HomeDetailRoute({
    _i9.Key? key,
    required int householdId,
    List<_i8.PageRouteInfo>? children,
  }) : super(
          HomeDetailRoute.name,
          args: HomeDetailRouteArgs(
            key: key,
            householdId: householdId,
          ),
          initialChildren: children,
        );

  static const String name = 'HomeDetailRoute';

  static const _i8.PageInfo<HomeDetailRouteArgs> page =
      _i8.PageInfo<HomeDetailRouteArgs>(name);
}

class HomeDetailRouteArgs {
  const HomeDetailRouteArgs({
    this.key,
    required this.householdId,
  });

  final _i9.Key? key;

  final int householdId;

  @override
  String toString() {
    return 'HomeDetailRouteArgs{key: $key, householdId: $householdId}';
  }
}

/// generated route for
/// [_i3.HomeScreen]
class HomeRoute extends _i8.PageRouteInfo<void> {
  const HomeRoute({List<_i8.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}

/// generated route for
/// [_i4.PlannerScreen]
class PlannerRoute extends _i8.PageRouteInfo<void> {
  const PlannerRoute({List<_i8.PageRouteInfo>? children})
      : super(
          PlannerRoute.name,
          initialChildren: children,
        );

  static const String name = 'PlannerRoute';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}

/// generated route for
/// [_i5.ProfileScreen]
class ProfileRoute extends _i8.PageRouteInfo<void> {
  const ProfileRoute({List<_i8.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}

/// generated route for
/// [_i6.RecipeManagementScreen]
class RecipeManagementRoute extends _i8.PageRouteInfo<void> {
  const RecipeManagementRoute({List<_i8.PageRouteInfo>? children})
      : super(
          RecipeManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'RecipeManagementRoute';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}

/// generated route for
/// [_i7.ShoppingListScreen]
class ShoppingListRoute extends _i8.PageRouteInfo<void> {
  const ShoppingListRoute({List<_i8.PageRouteInfo>? children})
      : super(
          ShoppingListRoute.name,
          initialChildren: children,
        );

  static const String name = 'ShoppingListRoute';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}
