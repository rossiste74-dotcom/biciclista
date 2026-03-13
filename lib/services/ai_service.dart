import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/ai_provider.dart';
import '../models/planned_ride.dart';
import '../models/track.dart';
import '../models/ai_config.dart';
import '../services/database_service.dart';
import '../services/prompt_service.dart';
import '../services/supabase_config.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/biomechanics_analysis.dart';
import '../models/comic_prompts.dart';
/// Service for AI Coach functionality using Supabase Edge Functions (Butler AI via OpenRouter)
class AIService {
  final _db = DatabaseService();
  final _promptService = PromptService();
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
    // 1. Check Daily Limit
    final canProceed = await _checkDailyLimit();
    if (!canProceed) {
      return {
        'success': false, 
        'error': 'Limite giornaliero raggiunto. Torna domani, gamba o non gamba.'
      };
    }

    final profile = await _db.getUserProfile();
    if (profile == null) {
      return {'success': false, 'error': 'Profilo non trovato'};
    }

    // Default to DeepSeek if not specified
    final provider = profile.getAIProvider() ?? AIProvider.deepseek;

    final systemPrompt = await _buildSystemPrompt(profile, includeHealthData: useHealthContext);
    
    final result = await _callAI(
      provider: provider,
      systemPrompt: systemPrompt,
      userMessage: userQuestion,
    );

    // 2. Increment count on success
    if (result['success']) {
      await _incrementDailyCount();
    }
    
