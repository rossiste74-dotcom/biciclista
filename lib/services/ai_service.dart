import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/ai_provider.dart';
import '../models/planned_ride.dart';
import '../models/weather_conditions.dart';
import '../services/database_service.dart';

/// Service for AI Coach functionality using user's own API keys
class AIService {
  final _db = DatabaseService();

  /// Check if AI is configured (has provider and API key)
  Future<bool> isConfigured() async {
    final profile = await _db.getUserProfile();
    if (profile == null) return false;
    
    final provider = profile.getAIProvider();
    return provider != null && profile.aiApiKey != null && profile.aiApiKey!.trim().isNotEmpty;
  }

  /// Test connection to the configured AI provider
  Future<Map<String, dynamic>> testConnection() async {
    final profile = await _db.getUserProfile();
    if (profile == null) {
      return {'success': false, 'message': 'Profilo non trovato'};
    }

    final provider = profile.getAIProvider();
    final apiKey = profile.aiApiKey;

    if (provider == null || apiKey == null || apiKey.trim().isEmpty) {
      return {'success': false, 'message': 'Provider o API key non configurati'};
    }

    try {
      final response = await _callAI(
        provider: provider,
        apiKey: apiKey,
        systemPrompt: 'You are a helpful assistant.',
        userMessage: 'Say "Hello" in one word.',
      );

      if (response['success']) {
        return {'success': true, 'message': 'Connessione riuscita!', 'response': response['content']};
      } else {
        return {'success': false, 'message': response['error'] ?? 'Test fallito'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  /// Generate cycling advice based on user data
  Future<Map<String, dynamic>> getAdvice({
    required String userQuestion,
  }) async {
    final profile = await _db.getUserProfile();
    if (profile == null) {
      return {'success': false, 'error': 'Profilo non trovato'};
    }

    final provider = profile.getAIProvider();
    final apiKey = profile.aiApiKey;

    if (provider == null || apiKey == null || apiKey.trim().isEmpty) {
      return {'success': false, 'error': 'AI non configurata. Vai nelle impostazioni.'};
    }

    // Build comprehensive prompt with user data
    final systemPrompt = await _buildSystemPrompt(profile);
    
    try {
      return await _callAI(
        provider: provider,
        apiKey: apiKey,
        systemPrompt: systemPrompt,
        userMessage: userQuestion,
      );
    } catch (e) {
      return {'success': false, 'error': 'Errore: $e'};
    }
  }

  /// Build system prompt with user's biometric, weather, and ride data
  Future<String> _buildSystemPrompt(UserProfile profile) async {
    final prompt = StringBuffer();
    
    prompt.writeln('You are an expert cycling coach and meteorologist. Analyze the following data and provide concise, motivating advice in Italian:');
    prompt.writeln();
    prompt.writeln('**Dati Atleta:**');
    prompt.writeln('- Peso: ${profile.weight.toStringAsFixed(1)}kg');
    prompt.writeln('- HRV (Heart Rate Variability): ${profile.hrv}ms');
    prompt.writeln('- Sonno: ${profile.sleepHours.toStringAsFixed(1)} ore');
    
    // Calculate readiness score
    final readiness = _calculateReadinessScore(profile);
    prompt.writeln('- Readiness Score: $readiness/100');
    prompt.writeln();

    // Try to get next ride and weather
    final upcomingRides = await _db.getUpcomingRides();
    if (upcomingRides.isNotEmpty) {
      final nextRide = upcomingRides.first;
      prompt.writeln('**Percorso Pianificato:**');
      if (nextRide.rideName != null && nextRide.rideName!.isNotEmpty) {
        prompt.writeln('- Nome: ${nextRide.rideName}');
      }
      prompt.writeln('- Distanza: ${nextRide.distance.toStringAsFixed(1)}km');
      prompt.writeln('- Dislivello: ${nextRide.elevation.toStringAsFixed(0)}m');
      prompt.writeln('- Data: ${nextRide.rideDate.day}/${nextRide.rideDate.month}');
      
      // Add weather if available in forecast
      if (nextRide.forecastWeather != null && nextRide.forecastWeather!.isNotEmpty) {
        try {
          final weatherData = json.decode(nextRide.forecastWeather!);
          prompt.writeln();
          prompt.writeln('**Condizioni Meteo Previste:**');
          prompt.writeln('- Temperatura: ${weatherData['temperature']}°C');
          if (weatherData['windSpeed'] != null) {
            prompt.writeln('- Vento: ${weatherData['windSpeed']}km/h');
          }
          if (weatherData['humidity'] != null) {
            prompt.writeln('- Umidità: ${weatherData['humidity']}%');
          }
        } catch (e) {
          // Weather data parsing failed, skip
        }
      }
    } else {
      prompt.writeln('**Percorso Pianificato:** Nessun percorso imminente.');
    }

    prompt.writeln();
    prompt.writeln('Fornisci consigli specifici su intensità di allenamento, abbigliamento consigliato e motivazione. Sii conciso (max 150 parole) e motivante. Rispondi sempre in italiano.');
    
    return prompt.toString();
  }

  /// Analyze a planned ride and provide advice
  Future<String> analyzeRide(PlannedRide ride) async {
    final profile = await _db.getUserProfile();
    
    // Check configuration
    if (profile == null) return "Profilo utente non trovato.";
    final provider = profile.getAIProvider();
    final apiKey = profile.aiApiKey;
    if (provider == null || apiKey == null || apiKey.trim().isEmpty) {
      return "AI non configurata. Vai nelle impostazioni per attivare l'analista.";
    }

    // Build specialized prompt
    final prompt = StringBuffer();
    prompt.writeln('Sei un direttore sportivo e meteorologo esperto di ciclismo. Analizza questo percorso:');
    prompt.writeln();
    prompt.writeln('**Dati Percorso:**');
    prompt.writeln('- Distanza: ${ride.distance.toStringAsFixed(1)} km');
    prompt.writeln('- Dislivello: ${ride.elevation.toStringAsFixed(0)} m');
    prompt.writeln('- Data: ${ride.rideDate.day}/${ride.rideDate.month} ore ${ride.rideDate.hour}:${ride.rideDate.minute}');
    
    if (ride.forecastWeather != null) {
      try {
        final w = json.decode(ride.forecastWeather!);
        prompt.writeln('- Meteo previsto: ${w['temperature']}°C, Vento ${w['windSpeed']}km/h');
      } catch (_) {}
    }

    prompt.writeln();
    prompt.writeln('**Dati Ciclista:**');
    prompt.writeln('- Peso: ${profile.weight}kg');
    prompt.writeln('- HRV ultimi 7gg: ${profile.hrv} (Readiness: ${_calculateReadinessScore(profile)}/100)');

    prompt.writeln();
    prompt.writeln('Fornisci una breve analisi (max 150 parole) strutturata in:');
    prompt.writeln('1. **Difficoltà Percepita**: Quanto sarà dura per me oggi?');
    prompt.writeln('2. **Strategia**: Come affrontare il dislivello/distanza?');
    prompt.writeln('3. **Consiglio Pratico**: Abbigliamento o nutrizione.');
    prompt.writeln('Usa un tono professionale ma motivante. Rispondi in italiano.');

    try {
      final result = await _callAI(
        provider: provider,
        apiKey: apiKey,
        systemPrompt: "Sei un coach di ciclismo esperto. Sii conciso, preciso e utile.",
        userMessage: prompt.toString(),
      );

      if (result['success']) {
        return result['content'];
      } else {
        return "Impossibile generare l'analisi: ${result['error']}";
      }
    } catch (e) {
      return "Errore durante l'analisi: $e";
    }
  }

  /// Calculate readiness score from profile data
  int _calculateReadinessScore(UserProfile profile) {
    int score = 50; // Base score
    
    // HRV contribution (higher is better, typical range 30-100ms)
    if (profile.hrv > 60) {
      score += 20;
    } else if (profile.hrv > 40) {
      score += 10;
    } else if (profile.hrv < 30) {
      score -= 10;
    }
    
    // Sleep contribution (7-9 hours is optimal)
    if (profile.sleepHours >= 7 && profile.sleepHours <= 9) {
      score += 20;
    } else if (profile.sleepHours >= 6) {
      score += 10;
    } else if (profile.sleepHours < 6) {
      score -= 15;
    }
    
    // Weight stability (simplified - could track changes over time)
    if (profile.weight > 0) {
      score += 10;
    }
    
    return score.clamp(0, 100);
  }

  /// Call AI provider API
  Future<Map<String, dynamic>> _callAI({
    required AIProvider provider,
    required String apiKey,
    required String systemPrompt,
    required String userMessage,
  }) async {
    final profile = await _db.getUserProfile();
    final model = profile?.aiModel;
    
    switch (provider) {
      case AIProvider.openai:
        return await _callOpenAI(apiKey, systemPrompt, userMessage, model);
      case AIProvider.claude:
        return await _callClaude(apiKey, systemPrompt, userMessage, model);
      case AIProvider.gemini:
        return await _callGemini(apiKey, systemPrompt, userMessage, model);
    }
  }

  /// Call OpenAI API
  Future<Map<String, dynamic>> _callOpenAI(String apiKey, String systemPrompt, String userMessage, String? model) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': model ?? 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
        'max_tokens': 4096,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 429) {
      return {'success': false, 'error': 'Limite richieste OpenAI raggiunto. Riprova più tardi.'};
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['choices'][0]['message']['content'];
      return {'success': true, 'content': content};
    } else {
      final error = json.decode(response.body);
      return {'success': false, 'error': error['error']['message'] ?? 'Errore sconosciuto'};
    }
  }

  /// Call Claude API
  Future<Map<String, dynamic>> _callClaude(String apiKey, String systemPrompt, String userMessage, String? model) async {
    final url = Uri.parse('https://api.anthropic.com/v1/messages');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: json.encode({
        'model': model ?? 'claude-3-5-sonnet-20241022',
        'max_tokens': 4096,
        'system': systemPrompt,
        'messages': [
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode == 429) {
      return {'success': false, 'error': 'Limite richieste Claude raggiunto. Riprova più tardi.'};
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['content'][0]['text'];
      return {'success': true, 'content': content};
    } else {
      final error = json.decode(response.body);
      return {'success': false, 'error': error['error']['message'] ?? 'Errore sconosciuto'};
    }
  }

  /// Call Gemini API  
  Future<Map<String, dynamic>> _callGemini(String apiKey, String systemPrompt, String userMessage, String? model) async {
    // Default to gemini-2.5-flash if not specified
    final modelId = model != null && model.isNotEmpty ? model : 'gemini-2.5-flash';
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1/models/$modelId:generateContent?key=$apiKey');
    
    // Combine system prompt and user message for Gemini
    final fullPrompt = '$systemPrompt\n\n**Domanda dell\'utente:** $userMessage';
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'contents': [{
          'parts': [{'text': fullPrompt}]
        }],
        'generationConfig': {
          'maxOutputTokens': 8192,
          'temperature': 0.7,
        },
      }),
    );

    if (response.statusCode == 429) {
      return {'success': false, 'error': 'Limite giornaliero Gemini raggiunto (Quota Exceeded). Riprova domani o cambia modello nelle impostazioni.'};
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['candidates'][0]['content']['parts'][0]['text'];
      return {'success': true, 'content': content};
    } else {
      final error = json.decode(response.body);
      return {'success': false, 'error': error['error']['message'] ?? 'Errore sconosciuto'};
    }
  }

  /// Fetch available models from Gemini API
  Future<List<Map<String, String>>> getAvailableGeminiModels(String apiKey) async {
    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1/models?key=$apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> models = data['models'];
        
        return models
            .where((m) {
              // Filter for generateContent supported models
              final supportedMethods = List<String>.from(m['supportedGenerationMethods'] ?? []);
              return supportedMethods.contains('generateContent');
            })
            .map<Map<String, String>>((m) {
              String name = m['name'].toString(); // e.g. "models/gemini-pro"
              if (name.startsWith('models/')) {
                name = name.replaceAll('models/', '');
              }
              return {
                'id': name,
                'name': m['displayName'] ?? name,
              };
            }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching models: $e');
      return [];
    }
  }
}
