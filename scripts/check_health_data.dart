import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:biciclistico/services/database_service.dart';
import 'package:biciclistico/models/planned_ride.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // We need Supabase initialized to run this, so we'll just run it as an integration test
  // Or better, let's just make an easy debug print in the app.
}
