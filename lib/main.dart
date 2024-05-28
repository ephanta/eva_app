import 'package:eva_app/screens/home.dart';
import 'package:eva_app/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eva_app/screens/auth.dart';

/// Die Hauptmethode für die Flutter-Anwendung.
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

/// Initialisierung Supabase
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

/// Das Root-Widget der Anwendung
class FamilyFeastApp extends StatefulWidget {
  const FamilyFeastApp({super.key});

  @override
  _FamilyFeastAppState createState() => _FamilyFeastAppState();
}

/// Der Zustand der FamilyFeastApp
class _FamilyFeastAppState extends State<FamilyFeastApp> {
  late final SupabaseClient _client;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _client.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      setState(() {
        _isAuthenticated = session != null;
      });
    });
    _checkAuthStatus();
  }

  /// Überprüft und aktualisiert den Authentifizierungsstatus
  Future<void> _checkAuthStatus() async {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _isAuthenticated = session != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FamilyFeast',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      initialRoute: _isAuthenticated ? '/' : '/auth',
      routes: {
        '/': (context) => _isAuthenticated ? const HomeScreen(title: 'FamilyFeast') : const AuthScreen(),
        '/auth': (context) => const AuthScreen(),
        '/profile': (context) => _isAuthenticated ? const ProfileScreen() : const AuthScreen(),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const Scaffold(
            body: Center(
              child: Text(
                'Not Found',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
