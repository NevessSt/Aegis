import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/controllers/memory_provider.dart';
import 'core/controllers/premium_provider.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enforce biometric authentication before launching the app
  final LocalAuthentication auth = LocalAuthentication();
  bool authenticated = false;
  
  try {
    authenticated = await auth.authenticate(
      localizedReason: 'Scan your fingerprint (or face) to unlock Project Aegis',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
  } on PlatformException catch (e) {
    debugPrint('Biometric Error: \$e');
    // For development/sandbox, we bypass lock if biometrics fail or are unavailable
    authenticated = true; 
  }

  runApp(AegisApp(isAuthorized: authenticated));
}

class AegisApp extends StatelessWidget {
  final bool isAuthorized;

  const AegisApp({Key? key, required this.isAuthorized}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isAuthorized) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              'Aegis Access Denied',
              style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
      ],
      child: MaterialApp(
        title: 'Project Aegis',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A), // Premium Dark Slate
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF38BDF8),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
