import 'package:eva_app/provider/data_provider.dart';
import 'package:eva_app/routes/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    if (kDebugMode) {
      print('.env Datei erfolgreich geladen');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Fehler beim Laden der .env Datei: $e');
    }
  }

  await Supabase.initialize(
    url: dotenv.env['URL_ACCOUNT_A']!,
    anonKey: dotenv.env['ANON_KEY_ACCOUNT_A']!,
  );

  await initializeDateFormatting('de_DE', null);
  if (kDebugMode) {
    print('Date formatting for German initialized');
  }

  final supabase = Supabase.instance.client;

  final session = supabase.auth.currentSession;
  final jwtToken = session?.accessToken;

  if (jwtToken != null) {
    if (kDebugMode) {
      print('JWT Token: $jwtToken');
    }
  } else {
    if (kDebugMode) {
      print('No JWT token found. User may not be authenticated.');
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => DataProvider(supabase),
      child: const FamilyFeastApp(),
    ),
  );
}

class FamilyFeastApp extends StatelessWidget {
  const FamilyFeastApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FamilyFeast',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routerConfig: appRouter.config(),
    );
  }
}
