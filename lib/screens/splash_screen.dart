import "package:biciclistico/screens/auth_screen.dart";
import 'package:flutter/material.dart';
import 'dart:math';

import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/configuration_service.dart';
import 'main_navigation_screen.dart';
import 'onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _quotes = [
    "Dopo la curva spiana",
    "Mo te levo er KOM",
    "Pedalo e non mollo",
    "In discesa tutti fenomeni",
    "Alle 8 alla casetta dell'acqua",
    "W la fuga",
    "Chi ha fatto la traccia?",
  ];

  late String _randomQuote;

  @override
  void initState() {
    super.initState();
    _randomQuote = _quotes[Random().nextInt(_quotes.length)];
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 3 seconds delay as requested (or maybe less now?)
    await Future.delayed(const Duration(seconds: 2)); 

    try {
      final dbService = DatabaseService();
      await dbService.init();

      final notificationService = NotificationService();
      await notificationService.init();

      // Initialize Remote Configuration
      await ConfigurationService().initialize();

      if (!mounted) return;

      // 1. Check Supabase Session
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session == null) {
        // No session -> Auth Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      } else {
        // Has session -> Check if profile exists in Cloud (or Sync)
        // ideally we sync here or just proceed.
        // For now, let's assume if logged in, he might need to onboard if profile missing.
        
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
           final profile = await dbService.getUserProfile(); // Check local cache first?
           // OR Check Cloud
           // Let's check Cloud availability to be "Cloud First"
           try {
             final data = await Supabase.instance.client
                .from('profiles')
                .select()
                .eq('user_id', user.id)
                .maybeSingle();
                
             if (data == null) {
                // Logged in but no profile data? -> Onboarding
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                );
             } else {
                // Profile exists -> Main App
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                );
             }
           } catch (e) {
             // Offline or error -> Fallback to local profile check if "Offline Buffer" is desired
             final localProfile = await dbService.getUserProfile();
             if (localProfile != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                );
             } else {
                // No local, no cloud access -> Maybe AuthScreen again or Error?
                // If offline and no session token preserved, Supabase SDK usually handles persistence.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Offline e nessun dato locale.')));
                // Retry?
             }
           }
        }
      }
    } catch (e) {
      debugPrint('Initialization Error: $e');
      if (mounted) {
         // Fallback to Auth
         Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double logoSize = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // App background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // Pop-out Logo Container
             Container(
               padding: const EdgeInsets.all(24),
               width: logoSize,
               height: logoSize,
               child: Image.asset(
                   'assets/log1.png',
                   fit: BoxFit.contain,
               ),
             ),
             const SizedBox(height: 40),
              
             // Random Funny Quote
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 32),
               child: Text(
                 '"$_randomQuote"',
                 textAlign: TextAlign.center,
                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                   fontSize: 24,
                   fontStyle: FontStyle.italic,
                   color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                 ),
               ),
             ),
             

             
             const SizedBox(height: 60),
             const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
