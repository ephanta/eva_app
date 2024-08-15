import 'package:eva_app/provider/data_provider.dart';
import 'package:eva_app/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Die Hauptmethode für die Flutter-Anwendung.
Future<void> main() async {
  try {
    await dotenv.load(fileName: '.env');
    print('.env Datei erfolgreich geladen');
  } catch (e) {
    print('Fehler beim Laden der .env Datei: $e');
  }
  await initializeSupabase();
  runApp(
    /// Initialisieren der Provider für die Datenverwaltung
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => DataProvider(Supabase.instance.client)),
      ],
      child: const FamilyFeastApp(),
    ),
  );
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
  /// AppRouter für das Verwenden von Routen
  final _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FamilyFeast',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),

      /// Konfiguration des AppRouters
      routerConfig: _appRouter.config(),
    );
  }
}
