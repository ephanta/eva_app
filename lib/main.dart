import 'package:eva_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The main entry point for the Flutter application.
Future<void> main() async {
  try {
    await dotenv.load(fileName: '.env');
    print('.env Datei erfolgreich geladen');
  } catch (e) {
    print('Fehler beim Laden der .env Datei: $e');
  }
  initializeSupabase();
  runApp(const FamilyFeastApp());
}

void initializeSupabase() async {
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

class FamilyFeastApp extends StatelessWidget {
  const FamilyFeastApp({super.key});

  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FamilyFeast',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const HomeScreen(title: 'FamilyFeast'),
    );
  }
}
