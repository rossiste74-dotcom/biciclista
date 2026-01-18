import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Artificial delay to ensure logo visibility and prevent flash
    // Also allows the engine to settle.
    await Future.delayed(const Duration(milliseconds: 1500)); 

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
      // Fallback or Error Screen could go here. 
      // For now, try to go to onboarding if DB fails
      if (mounted) {
         Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // App Icon or Logo
             Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Colors.white,
                 shape: BoxShape.circle,
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.2),
                     blurRadius: 10,
                     offset: const Offset(0, 5)
                   )
                 ]
               ),
               child: const Icon(
                 Icons.directions_bike,
                 size: 64,
                 color: Colors.blue,
               ),
             ),
             const SizedBox(height: 24),
             Text(
               'Biciclista',
               style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                 color: Colors.white,
                 fontWeight: FontWeight.bold,
               ),
             ),
             const SizedBox(height: 8),
             Text(
               'Il tuo assistente smart',
               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                 color: Colors.white70,
               ),
             ),
             const SizedBox(height: 48),
             const CircularProgressIndicator(
               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
             )
          ],
        ),
      ),
    );
  }
}
