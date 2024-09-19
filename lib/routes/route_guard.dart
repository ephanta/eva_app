import 'package:auto_route/auto_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // If the user is authenticated, continue
      resolver.next(true);
    } else {
      // If the user is not authenticated, redirect to the auth page
      router.push(const AuthRoute());
    }
  }
}