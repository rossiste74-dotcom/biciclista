import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/supabase_config.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_translation_loader.dart';

void main() async {
  // minimal binding
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  // Initialize Supabase if configured
  if (SupabaseConfig.isConfigured) {
    try {
      await SupabaseConfig.initialize();
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  }
  
  // Date formatting can be awaited here or in splash, but usually fast enough.
  // We'll keep it here but without awaiting DB/Services.
  initializeDateFormatting('it_IT', null).then((_) {
     runApp(
       EasyLocalization(
         supportedLocales: const [Locale('it')],
         path: 'assets/translations', // Used by base loader, also passed to custom
         assetLoader: const SupabaseTranslationLoader(),
         fallbackLocale: const Locale('it'),
         child: const BiciclisticoApp(),
       ),
     );
  });
}

class BiciclisticoApp extends StatelessWidget {
  const BiciclisticoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biciclistico',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
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
