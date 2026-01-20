import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration for Biciclistico app
/// 
/// IMPORTANT: Replace these values with your actual Supabase credentials
/// Get them from: https://app.supabase.com/project/_/settings/api
class SupabaseConfig {
  // TODO: Replace with your Supabase project URL
  static const String supabaseUrl = 'https://fiukytfosrjppbmnrlmp.supabase.co';
  
  // TODO: Replace with your Supabase public anon key
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpdWt5dGZvc3JqcHBibW5ybG1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4MjgwNDAsImV4cCI6MjA4NDQwNDA0MH0.5zoH3CnaE89PSalsBTKWChbaYgXaIDOkkv4Q9Bv1DTE';
  
  /// Initialize Supabase client
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }
  
  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Check if Supabase is properly configured
  static bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL_HERE' && 
           supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE';
  }
}
