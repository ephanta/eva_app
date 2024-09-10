import 'package:eva_app/provider/data_provider.dart';
import 'package:eva_app/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    print('.env Datei erfolgreich geladen');
  } catch (e) {
    print('Fehler beim Laden der .env Datei: $e');
  }

  await Supabase.initialize(
    url: dotenv.env['URL_ACCOUNT_A']!,
    anonKey: dotenv.env['ANON_KEY_ACCOUNT_A']!,
  );

  final supabase = Supabase.instance.client;

  // Fetch the current session and JWT token
  final session = Supabase.instance.client.auth.currentSession;
  final jwtToken = session?.accessToken;

  if (jwtToken != null) {
    print('JWT Token: $jwtToken');  // Print the JWT token to the console
  } else {
    print('No JWT token found. User may not be authenticated.');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DataProvider(supabase),
        ),
      ],
      child: const FamilyFeastApp(),
    ),
  );
}

class FamilyFeastApp extends StatefulWidget {
  const FamilyFeastApp({Key? key}) : super(key: key);

  @override
  _FamilyFeastAppState createState() => _FamilyFeastAppState();
}

class _FamilyFeastAppState extends State<FamilyFeastApp> {
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
      routerConfig: _appRouter.config(),
    );
  }
}
