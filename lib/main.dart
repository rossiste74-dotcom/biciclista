import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biciclistico/screens/splash_screen.dart'; // Import SplashScreen
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  // minimal binding
  WidgetsFlutterBinding.ensureInitialized();
  // Date formatting can be awaited here or in splash, but usually fast enough.
  // We'll keep it here but without awaiting DB/Services.
  initializeDateFormatting('it_IT', null).then((_) {
     runApp(const BiciclisticoApp());
  });
}

class BiciclisticoApp extends StatelessWidget {
  const BiciclisticoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'biciclistico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: GoogleFonts.kiteOne(fontSize: 57),
          displayMedium: GoogleFonts.kiteOne(fontSize: 45),
          displaySmall: GoogleFonts.kiteOne(fontSize: 36),
          headlineLarge: GoogleFonts.kiteOne(fontSize: 32),
          headlineMedium: GoogleFonts.kiteOne(fontSize: 28),
          headlineSmall: GoogleFonts.kiteOne(fontSize: 24),
        ),
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
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: GoogleFonts.kiteOne(fontSize: 57),
          displayMedium: GoogleFonts.kiteOne(fontSize: 45),
          displaySmall: GoogleFonts.kiteOne(fontSize: 36),
          headlineLarge: GoogleFonts.kiteOne(fontSize: 32),
          headlineMedium: GoogleFonts.kiteOne(fontSize: 28),
          headlineSmall: GoogleFonts.kiteOne(fontSize: 24),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(), // Start with Splash
    );
  }
}
