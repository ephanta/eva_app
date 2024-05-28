import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import '../components/app_bar_custom.dart';

/// {@category Screens}
/// Ansicht für das Anmelden oder Registrieren eines Nutzers
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

/// Der Zustand für die Authentifizierungsseite
class _AuthScreenState extends State<AuthScreen> {

  @override
  void initState() {
    super.initState();
    _checkAuthStatus(); // Check authentication status when the screen initializes
  }

  Future<void> _checkAuthStatus() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Login')),
      appBar: const AppBarCustom(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  'Authentifizierung',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                // Email Auth
                SupaEmailAuth(
                  localization: const SupaEmailAuthLocalization(
                    enterEmail: 'E-Mail eingeben',
                    enterPassword: 'Passwort eingeben',
                    forgotPassword: 'Passwort vergessen?',
                    signIn: 'Anmelden',
                    signUp: 'Registrieren',
                    dontHaveAccount: 'Sie haben noch keinen Account? Registrieren Sie sich!',
                    haveAccount: 'Sie haben bereits einen Account? Melden Sie sich an!',
                  ),
                  redirectTo: '/',
                  onSignInComplete: (response) {
                    _checkAuthStatus(); // Check authentication status after sign in
                  },
                  onSignUpComplete: (response) {
                    _checkAuthStatus(); // Check authentication status after sign up
                  },
                  metadataFields: [
                    MetaDataField(
                      prefixIcon: const Icon(Icons.person),
                      label: 'Nutzername',
                      key: 'username',
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Bitte geben Sie einen Nutzernamen ein';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
