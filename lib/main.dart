import 'package:eva_app/provider/data_provider.dart';
import 'package:eva_app/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initialize both Supabase clients for Account A and Account B
late SupabaseClient supabaseClientA;  // Account A: Authentication
late SupabaseClient supabaseClientB;  // Account B: Recipe Management

/// Die Hauptmethode für die Flutter-Anwendung.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    print('.env Datei erfolgreich geladen');
  } catch (e) {
    print('Fehler beim Laden der .env Datei: $e');
  }

  // Initialize both Supabase clients
  await initializeSupabaseClients();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => DataProvider(supabaseClientA)),  // Use Account A for data provider
      ],
      child: const FamilyFeastApp(),
    ),
  );
}

/// Initialize both Supabase clients (Account A and Account B)
Future<void> initializeSupabaseClients() async {
  try {
    // Initialize Account A (Authentication)
    supabaseClientA = SupabaseClient(
      dotenv.env['SUPABASE_URL_ACCOUNT_A']!,
      dotenv.env['SUPABASE_ANON_KEY_ACCOUNT_A']!,
    );
    print('Supabase Account A erfolgreich initialisiert');

    // Initialize Account B (Recipe Management)
    supabaseClientB = SupabaseClient(
      dotenv.env['SUPABASE_URL_ACCOUNT_B']!,
      dotenv.env['SUPABASE_ANON_KEY_ACCOUNT_B']!,
    );
    print('Supabase Account B erfolgreich initialisiert');
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
