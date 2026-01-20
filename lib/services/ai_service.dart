import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/ai_provider.dart';
import '../models/planned_ride.dart';
import '../models/track.dart';
import '../services/database_service.dart';
import '../services/supabase_config.dart';
import 'package:intl/intl.dart';

/// Service for AI Coach functionality using Supabase Edge Functions (Butler AI via OpenRouter)
class AIService {
  final _db = DatabaseService();
  final _functions = Supabase.instance.client.functions;

  /// Check if AI is configured (User has a profile)
  Future<bool> isConfigured() async {
    final profile = await _db.getUserProfile();
    return profile != null;
  }

  /// Test connection to the AI Router
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final profile = await _db.getUserProfile();
      final provider = profile?.getAIProvider() ?? AIProvider.deepseek;

      final response = await _callAI(
        provider: provider,
        systemPrompt: 'You are a connection tester.',
        userMessage: 'Ping',
      );

      if (response['success']) {
        return {'success': true, 'message': 'Connessione AI riuscita!', 'response': response['content']};
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
    bool useHealthContext = true,
  }) async {
    final profile = await _db.getUserProfile();
    if (profile == null) {
      return {'success': false, 'error': 'Profilo non trovato'};
    }

    // Default to DeepSeek if not specified (conceptually, though function handles routing)
    final provider = profile.getAIProvider() ?? AIProvider.deepseek;

    final systemPrompt = await _buildSystemPrompt(profile, includeHealthData: useHealthContext);
    
    return await _callAI(
      provider: provider,
      systemPrompt: systemPrompt,
      userMessage: userQuestion,
    );
  }

  /// Analyze a planned ride and provide advice
  Future<String> analyzeRide(PlannedRide ride) async {
    final profile = await _db.getUserProfile();
    if (profile == null) return "Profilo utente non trovato.";

    final provider = profile.getAIProvider() ?? AIProvider.deepseek;
    
    // Build specialized prompt
    final prompt = StringBuffer();
    prompt.writeln('Sei "Il Biciclista" - un ciclista esperto e diretto che analizza i percorsi con occhio critico. Analizza questo percorso:');
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
    prompt.writeln('1. **Difficoltà Percepita**: Quanto sarà tosta per me oggi?');
    prompt.writeln('2. **Strategia**: Come affrontare il dislivello e la distanza?');
    prompt.writeln('3. **Consiglio Pratico**: Abbigliamento, nutrizione o ritmo.');
    prompt.writeln('Usa un tono diretto, simpatico e un po\' sarcastico. Parla come "Il Biciclista", un ciclista esperto che consiglia un amico. Rispondi in italiano con gergo ciclistico.');

    // Determine personality
    final personality = profile.coachPersonality ?? 'friendly';
    String systemPrompt = "Sei 'Il Biciclista', il tuo compagno di uscite esperto.";

    switch (personality) {
      case 'sergeant':
        systemPrompt = "Sei un SERGENTE ISTRUTTORE. Stai urlando nelle orecchie dell'atleta mentre pedala. DURO, DIRETTO, NIENTE SCUSE. Se il meteo è brutto, è MEGLIO (più gloria).";
        break;
      case 'zen':
        systemPrompt = "Sei un Maestro Zen. Guida l'atleta a trovare il flusso interiore. Il meteo e la fatica sono illusioni. Respira e pedala.";
        break;
      case 'analytical':
        systemPrompt = "Sei un Computer di Bordo Avanzato. Analizza meteo, HR e fatica. Fornisci strategie basate su percentuali e dati. Freddo e calcolatore.";
        break;
      case 'friendly':
      default:
        systemPrompt = "Sei 'Il Biciclista', un compagno esperto che pedala a fianco. Simpatico, incoraggiante, pratico. Se piove, fai una battuta.";
        break;
    }

    final result = await _callAI(
      provider: profile.getAIProvider() ?? AIProvider.deepseek,
      systemPrompt: systemPrompt,
      userMessage: prompt.toString(),
      action: 'analyze_ride',
      payloadExtras: {'ride_id': ride.id}, // Optional tracking
    );

    if (result['success']) {
      return result['content'];
    } else {
      return "Impossibile generare l'analisi: ${result['error']}";
    }
  }

  /// Analyze a timeless Track (Library)
  Future<String> analyzeTrack(Track track) async {
    final profile = await _db.getUserProfile();
    
    final prompt = StringBuffer();
    prompt.writeln('Sei "Il Biciclista". Analizza questa traccia salvata in libreria e dai consigli strategici su come affrontarla.');
    prompt.writeln();
    prompt.writeln('**Dati Traccia:**');
    prompt.writeln('- Nome: ${track.name}');
    prompt.writeln('- Distanza: ${track.distance.toStringAsFixed(1)} km');
    prompt.writeln('- Dislivello: ${track.elevation.toStringAsFixed(0)} m');
    prompt.writeln('- Terreno: ${track.terrainLabel}');
    
    // Check for upcoming planned rides for this track
    try {
      final upcomingRides = await _db.getUpcomingRides();
      final relatedRide = upcomingRides.where((r) => r.trackId == track.id).firstOrNull;
      
      if (relatedRide != null) {
        prompt.writeln();
        prompt.writeln('**CONTESTO IMPORTANTE: Questa traccia è pianificata per una uscita!**');
        prompt.writeln('- Data: ${DateFormat('dd MMMM yyyy, HH:mm').format(relatedRide.rideDate)}');
        prompt.writeln('- Tipo: ${relatedRide.isGroupRide ? "Uscita di Gruppo" : "Uscita in Solitaria"}');
        
        if (relatedRide.forecastWeather != null) {
          try {
            final weather = json.decode(relatedRide.forecastWeather!);
            prompt.writeln('- Meteo Previsto: Temp ${weather['temperature']}°C, Vento ${weather['windSpeed'] ?? '?'} km/h');
          } catch (_) {}
        }
        prompt.writeln('Tieni conto della DATA e del METEO (se presente) per dare consigli specifici.');
      }
    } catch (e) {
      print('Error fetching related rides: $e');
    }

    if (profile != null) {
      prompt.writeln();
      prompt.writeln('**Profilo Atleta (per contesto):**');
      prompt.writeln('- Peso: ${profile.weight}kg');
    }

    prompt.writeln();
    prompt.writeln('Fornisci un analisi strategica "senza tempo" (non conosci meteo o data). Concentrati su:');
    prompt.writeln('1. **Difficoltà Tecnica**: Cosa aspettarsi dal terreno.');
    prompt.writeln('2. **Gestione Sforzo**: Dove spingere e dove risparmiare gamba.');
    prompt.writeln('3. **Nutrizione Ideale**: Stima del fabbisogno.');
    prompt.writeln('Sii sempre simpatico e diretto.');

    // Determine personality
    final personality = profile?.coachPersonality ?? 'friendly';
    String systemPrompt = "Sei 'Il Biciclista', analizzi percorsi GPX con saggezza e ironia.";
    
    switch (personality) {
      case 'sergeant':
        systemPrompt = "Sei un SERGENTE ISTRUTTORE di ciclismo. Sei DURO, MOTIVANTE, non accetti scuse. Urla (MAIUSCOLO) i punti critici. Vuoi sudore e gloria.";
        break;
      case 'zen':
        systemPrompt = "Sei un Maestro Zen della bicicletta. Parla con calma, usa metafore sulla natura e il flusso. L'obiettivo è l'armonia, non la velocità.";
        break;
      case 'analytical':
        systemPrompt = "Sei un Ingegnere Olistico. Analizza solo i DATI. Sii freddo, preciso, focus su Watt/kg, pendenze ed efficienza. Niente chiacchiere.";
        break;
      case 'friendly':
      default:
        systemPrompt = "Sei 'Il Biciclista', un compagno di uscite esperto. Sei simpatico, ironico, usi slang ciclistico (gamba, scia, cappottarsi).";
        break;
    }

    final result = await _callAI(
      provider: profile?.getAIProvider() ?? AIProvider.deepseek,
      systemPrompt: systemPrompt,
      userMessage: prompt.toString(),
      action: 'analyze_track',
      payloadExtras: {'track_id': track.id},
    );

    if (result['success']) {
      return result['content'];
    } else {
      return "Analisi non disponibile: ${result['error']}";
    }
  }

  /// Call Edge Function (butler-ai-openrouter)
  Future<Map<String, dynamic>> _callAI({
    required AIProvider provider,
    required String systemPrompt,
    required String userMessage,
    String action = 'chat',
    Map<String, dynamic>? payloadExtras,
  }) async {
    try {
      final payload = {
        'messages': [
           {'role': 'system', 'content': systemPrompt},
           {'role': 'user', 'content': userMessage}
        ],
        ...(payloadExtras ?? {}),
      };

      try {
          // Attempt 1
          final stopwatch = Stopwatch()..start();
          
          final response = await _functions.invoke(
            'butler-ai-openrouter',
            body: {
              'messages': payload['messages'], 
            },
          );
          stopwatch.stop();

          // Log Success
          final result = _parseResponse(response);
          _logRequest(
            requestType: action,
            provider: provider,
            model: 'auto-router', // Edge function decides
            status: result['success'] ? 'success' : 'failure',
            durationMs: stopwatch.elapsedMilliseconds,
            errorMessage: result['error'],
          );
          
          return result;
          
      } on FunctionException catch (e) {
          // Check for 401 (Unauthorized) or similar
          if (e.status == 401 || (e.details != null && e.details.toString().contains('jwt'))) {
              print('AI Service: 401 Detected. Refreshing session...');
              try {
                  await Supabase.instance.client.auth.refreshSession();
                  print('AI Service: Session Refreshed. Retrying...');
                  
                  // Attempt 2 (Refreshed Session)
                  final response = await _functions.invoke(
                    'butler-ai-openrouter',
                    body: {
                      'messages': payload['messages'], 
                    },
                  );
                  return _parseResponse(response);
                  
              } catch (refreshErr) {
                  print('AI Service: Refresh failed. Attempting Fallback (Anon Key)...');
                  try {
                      // Attempt 3 (Fallback to Anon Key)
                      // We must explicitly set Authorization header to overwrite the (broken) user token
                      final response = await _functions.invoke(
                        'butler-ai-openrouter',
                        body: {
                          'messages': payload['messages'], 
                        },
                        headers: {
                          'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}',
                        },
                      );
                      return _parseResponse(response);
                  } catch (fallbackErr) {
                      print('Fallback error: $fallbackErr');
                      // User requested friendly local fallback if everything fails
                      return {
                        'success': true, 
                        'content': 'Il Butler è momentaneamente offline, controlla la tua connessione!'
                      };
                  }
              }
          }
          final details = e.details;
          // Also return friendly message here if it's not a 401 (which we tried to fix)
          return {
            'success': true, 
            'content': 'Il Butler è momentaneamente offline, controlla la tua connessione!'
          };
      }
    } catch (e) {
       print('AI Service Error: $e');
       
       // Log failure
       _logRequest(
         requestType: action,
         provider: provider,
         model: 'unknown',
         status: 'failure',
         errorMessage: e.toString(),
         durationMs: 0,
       );

       return {
         'success': true, 
         'content': 'Il Butler è momentaneamente offline, controlla la tua connessione!'
       };
    }
  }

  Future<void> _logRequest({
    required String requestType,
    required AIProvider provider,
    required String model,
    required String status,
    int? durationMs,
    int inputTokens = 0,
    int outputTokens = 0,
    String? errorMessage,
  }) async {
    try {
       final userId = Supabase.instance.client.auth.currentUser?.id;
       if (userId == null) return;

       // Use local logging if cloud fails? No, try cloud logger
       await Supabase.instance.client.from('ai_logs').insert({
         'user_id': userId,
         'request_type': requestType,
         'provider': provider.name,
         'model': model,
         'status': status,
         'duration_ms': durationMs,
         'input_tokens': inputTokens,
         'output_tokens': outputTokens,
         'error_message': errorMessage,
       }); // Fire and forget
    } catch (e) {
      print('Failed to log AI usage: $e');
    }
  }

  Map<String, dynamic> _parseResponse(FunctionResponse response) {
      final data = response.data;
      if (data != null && data['error'] != null) {
          return {'success': false, 'error': data['error']};
      }

      // 1. Try OpenAI/Standard format (choices -> message -> content)
      if (data != null && data['choices'] != null && (data['choices'] as List).isNotEmpty) {
         final firstChoice = data['choices'][0];
         if (firstChoice['message'] != null && firstChoice['message']['content'] != null) {
            return {
               'success': true, 
               'content': firstChoice['message']['content']
            };
         }
      }

      // 2. Try Simple format (Legacy/Direct)
      if (data != null && data['content'] != null) {
          return {
            'success': true, 
            'content': data['content'],
          };
      } 
      
      return {'success': false, 'error': 'Risposta vuota (Formato non riconosciuto)'};
  }


  /// Build system prompt (Helper)
  Future<String> _buildSystemPrompt(UserProfile profile, {bool includeHealthData = true}) async {
    final prompt = StringBuffer();
    
    prompt.writeln('Sei "Il Biciclista" - un ciclista navigato, esperto e un po\' sarcastico. Dai consigli pratici con un tono simpatico e diretto, usando gergo ciclistico italiano. Non essere troppo formale, parla come se stessi consigliando un amico al bar dopo un\'uscita. Analizza i seguenti dati e fornisci consigli utili ma con personalità:');
    prompt.writeln();

    if (includeHealthData) {
      prompt.writeln('**Dati Atleta:**');
      prompt.writeln('- Peso: ${profile.weight.toStringAsFixed(1)}kg');
      prompt.writeln('- HRV (Heart Rate Variability): ${profile.hrv}ms');
      prompt.writeln('- Sonno: ${profile.sleepHours.toStringAsFixed(1)} ore');
      
      final readiness = _calculateReadinessScore(profile);
      prompt.writeln('- Readiness Score: $readiness/100');
      prompt.writeln();

      // Dati Bici (Manutenzione)
      final bikes = await _db.getAllBicycles();
      if (bikes.isNotEmpty) {
        final bike = bikes.first; // Use primary/first bike
        prompt.writeln('**Bicicletta in Uso:**');
        prompt.writeln('- Modello: ${bike.name} (${bike.type})');
        prompt.writeln('- KM Totali: ${bike.totalKilometers.toStringAsFixed(1)} km');
        prompt.writeln('- Componenti:');
        for (var c in bike.components) {
          final usage = c.currentKm;
          final limit = c.limitKm;
          final status = usage > limit ? 'DA SOSTITUIRE ⚠️' : (usage > limit * 0.8 ? 'Attenzione ⚠️' : 'OK');
          prompt.writeln('  * ${c.name}: ${usage.toStringAsFixed(0)}/${limit.toStringAsFixed(0)} km [$status]');
        }
        prompt.writeln();
      }

      final upcomingRides = await _db.getUpcomingRides();
      if (upcomingRides.isNotEmpty) {
        final nextRide = upcomingRides.first;
        prompt.writeln('**Percorso Pianificato:**');
        if (nextRide.rideName != null && nextRide.rideName!.isNotEmpty) {
          prompt.writeln('- Nome: ${nextRide.rideName}');
        }
        prompt.writeln('- Distanza: ${nextRide.distance.toStringAsFixed(1)}km');
        prompt.writeln('- Dislivello: ${nextRide.elevation.toStringAsFixed(0)}m');
        
        if (nextRide.forecastWeather != null && nextRide.forecastWeather!.isNotEmpty) {
          try {
            final weatherData = json.decode(nextRide.forecastWeather!);
            prompt.writeln();
            prompt.writeln('**Condizioni Meteo Previste:**');
            prompt.writeln('- Temperatura: ${weatherData['temperature']}°C');
             if (weatherData['windSpeed'] != null) {
              prompt.writeln('- Vento: ${weatherData['windSpeed']}km/h');
            }
          } catch (e) {}
        }
      } else {
        prompt.writeln('**Percorso Pianificato:** Nessun percorso imminente.');
      }
    } else {
      prompt.writeln('**Modalità Meccanico/Tecnico:**');
      prompt.writeln('Ignora dati fisiologici. Concentrati solo sulla richiesta tecnica riguardo la biciletta.');
    }

    prompt.writeln();
    prompt.writeln('Fornisci consigli specifici e pratici. Sii conciso (max 150 parole) ma simpatico. Usa un tono colloquiale con gergo ciclistico italiano. Rispondi sempre in italiano come "Il Biciclista".');
    
    return prompt.toString();
  }

  int _calculateReadinessScore(UserProfile profile) {
    int score = 50;
    if (profile.hrv > 60) score += 20;
    else if (profile.hrv > 40) score += 10;
    else if (profile.hrv < 30) score -= 10;
    
    if (profile.sleepHours >= 7 && profile.sleepHours <= 9) score += 20;
    else if (profile.sleepHours >= 6) score += 10;
    else if (profile.sleepHours < 6) score -= 15;
    
    if (profile.weight > 0) score += 10;
    
    return score.clamp(0, 100);
  }

  /// Fetch available Gemini models from Google API
  Future<List<Map<String, String>>> getAvailableGeminiModels(String apiKey) async {
    if (apiKey.isEmpty) return [];
    
    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = (data['models'] as List).where((m) {
          final methods = (m['supportedGenerationMethods'] as List? ?? []).cast<String>();
          return methods.contains('generateContent');
        }).map<Map<String, String>>((m) {
          return {
            'id': (m['name'] as String).replaceFirst('models/', ''),
            'name': m['displayName'] as String,
          };
        }).toList();
        
        // Sort by version (newer first roughly) - Optional
        return models;
      }
      return [];
    } catch (e) {
      print('Error fetching Gemini models: $e');
      return [];
    }
  }
}
