import 'package:auto_route/auto_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.gr.dart';

/// {@category Routes}
/// Schützt die Routen der App vor unautorisiertem Zugriff.
class AuthGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(
      NavigationResolver resolver, StackRouter router) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      resolver.next(true);
    } else {
      router.push(const AuthRoute());
    }
  }
}
