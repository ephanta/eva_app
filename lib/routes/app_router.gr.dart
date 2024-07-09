// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i11;
import 'package:eva_app/screens/auth.dart' as _i1;
import 'package:eva_app/screens/home.dart' as _i3;
import 'package:eva_app/screens/home_detail.dart' as _i2;
import 'package:eva_app/screens/planner.dart' as _i4;
import 'package:eva_app/screens/profile.dart' as _i5;
import 'package:eva_app/screens/recipe_create_screen.dart' as _i6;
import 'package:eva_app/screens/recipe_detail_screen.dart' as _i7;
import 'package:eva_app/screens/recipe_edit_screen.dart' as _i8;
import 'package:eva_app/screens/recipe_list_screen.dart' as _i9;
import 'package:eva_app/screens/shopping_list.dart' as _i10;
import 'package:flutter/material.dart' as _i12;

abstract class $AppRouter extends _i11.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i11.PageFactory> pagesMap = {
    AuthRoute.name: (routeData) {
      return _i11.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AuthScreen(),
      );
    },
    HomeDetailRoute.name: (routeData) {
      final args = routeData.argsAs<HomeDetailRouteArgs>();
      return _i11.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.HomeDetailScreen(
          key: args.key,
          householdId: args.householdId,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return _i11.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.HomeScreen(),
      );
    },
    PlannerRoute.name: (routeData) {
      return _i11.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.PlannerScreen(),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i11.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.ProfileScreen(),
      );
    },
    RecipeCreateRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<RecipeCreateRouteArgs>(
          orElse: () => RecipeCreateRouteArgs(
              householdId: pathParams.getString('householdId')));
      return _i11.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i6.RecipeCreateScreen(
          key: args.key,
          householdId: args.householdId,
        ),
      );
    },
    RecipeDetailRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<RecipeDetailRouteArgs>(
          orElse: () =>
              RecipeDetailRouteArgs(recipeId: pathParams.getString('id')));
      return _i11.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.RecipeDetailScreen(
          key: args.key,
          recipeId: args.recipeId,
        ),
      );
    },
    RecipeEditRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<RecipeEditRouteArgs>(
          orElse: () =>
              RecipeEditRouteArgs(recipeId: pathParams.getString('id')));
      return _i11.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.RecipeEditScreen(
          key: args.key,
          recipeId: args.recipeId,
        ),
      );
    },
    RecipeListRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<RecipeListRouteArgs>(
          orElse: () =>
              RecipeListRouteArgs(householdId: pathParams.getString('id')));
      return _i11.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i9.RecipeListScreen(
          key: args.key,
          householdId: args.householdId,
        ),
      );
    },
    ShoppingListRoute.name: (routeData) {
      return _i11.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.ShoppingListScreen(),
      );
    },
  };
}

/// generated route for
/// [_i1.AuthScreen]
class AuthRoute extends _i11.PageRouteInfo<void> {
  const AuthRoute({List<_i11.PageRouteInfo>? children})
      : super(
          AuthRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthRoute';

  static const _i11.PageInfo<void> page = _i11.PageInfo<void>(name);
}

/// generated route for
/// [_i2.HomeDetailScreen]
class HomeDetailRoute extends _i11.PageRouteInfo<HomeDetailRouteArgs> {
  HomeDetailRoute({
    _i12.Key? key,
    required int householdId,
    List<_i11.PageRouteInfo>? children,
  }) : super(
          HomeDetailRoute.name,
          args: HomeDetailRouteArgs(
            key: key,
            householdId: householdId,
          ),
          initialChildren: children,
        );

  static const String name = 'HomeDetailRoute';

  static const _i11.PageInfo<HomeDetailRouteArgs> page =
      _i11.PageInfo<HomeDetailRouteArgs>(name);
}

class HomeDetailRouteArgs {
  const HomeDetailRouteArgs({
    this.key,
    required this.householdId,
  });

  final _i12.Key? key;

  final int householdId;

