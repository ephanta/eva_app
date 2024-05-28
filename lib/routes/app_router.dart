import 'package:auto_route/auto_route.dart';
import 'route_guard.dart';
import 'app_router.gr.dart';

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
    AutoRoute(page: HomeRoute.page, path: '/', initial: true, guards: [AuthGuard()]),
    AutoRoute(page: ProfileRoute.page, path: '/profile', guards: [AuthGuard()]),
    AutoRoute(page: PlannerRoute.page, path: '/planner', guards: [AuthGuard()]),
    AutoRoute(page: ShoppingListRoute.page, path: '/shopping-list', guards: [AuthGuard()]),


  ];
}