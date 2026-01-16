import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biciclistico/screens/onboarding_screen.dart';
import 'package:biciclistico/screens/main_navigation_screen.dart';
import 'services/database_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
  
  final dbService = DatabaseService();
  await dbService.init();
  
  final profile = await dbService.getUserProfile();

  runApp(BiciclisticoApp(showOnboarding: profile == null));
}

class BiciclisticoApp extends StatelessWidget {
  final bool showOnboarding;
  const BiciclisticoApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biciclistico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('it', 'IT'),
      ],
      locale: const Locale('it', 'IT'),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system,
      home: showOnboarding ? const OnboardingScreen() : const MainNavigationScreen(),
    );
  }
}
