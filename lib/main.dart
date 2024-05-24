import 'package:eva_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eva_app/screens/auth.dart';

/// The main entry point for the Flutter application.
Future<void> main() async {
  try {
    await dotenv.load(fileName: '.env');
    print('.env Datei erfolgreich geladen');
  } catch (e) {
    print('Fehler beim Laden der .env Datei: $e');
  }
  await initializeSupabase();
  runApp(const FamilyFeastApp());
}

Future<void> initializeSupabase() async {
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_KEY']!,
    );
    print('Supabase erfolgreich initialisiert');
  } catch (e) {
    print('Fehler bei der Initialisierung von Supabase: $e');
  }
}

class FamilyFeastApp extends StatefulWidget {
  const FamilyFeastApp({super.key});

  @override
  _FamilyFeastAppState createState() => _FamilyFeastAppState();
}

class _FamilyFeastAppState extends State<FamilyFeastApp> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _isAuthenticated = session != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FamilyFeast',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: _isAuthenticated ? const HomeScreen(title: 'FamilyFeast') : const AuthScreen(),
    );
  }
}