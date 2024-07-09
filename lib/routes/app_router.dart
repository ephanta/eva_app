import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';
import 'route_guard.dart';

/// {@category Routes}
/// Konfiguriert Routen der App.
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends $AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    /// Routen für die Authentifizierung
    AutoRoute(page: AuthRoute.page, path: '/auth'),

    /// Routen für die App
    AutoRoute(
        page: HomeRoute.page,
        path: '/',
        initial: true,
        guards: [AuthGuard()]),
    AutoRoute(
        page: HomeDetailRoute.page,
        path: '/detail/:id',
        guards: [AuthGuard()]),
    AutoRoute(
        page: ProfileRoute.page, path: '/profile', guards: [AuthGuard()]),
    AutoRoute(
        page: PlannerRoute.page,
        path: '/detail/:id/planner',
        guards: [AuthGuard()]),
    AutoRoute(
        page: ShoppingListRoute.page,
        path: '/detail/:id/shopping-list',
        guards: [AuthGuard()]),

    /// Routen für Rezepte
    AutoRoute(
        page: RecipeListRoute.page,
        path: '/household/:id/recipes',
        guards: [AuthGuard()]),
    AutoRoute(
        page: RecipeDetailRoute.page,
        path: '/recipes/:id',
        guards: [AuthGuard()]),
    AutoRoute(
        page: RecipeCreateRoute.page,
        path: '/recipes/create',
        guards: [AuthGuard()]),
    AutoRoute(
        page: RecipeEditRoute.page,
        path: '/recipes/:id/edit',
        guards: [AuthGuard()]),
  ];
}