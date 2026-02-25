import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Providers
import 'providers/auth_provider.dart';
import 'services/culture_preference_service.dart';

// Screens
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CulturePreferenceService()),
      ],
      child: const JobHudApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash/Initial Route - Handles initial auth state check
    GoRoute(
      path: '/',
      builder: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        // This will be immediately replaced by the redirect
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = authProvider.isAuthenticated;
        
        // If user is logged in, go to dashboard
        if (isLoggedIn) {
          return '/dashboard';
        }
        // Otherwise, go to welcome screen
        return '/welcome';
      },
    ),
    // Welcome screen - only for unauthenticated users
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        return authProvider.isAuthenticated ? '/dashboard' : null;
      },
    ),
    // Login screen - only for unauthenticated users
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        return authProvider.isAuthenticated ? '/dashboard' : null;
      },
    ),
    // Signup screen - only for unauthenticated users
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        return authProvider.isAuthenticated ? '/dashboard' : null;
      },
    ),
    // Dashboard - only for authenticated users
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        return authProvider.isAuthenticated ? null : '/welcome';
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Error: ${state.error}'),
    ),
  ),
);

class JobHudApp extends StatefulWidget {
  const JobHudApp({super.key});

  @override
  State<JobHudApp> createState() => _JobHudAppState();
}

class _JobHudAppState extends State<JobHudApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'JobHUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6FA5),
          primary: const Color(0xFF4A6FA5),
          secondary: const Color(0xFF6B4E71),
          tertiary: const Color(0xFF6B8F71),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A6FA5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}