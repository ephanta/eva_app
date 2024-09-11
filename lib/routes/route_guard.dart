import 'package:auto_route/auto_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.gr.dart';

/// {@category Routes}
/// Schütz die Routen der App vor unautorisierten Zugriffen.
class AuthGuard extends AutoRouteGuard {
  @override

  /// Überprüft, ob der User angemeldet ist. Falls nicht, wird er auf die Auth-Seite weitergeleitet.
  Future<void> onNavigation(
      NavigationResolver resolver, StackRouter router) async {
    /// Aktueller User
    final user = Supabase.instance.client.auth.currentUser;

    /// Überprüft, ob der User angemeldet ist. Falls nicht, wird er auf die Auth-Seite weitergeleitet.
    if (user == null) {
      router.push(const AuthRoute());
    } else {
      resolver.next(true);
    }
  }
}