  @override
  String toString() {
    return 'HomeDetailRouteArgs{key: $key, householdId: $householdId}';
  }
}

/// generated route for
/// [_i3.HomeScreen]
class HomeRoute extends _i11.PageRouteInfo<void> {
  const HomeRoute({List<_i11.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i11.PageInfo<void> page = _i11.PageInfo<void>(name);
}

/// generated route for
/// [_i4.PlannerScreen]
class PlannerRoute extends _i11.PageRouteInfo<void> {
  const PlannerRoute({List<_i11.PageRouteInfo>? children})
      : super(
          PlannerRoute.name,
          initialChildren: children,
        );

  static const String name = 'PlannerRoute';

  static const _i11.PageInfo<void> page = _i11.PageInfo<void>(name);
}

/// generated route for
/// [_i5.ProfileScreen]
class ProfileRoute extends _i11.PageRouteInfo<void> {
  const ProfileRoute({List<_i11.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i11.PageInfo<void> page = _i11.PageInfo<void>(name);
}

/// generated route for
/// [_i6.RecipeCreateScreen]
class RecipeCreateRoute extends _i11.PageRouteInfo<RecipeCreateRouteArgs> {
  RecipeCreateRoute({
    _i12.Key? key,
    required String householdId,
    List<_i11.PageRouteInfo>? children,
  }) : super(
          RecipeCreateRoute.name,
          args: RecipeCreateRouteArgs(
            key: key,
            householdId: householdId,
          ),
          rawPathParams: {'householdId': householdId},
          initialChildren: children,
        );

  static const String name = 'RecipeCreateRoute';

  static const _i11.PageInfo<RecipeCreateRouteArgs> page =
      _i11.PageInfo<RecipeCreateRouteArgs>(name);
}

class RecipeCreateRouteArgs {
  const RecipeCreateRouteArgs({
    this.key,
    required this.householdId,
  });

  final _i12.Key? key;

  final String householdId;

  @override
  String toString() {
    return 'RecipeCreateRouteArgs{key: $key, householdId: $householdId}';
  }
}

/// generated route for
/// [_i7.RecipeDetailScreen]
class RecipeDetailRoute extends _i11.PageRouteInfo<RecipeDetailRouteArgs> {
  RecipeDetailRoute({
    _i12.Key? key,
    required String recipeId,
    List<_i11.PageRouteInfo>? children,
  }) : super(
          RecipeDetailRoute.name,
          args: RecipeDetailRouteArgs(
            key: key,
            recipeId: recipeId,
          ),
          rawPathParams: {'id': recipeId},
          initialChildren: children,
        );

  static const String name = 'RecipeDetailRoute';

  static const _i11.PageInfo<RecipeDetailRouteArgs> page =
      _i11.PageInfo<RecipeDetailRouteArgs>(name);
}

class RecipeDetailRouteArgs {
  const RecipeDetailRouteArgs({
    this.key,
    required this.recipeId,
  });

  final _i12.Key? key;

  final String recipeId;

  @override
  String toString() {
    return 'RecipeDetailRouteArgs{key: $key, recipeId: $recipeId}';
  }
}

/// generated route for
/// [_i8.RecipeEditScreen]
class RecipeEditRoute extends _i11.PageRouteInfo<RecipeEditRouteArgs> {
  RecipeEditRoute({
    _i12.Key? key,
    required String recipeId,
    List<_i11.PageRouteInfo>? children,
  }) : super(
          RecipeEditRoute.name,
          args: RecipeEditRouteArgs(
            key: key,
            recipeId: recipeId,
          ),
          rawPathParams: {'id': recipeId},
          initialChildren: children,
        );

  static const String name = 'RecipeEditRoute';

  static const _i11.PageInfo<RecipeEditRouteArgs> page =
      _i11.PageInfo<RecipeEditRouteArgs>(name);
}

class RecipeEditRouteArgs {
  const RecipeEditRouteArgs({
    this.key,
    required this.recipeId,
  });

  final _i12.Key? key;

  final String recipeId;

  @override
  String toString() {
    return 'RecipeEditRouteArgs{key: $key, recipeId: $recipeId}';
  }
}

/// generated route for
/// [_i9.RecipeListScreen]
class RecipeListRoute extends _i11.PageRouteInfo<RecipeListRouteArgs> {
  RecipeListRoute({
    _i12.Key? key,
    required String householdId,
    List<_i11.PageRouteInfo>? children,
  }) : super(
          RecipeListRoute.name,
          args: RecipeListRouteArgs(
            key: key,
            householdId: householdId,
          ),
          rawPathParams: {'id': householdId},
          initialChildren: children,
        );

  static const String name = 'RecipeListRoute';

  static const _i11.PageInfo<RecipeListRouteArgs> page =
      _i11.PageInfo<RecipeListRouteArgs>(name);
}

class RecipeListRouteArgs {
  const RecipeListRouteArgs({
    this.key,
    required this.householdId,
  });

  final _i12.Key? key;

  final String householdId;

  @override
  String toString() {
    return 'RecipeListRouteArgs{key: $key, householdId: $householdId}';
  }
}

/// generated route for
/// [_i10.ShoppingListScreen]
class ShoppingListRoute extends _i11.PageRouteInfo<void> {
  const ShoppingListRoute({List<_i11.PageRouteInfo>? children})
      : super(
          ShoppingListRoute.name,
          initialChildren: children,
        );

  static const String name = 'ShoppingListRoute';

  static const _i11.PageInfo<void> page = _i11.PageInfo<void>(name);
}
