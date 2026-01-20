import 'package:flutter/material.dart';
import 'dart:math';

import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'main_navigation_screen.dart';
import 'onboarding_screen.dart';

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
    // 3 seconds delay as requested
    await Future.delayed(const Duration(seconds: 3)); 

    try {
      final dbService = DatabaseService();
      await dbService.init();

      final notificationService = NotificationService();
      await notificationService.init();

      final profile = await dbService.getUserProfile();
      
      if (!mounted) return;

      if (profile == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      debugPrint('Initialization Error: $e');
      if (mounted) {
         Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
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