    return result;
  }

  // --- Rate Limiting Helpers ---

  static const int _dailyLimit = 10;

  Future<bool> _checkDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDailyKey();
    final count = prefs.getInt(key) ?? 0;
    return count < _dailyLimit;
  }

  Future<void> _incrementDailyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDailyKey();
    final count = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, count + 1);
  }

  Future<int> getRemainingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDailyKey();
    final count = prefs.getInt(key) ?? 0;
    return (_dailyLimit - count).clamp(0, _dailyLimit);
  }

  String _getDailyKey() {
    final now = DateTime.now();
    return 'ai_requests_${now.year}_${now.month}_${now.day}';
  }

  /// Analyze a planned ride and provide advice
  Future<String> analyzeRide(PlannedRide ride) async {
    final profile = await _db.getUserProfile();
    if (profile == null) return "Profilo utente non trovato.";

    final provider = profile.getAIProvider() ?? AIProvider.deepseek;
    
    // Build specialized prompt
    // Prepare data for interpolation
    String weatherInfo = '';
    if (ride.forecastWeather != null) {
      try {
        final w = json.decode(ride.forecastWeather!);
        weatherInfo = '- Meteo previsto: ${w['temperature']}°C, Vento ${w['windSpeed']}km/h';
      } catch (_) {}
    }

    final userMessage = await _promptService.getPrompt(AIConfig.keyAnalyzeRide, {
      'distance': ride.distance.toStringAsFixed(1),
      'elevation': ride.elevation.toStringAsFixed(0),
      'date': '${ride.rideDate.day}/${ride.rideDate.month} ore ${ride.rideDate.hour}:${ride.rideDate.minute}',
      'weather': weatherInfo,
      'weight': profile.weight,
      'hrv': profile.hrv,
      'readiness': _calculateReadinessScore(profile),
    });

    // Determine personality prompt
    final personality = profile.coachPersonality ?? 'friendly';
    String personaKey = AIConfig.keyPersonaFriendly;
    switch (personality) {
      case 'sergeant': personaKey = AIConfig.keyPersonaSergeant; break;
      case 'zen': personaKey = AIConfig.keyPersonaZen; break;
      case 'analytical': personaKey = AIConfig.keyPersonaAnalytical; break;
    }
    final systemPrompt = await _promptService.getPrompt(personaKey);

    final result = await _callAI(
      provider: profile.getAIProvider() ?? AIProvider.deepseek,
      systemPrompt: systemPrompt,
      userMessage: userMessage,
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
    
    String relatedRideContext = '';
    // Check for upcoming planned rides for this track
    try {
      final upcomingRides = await _db.getUpcomingRides();
      final relatedRide = upcomingRides.where((r) => r.trackId == track.id).firstOrNull;
      
      if (relatedRide != null) {
        final sb = StringBuffer();
        sb.writeln('**CONTESTO IMPORTANTE: Questa traccia è pianificata per una uscita!**');
        sb.writeln('- Data: ${DateFormat('dd MMMM yyyy, HH:mm').format(relatedRide.rideDate)}');
        sb.writeln('- Tipo: ${relatedRide.isGroupRide ? "Uscita di Gruppo" : "Uscita in Solitaria"}');
        
        if (relatedRide.forecastWeather != null) {
          try {
            final weather = json.decode(relatedRide.forecastWeather!);
            sb.writeln('- Meteo Previsto: Temp ${weather['temperature']}°C, Vento ${weather['windSpeed'] ?? '?'} km/h');
          } catch (_) {}
        }
        sb.writeln('Tieni conto della DATA e del METEO (se presente) per dare consigli specifici.');
        relatedRideContext = sb.toString();
      }
    } catch (e) {
      print('Error fetching related rides: $e');
    }

    String profileContext = '';
    if (profile != null) {
      profileContext = '**Profilo Atleta (per contesto):**\n- Peso: ${profile.weight}kg';
    }

    final userMessage = await _promptService.getPrompt(AIConfig.keyAnalyzeTrack, {
      'name': track.name,
      'distance': track.distance.toStringAsFixed(1),
      'elevation': track.elevation.toStringAsFixed(0),
      'terrain': track.terrainLabel,
      'related_ride_context': relatedRideContext,
      'profile_context': profileContext,
    });

    // Determine personality prompt
    final personality = profile?.coachPersonality ?? 'friendly';
    String personaKey = AIConfig.keyPersonaFriendly;
    switch (personality) {
      case 'sergeant': personaKey = AIConfig.keyPersonaSergeant; break;
      case 'zen': personaKey = AIConfig.keyPersonaZen; break;
      case 'analytical': personaKey = AIConfig.keyPersonaAnalytical; break;
    }
    final systemPrompt = await _promptService.getPrompt(personaKey);

    final result = await _callAI(
      provider: profile?.getAIProvider() ?? AIProvider.deepseek,
      systemPrompt: systemPrompt,
      userMessage: userMessage,
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
    final userData = StringBuffer();
    final bikeData = StringBuffer();
    final upcomingRide = StringBuffer();

    if (includeHealthData) {
      userData.writeln('**Dati Atleta:**');
      userData.writeln('- Peso: ${profile.weight.toStringAsFixed(1)}kg');
      userData.writeln('- HRV (Heart Rate Variability): ${profile.hrv}ms');
      userData.writeln('- Sonno: ${profile.sleepHours.toStringAsFixed(1)} ore');
      
      final readiness = _calculateReadinessScore(profile);
      userData.writeln('- Readiness Score: $readiness/100');

      // Ruolo
      userData.writeln('\n**Ruolo Utente:** ${profile.role.name}');
      if (profile.role == UserRole.presidente) {
         userData.writeln('ISTRUZIONE CRITICA: Rivolgiti all\'utente chiamandolo ESCLUSIVAMENTE "Signor Presidente" o "Sua Eccellenza". Mostrati estremamente deferente, servizievole e lusinghiero ("I ragazzi sono pronti per lei"). Puoi includere del leggero sarcasmo britannico se lo ritieni opportuno.');
      } else if (profile.role == UserRole.capitano) {
         userData.writeln('ISTRUZIONE CRITICA: Rivolgiti all\'utente come "Capitano". Usa un tono rispettoso ma cameratesco, tattico e motivazionale.');
      } else {
         userData.writeln('ISTRUZIONE CRITICA: L\'utente è un "Gregario" (livello base). Rivolgiti a lui chiamandolo "Gregario". Usa un tono severo, prendendolo in giro in modo sarcastico sulle sue prestazioni ("Vedi di non farti staccare anche stavolta", "Meno scuse, pedala!").');
      }

      // Dati Bici (Manutenzione)
      final bikes = await _db.getAllBicycles();
      if (bikes.isNotEmpty) {
        final bike = bikes.first; // Use primary/first bike
        bikeData.writeln('**Bicicletta in Uso:**');
        bikeData.writeln('- Modello: ${bike.name} (${bike.type})');
        bikeData.writeln('- KM Totali: ${bike.totalKilometers.toStringAsFixed(1)} km');
        bikeData.writeln('- Componenti:');
        for (var c in bike.components) {
          final usage = c.currentKm;
          final limit = c.limitKm;
          final status = usage > limit ? 'DA SOSTITUIRE ⚠️' : (usage > limit * 0.8 ? 'Attenzione ⚠️' : 'OK');
          bikeData.writeln('  * ${c.name}: ${usage.toStringAsFixed(0)}/${limit.toStringAsFixed(0)} km [$status]');
        }
      }

      final upcomingRides = await _db.getUpcomingRides();
      if (upcomingRides.isNotEmpty) {
        final nextRide = upcomingRides.first;
        upcomingRide.writeln('**Percorso Pianificato:**');
        if (nextRide.rideName != null && nextRide.rideName!.isNotEmpty) {
          upcomingRide.writeln('- Nome: ${nextRide.rideName}');
        }
        upcomingRide.writeln('- Distanza: ${nextRide.distance.toStringAsFixed(1)}km');
        upcomingRide.writeln('- Dislivello: ${nextRide.elevation.toStringAsFixed(0)}m');
        
        if (nextRide.forecastWeather != null && nextRide.forecastWeather!.isNotEmpty) {
          try {
            final weatherData = json.decode(nextRide.forecastWeather!);
            upcomingRide.writeln();
            upcomingRide.writeln('**Condizioni Meteo Previste:**');
            upcomingRide.writeln('- Temperatura: ${weatherData['temperature']}°C');
             if (weatherData['windSpeed'] != null) {
              upcomingRide.writeln('- Vento: ${weatherData['windSpeed']}km/h');
            }
          } catch (e) {}
        }
      } else {
        upcomingRide.writeln('**Percorso Pianificato:** Nessun percorso imminente.');
      }
    } else {
      userData.writeln('**Modalità Meccanico/Tecnico:**');
      userData.writeln('Ignora dati fisiologici. Concentrati solo sulla richiesta tecnica riguardo la biciletta.');
    }

    // Determine personality prompt
    final personality = profile.coachPersonality ?? 'friendly';
    String personaKey = AIConfig.keyPersonaFriendly;
    switch (personality) {
      case 'sergeant': personaKey = AIConfig.keyPersonaSergeant; break;
      case 'zen': personaKey = AIConfig.keyPersonaZen; break;
      case 'analytical': personaKey = AIConfig.keyPersonaAnalytical; break;
    }
    // We append the personal data to the persona, or use a base coach prompt?
    // Let's use base_coach as the main template
    return _promptService.getPrompt(AIConfig.keyBaseCoach, {
      'user_data': userData.toString(),
      'bike_data': bikeData.toString(),
      'upcoming_ride': upcomingRide.toString(),
    });
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
  /// Get Daily Wisdom for Community (Lazy Generation)
  Future<String> getOrGenerateDailyWisdom() async {
    final now = DateTime.now();
    
    // 1. Check DB
    final cached = await _db.getDailyWisdom(now);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // 2. If missing, Generate
    final profile = await _db.getUserProfile();
    final provider = profile?.getAIProvider() ?? AIProvider.deepseek;
    
    // We use community_motivation key as requested
    final systemPrompt = await _promptService.getPrompt(AIConfig.keyCommunityMotivation, {
      'dati_aggregati_crew': 'Attività in calo del 20% questa settimana. Meteo buono nel weekend.' // Placeholder logic
    });
    
    // Provide some minimal context if needed (e.g. day of week)
    final dayName = DateFormat('EEEE', 'it_IT').format(now);
    final userMessage = "Oggi è $dayName. Genera il messaggio.";

    final result = await _callAI(
      provider: provider,
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      action: 'daily_wisdom',
    );

    if (result['success']) {
      final content = result['content'] as String;
      // 3. Save to DB
      await _db.saveDailyWisdom(now, content);
      return content;
    } else {
      // Fallback
      return "Oggi niente perle di saggezza. Il server è in fuga solitaria.";
    }
  }
  /// Get Daily Comic Strip paths based on community stats (3 panels story)
  Future<List<String>> getDailyComicPaths() async {
    try {
      final activityLevel = await getCommunityActivityLevel();
      
      // We expect 3 panels for each level: comic_{level}_1.png, comic_{level}_2.png, comic_{level}_3.png
      // For now, we use the single existing static image if the numbered ones aren't available
      // but we prepare the list for the multi-page widget.
      switch (activityLevel) {
        case 'lazy':
          return [
            'assets/comics/comic_lazy.png',
            'assets/comics/comic_lazy.png',
            'assets/comics/comic_lazy.png',
          ];
        case 'pro':
          return [
            'assets/comics/comic_pro.png',
            'assets/comics/comic_pro.png',
            'assets/comics/comic_pro.png',
          ];
        default:
          return [
            'assets/comics/story_1.png',
            'assets/comics/story_2.png',
            'assets/comics/story_3.png',
          ];
      }
    } catch (e) {
      print('[AIService] Error selecting daily comic paths: $e');
      return ['assets/comics/comic_avg.png'];
    }
  }

  /// Determine community activity level from Supabase
  Future<String> getCommunityActivityLevel() async {
    try {
      // Milan coordinates as default center for community stats
      const lat = 45.4642; 
      const lon = 9.1900;
      const radiusKm = 50.0;

      final dynamic response = await Supabase.instance.client.rpc('get_community_stats', params: {
        'lat': lat,
        'lon': lon,
        'radius_km': radiusKm,
      });

      if (response != null && response is Map) {
        final avgKm = (response['avg_km'] as num?)?.toDouble() ?? 0.0;
        final activeUsers = (response['active_users'] as num?)?.toInt() ?? 0;
        
        print('[AIService] Community: avg_km=$avgKm, active_users=$activeUsers');

        if (activeUsers < 2 || avgKm < 20) {
          return 'lazy';
        } else if (avgKm > 60) {
          return 'pro';
        }
      }
      return 'avg';
    } catch (e) {
      print('[AIService] Warning: Falling back to "avg" for comics. Error: $e');
      return 'avg';
    }
  }

  /// Generate a dynamic comic scenario based on community performance
  Future<String> generateDailyComicScenario() async {
    try {
      final level = await getCommunityActivityLevel();
      
      // Milan coordinates as default center for community stats
      const lat = 45.4642; 
      const lon = 9.1900;
      const radiusKm = 50.0;

      final stats = await Supabase.instance.client.rpc('get_community_stats', params: {
        'lat': lat,
        'lon': lon,
        'radius_km': radiusKm,
      });

      final statsStr = stats != null 
          ? "Media Km: ${stats['avg_km']}, Utenti Attivi: ${stats['active_users']}, Bici Prevalente: ${stats['popular_type']}"
          : "Statistiche non disponibili.";

      final systemPrompt = '''
Sei un autore di fumetti specializzato in ciclismo amatoriale italiano. 
Il tuo compito è scrivere la sceneggiatura per la striscia quotidiana "ANONIMA CICLISTI".

REGOLE STILISTICHE:
${ComicPrompts.graphicalStyle}

PERSONAGGI:
${ComicPrompts.characterBase}

DATI ATTUALI DELLA COMMUNITY:
$statsStr
Livello Attività rilevato: $level

ISTRUZIONI:
Genera una STORIA COMPLETA divisa in 3 IMMAGINI (PANNELLI).
Ogni immagine DEVE contenere ESATTAMENTE 3 VIGNETTE (totale 9 vignette per la storia).
Il tono deve essere sarcastico, pungente ma affettuoso verso il mondo del ciclismo MTB. 
Includi sempre una punchline comica nel pannello finale.

Formatta l'output in modo chiaro:
TITOLO STORIA: [Titolo della giornata]

IMMAGINE 1: [Descrizione visiva generale]
- Vignetta 1: [Descrizione] - Dialogo: "..."
- Vignetta 2: [Descrizione] - Dialogo: "..."
- Vignetta 3: [Descrizione] - Dialogo: "..."

IMMAGINE 2: [Descrizione visiva generale]
- Vignetta 1: [Descrizione] - Dialogo: "..."
... e così via per la IMMAGINE 3.
''';

      final response = await Supabase.instance.client.functions.invoke(
        'butler-ai-openrouter',
        body: {
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'Genera la striscia di oggi basandoti sulla performance della crew.'}
          ],
        },
      );

      final data = response.data;
      if (data != null && data['choices'] != null && (data['choices'] as List).isNotEmpty) {
        return data['choices'][0]['message']['content'];
      }
      return "Impossibile generare la storia oggi. Il disegnatore è andato a scalare lo Stelvio.";
    } catch (e) {
      print('[AIService] Error generating comic scenario: $e');
      return "Errore nella generazione della striscia.";
    }
  }
  /// Analyze biomechanics from multiple images and generate verdict
  Future<Map<String, dynamic>> analyzeBiomechanicsFromImages(List<File> imageFiles) async {
    final profile = await _db.getUserProfile();
    final provider = profile?.getAIProvider() ?? AIProvider.deepseek;

    // Step 1: Get structured biomechanics data (JSON)
    final analysisResult = await _callAIWithMultiImages(
      provider: provider,
      systemPrompt: await _promptService.getPrompt(AIConfig.keyBiomechanicsEngine),
      userMessage: '''
Analyze these cycling posture images and return biomechanics data as JSON.
The images provided include:
1. Lateral view with leg extended (Required)
2. Lateral view with foot at 3 o'clock (Optional)
3. Frontal or Posterior view (Optional)
Use all available visual information to calibrate the measurements.
''',
      imageFiles: imageFiles,
      action: 'biomechanics_analysis',
    );

    if (!analysisResult['success']) {
      return {'success': false, 'error': analysisResult['error']};
    }

    // Parse JSON response
    BiomechanicsAnalysis? analysis;
    try {
      final content = analysisResult['content'];
      // Extract JSON if wrapped in markdown code blocks
      final jsonString = content.replaceAll(RegExp(r'^```json\n|\n```$'), '').trim();
      
      final jsonData = json.decode(jsonString);
      analysis = BiomechanicsAnalysis.fromJson(jsonData);
    } catch (e) {
      print('JSON Parse Error: $e');
      return {'success': false, 'error': 'Failed to parse biomechanics data: $e'};
    }

    // Check image quality
    if (analysis.metadata.imageQualityScore < 0.5) {
      return {
        'success': false,
        'error': 'Foto non utilizzabile. ${analysis.metadata.validationErrors.join(", ")}',
        'validation_errors': analysis.metadata.validationErrors,
      };
    }

    // Step 2: Generate professional verdict with final joke
    final verdictPrompt = await _promptService.getPrompt(
      AIConfig.keyBiciclistaVerdetto,
      {'biometrics_json': json.encode(analysis.biometrics.toJson())}
    );

    final verdictResult = await _callAI(
      provider: provider,
      systemPrompt: verdictPrompt,
      userMessage: 'Generate the professional verdict.',
      action: 'biomechanics_verdict',
    );

    final finalAnalysis = BiomechanicsAnalysis(
      metadata: analysis.metadata,
      biometrics: analysis.biometrics,
      recommendations: analysis.recommendations,
      visualOverlay: analysis.visualOverlay,
      verdict: verdictResult['success'] ? verdictResult['content'] : 'Il meccanico è uscito a fumare.',
      createdAt: DateTime.now(),
    );

    // Save to DB
    await _db.saveBiomechanicsAnalysis(finalAnalysis);

    return {
      'success': true,
      'analysis': finalAnalysis,
      'verdict': finalAnalysis.verdict,
    };
  }

  /// Helper: Call AI with multiple images (uses Gemini vision via Edge Function)
  Future<Map<String, dynamic>> _callAIWithMultiImages({
    required AIProvider provider,
    required String systemPrompt,
    required String userMessage,
    required List<File> imageFiles,
    String action = 'vision',
  }) async {
    try {
      final List<String> base64Images = [];
      for (var file in imageFiles) {
        final bytes = await file.readAsBytes();
        base64Images.add(base64Encode(bytes));
      }
      
      final payload = {
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {
            'role': 'user', 
            'content': userMessage,
            'images': base64Images
          }
        ],
        'action': action,
      };

      final response = await _functions.invoke(
        'butler-ai-openrouter',
        body: {'messages': payload['messages'], 'action': action},
      );

      return _parseResponse(response);
    } catch (e) {
      print('AI Vision Error: $e');
      return {'success': false, 'error': 'Errore analisi visione: $e'};
    }
  }
}
