import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                // Email Auth
                SupaEmailAuth(
                  //TODO: Fix this
                  redirectTo: '/',
                  onSignInComplete: (response) {
                    //TODO: Fix this
                    Navigator.pushNamed(context, '/');
                  },
                  //TODO: Fix this
                  onSignUpComplete: (response) {
                    Navigator.pushNamed(context, '/');
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
                    //TODO: Edit label and other text
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
