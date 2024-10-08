import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../routes/app_router.gr.dart';
import '../widgets/navigation/app_bar_custom.dart';

/// {@category Screens}
/// Ansicht für das Anmelden oder Registrieren eines Nutzers
@RoutePage()
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

/// Der Zustand für die Authentifizierungsseite
class _AuthScreenState extends State<AuthScreen> {
  late final SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _checkAuthStatus(); // Check authentication status when the screen initializes
  }

  /// Überprüft den Authentifizierungsstatus
  Future<void> _checkAuthStatus() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        AutoRouter.of(context).push(const HomeRoute());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking auth status: $e');
      }
      // Handle error appropriately
    }
  }

  void _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
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
            Column(
              children: [
                Text(
                  'Authentifizierung',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                /// Email Auth
                SupaEmailAuth(
                  localization: const SupaEmailAuthLocalization(
                    enterEmail: 'E-Mail eingeben',
                    validEmailError:
                        'Bitte geben Sie eine gültige E-Mail-Adresse ein',
                    enterPassword: 'Passwort eingeben',
                    passwordLengthError:
                        'Das Passwort muss mindestens 6 Zeichen lang sein',
                    forgotPassword: 'Passwort vergessen?',
                    signIn: 'Anmelden',
                    signUp: 'Registrieren',
                    dontHaveAccount:
                        'Sie haben noch keinen Account? Registrieren Sie sich!',
                    haveAccount:
                        'Sie haben bereits einen Account? Melden Sie sich an!',
                    sendPasswordReset: 'Passwort zurücksetzen',
                    backToSignIn: 'Zurück zur Anmeldung',
                    unexpectedError: 'Ein unerwarteter Fehler ist aufgetreten',
                  ),
                  redirectTo: '/',
                  onSignInComplete: (response) {
                    _checkAuthStatus();
                  },
                  onSignUpComplete: (response) {
                    _checkAuthStatus();
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
                        prefs.setString('username', val);
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
