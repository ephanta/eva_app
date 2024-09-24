import 'package:auto_route/auto_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.gr.dart';

/// {@category Routes}
/// Schützt die Routen der App vor unautorisiertem Zugriff.
/// Wenn der Nutzer eingeloggt ist, wird die Navigation fortgesetzt.
/// Andernfalls wird der Nutzer auf die Anmeldeseite umgeleitet.
/// @nodoc
class AuthGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(
      NavigationResolver resolver, StackRouter router) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Setzt die Navigation fort
      resolver.next(true);
    } else {
      // Leitet zur Anmeldeseite um
      router.push(const AuthRoute());
    }
  }
}
