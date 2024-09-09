import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../routes/app_router.gr.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../provider/data_provider.dart';

@RoutePage()
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isSignUp = false;

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
        AutoRouter.of(context).push(const HomeRoute());
      }
    } catch (e) {
      print('Error checking auth status: $e');
      // Handle error appropriately
    }
  }

  Future<void> _signInOrSignUp() async {
    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          data: {'username': _usernameController.text},
        );
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      _checkAuthStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
            if (_isSignUp)
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Nutzername'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
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
    _usernameController.dispose();
    super.dispose();
  }
}