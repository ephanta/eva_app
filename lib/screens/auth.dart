import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../provider/data_provider.dart';
import '../routes/app_router.gr.dart';
import '../widgets/navigation/app_bar_custom.dart';

/// {@category Screens}
/// Authentifizierungsbildschirm
@RoutePage()
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

/// Der State des Authentifizierungsbildschirms
class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final session = await dataProvider.getCurrentSession();
      if (session != null) {
        AutoRouter.of(context).replace(const HomeRoute());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking auth status: $e');
      }
      // Handle error appropriately
    }
  }

  Future<void> _signInOrSignUp() async {
    setState(() {
      _loading = true; // Show loading spinner while processing
    });
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      if (_isSignUp) {
        // Sign up and include username in user metadata
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (response.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Erfolgreich registriert! Bitte bestätigen Sie Ihre E-Mail.')),
          );
        }
      } else {
        // Sign in with email and password
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (response.session != null) {
          _checkAuthStatus(); // Proceed to Home if sign-in is successful
        }
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _loading = false; // Hide loading spinner when done
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
          showArrow: false, showHome: false, showProfile: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Authentifizierung',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),
            if (_isSignUp) const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator() // Show a spinner while loading
                : ElevatedButton(
                    onPressed: _signInOrSignUp,
                    child: Text(_isSignUp ? 'Registrieren' : 'Anmelden'),
                  ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                });
              },
              child: Text(_isSignUp
                  ? 'Bereits ein Konto? Anmelden'
                  : 'Kein Konto? Registrieren'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
