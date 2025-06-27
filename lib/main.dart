import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Environment loader
import 'package:houzy/repository/screens/bottomnav/bottomnavscreen.dart';
import 'firebase_options.dart';
import 'package:houzy/repository/splash/splashscreen.dart';
import 'package:houzy/repository/screens/login/loginscreen.dart';
import 'package:houzy/repository/screens/account/accountscreen.dart';

void main() async {
  // ✅ Ensure Flutter bindings before async code
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load .env and Stripe key setup
  await _setup();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Run app
  runApp(const MyApp());
}

Future<void> _setup() async {
  // ✅ Load environment variables from `.env` file
  await dotenv.load(fileName: ".env");

  // ✅ Assign Stripe publishable key
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  // ✅ Apply Stripe settings
  try {
    await Stripe.instance.applySettings();
  } catch (e) {
    print("Error initializing Stripe: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Houzy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: const Color(0xFFF54A00),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepOrange,
        ).copyWith(
          secondary: Colors.deepOrangeAccent,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => BottomNavScreen(),
        '/account': (context) => const AccountScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
