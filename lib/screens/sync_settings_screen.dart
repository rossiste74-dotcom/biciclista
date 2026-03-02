import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/health_sync_service.dart';
import 'health_activity_list_screen.dart';

class SyncSettingsScreen extends StatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  final _healthSync = HealthSyncService();
  bool _isLoading = true;
  double _minRideDistance = 50.0;
  bool _syncOtherWorkouts = false;
  
  // Available types to config
  final Map<HealthDataType, bool> _syncSettings = {
    HealthDataType.DISTANCE_DELTA: true,
    HealthDataType.HEART_RATE: true,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD: true,
    HealthDataType.SLEEP_SESSION: true,
    HealthDataType.WEIGHT: true,
    // Add others if desired, but these are the current ones implemented
    // HealthDataType.STEPS: false, 
    // HealthDataType.ACTIVE_ENERGY_BURNED: false,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var type in _syncSettings.keys) {
        // Default to true if not set
        _syncSettings[type] = prefs.getBool('sync_enable_${type.name}') ?? true;
      }
      _minRideDistance = prefs.getDouble('min_ride_distance_km') ?? 50.0;
      _syncOtherWorkouts = prefs.getBool('sync_enable_OTHER_WORKOUTS') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _toggleSetting(HealthDataType type, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sync_enable_${type.name}', value);
    setState(() {
      _syncSettings[type] = value;
    });
  }

  Future<void> _saveMinDistance(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('min_ride_distance_km', value);
  }

  Future<void> _toggleOtherWorkouts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sync_enable_OTHER_WORKOUTS', value);
    setState(() {
      _syncOtherWorkouts = value;
    });
  }

  String _getLabel(HealthDataType type) {
    switch (type) {
      case HealthDataType.DISTANCE_DELTA:
        return "Distanza (Ciclismo)";
      case HealthDataType.HEART_RATE:
        return "Battito Cardiaco";
      case HealthDataType.HEART_RATE_VARIABILITY_RMSSD:
        return "Variabilità Cardiaca (HRV)";
      case HealthDataType.SLEEP_SESSION:
        return "Sonno";
      case HealthDataType.WEIGHT:
        return "Peso Corporeo";
      default:
        return type.name;
    }
  }

  String _getDescription(HealthDataType type) {
    switch (type) {
      case HealthDataType.DISTANCE_DELTA:
        return "Sincronizza i km percorsi per rilevare automaticamente le uscite.";
      case HealthDataType.HEART_RATE:
        return "Analisi dello sforzo e recupero.";
      case HealthDataType.HEART_RATE_VARIABILITY_RMSSD:
         return "Monitoraggio dello stress e Readiness.";
      case HealthDataType.SLEEP_SESSION:
         return "Analisi del recupero notturno.";
      case HealthDataType.WEIGHT:
         return "Aggiorna automaticamente il peso nel profilo.";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni Sincronizzazione'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Seleziona quali dati sincronizzare con Health Connect / Salute.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ..._syncSettings.keys.map((type) {
                  return Column(
                    children: [
                      SwitchListTile(
                        title: Text(_getLabel(type)),
                        subtitle: Text(_getDescription(type)),
                        value: _syncSettings[type] ?? false,
                        onChanged: (val) => _toggleSetting(type, val),
                      ),
                      if (type == HealthDataType.DISTANCE_DELTA && (_syncSettings[type] ?? false))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Distanza Minima per Notifica: ${_minRideDistance.toInt()} km",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Slider(
                                value: _minRideDistance,
                                min: 1,
                                max: 100,
                                divisions: 99,
                                label: "${_minRideDistance.toInt()} km",
                                onChanged: (val) => setState(() => _minRideDistance = val),
                                onChangeEnd: (val) => _saveMinDistance(val),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
                const Divider(),
                SwitchListTile(
                  title: const Text("Sincronizza Altri Sport"),
                  subtitle: const Text("Importa automaticamente Corsa, Camminata, ecc. per l'analisi."),
                  value: _syncOtherWorkouts,
                  onChanged: _toggleOtherWorkouts,
                ),
                const Divider(),
                 ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text("Forza Sincronizzazione"),
                  subtitle: const Text("Avvia manualmente la sincronizzazione ora."),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sincronizzazione avviata...')),
                    );
                    try {
                      await _healthSync.syncRecentData();
                       if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sincronizzazione completata!')),
                        );
                      }
                    } catch (e) {
                       if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Errore: $e')),
                        );
                      }
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("Cronologia Importazioni"),
                  subtitle: const Text("Visualizza le attività scaricate da Health Connect"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HealthActivityListScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text("Importa Storico (1 Anno)"),
                  subtitle: const Text("Scarica tutte le attività dell'ultimo anno."),
                  onTap: () async {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Importazione storico in corso... Potrebbe richiedere tempo.')),
                     );
                     try {
                        await _healthSync.syncFullHistory();
                        if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Storico importato con successo!')),
                           );
                        }
                     } catch (e) {
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Errore importazione: $e')),
                           );
                        }
                     }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.grey),
                  title: const Text("Debug Connessione"),
                  subtitle: const Text("Verifica quanti dati l'app riesce a vedere."),
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (context) => FutureBuilder<String>(
                        future: _getDebugStats(),
                        builder: (context, snapshot) {
                          return AlertDialog(
                            title: const Text("Debug Health Connect"),
                            content: snapshot.hasData 
                                ? Text(snapshot.data!)
                                : const SizedBox(
                                    height: 100, 
                                    child: Center(child: CircularProgressIndicator())
                                  ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Chiudi"),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Future<String> _getDebugStats() async {
    if (kIsWeb) return "Health Connect non è supportato sul Web.";
    final health = Health();
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 365));
    
    try {
      final workouts = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: now,
        types: [HealthDataType.WORKOUT],
      );
      
      final steps = await health.getHealthDataFromTypes(
        startTime: now.subtract(const Duration(days: 3)),
        endTime: now,
        types: [HealthDataType.STEPS],
      );
      
      String msg = "Dati trovati (ultimi 365gg):\n"
             "- Allenamenti (WORKOUT): ${workouts.length}\n";
      
      if (workouts.isNotEmpty) {
        try {
          final types = workouts.take(3).map((e) {
            final val = e.value as WorkoutHealthValue;
            return val.workoutActivityType.toString();
          }).join(', ');
          msg += "- Primi 3 Tipi: $types\n";
        } catch (e) {
          msg += "- (Errore lettura tipi)\n";
        }
      }
      
      msg += "\nTest Rapido (ultimi 3gg):\n"
             "- Passi (STEPS): ${steps.length}";
             
      if (workouts.isEmpty && steps.isEmpty) {
         msg += "\n\n⚠️ ATTENZIONE: 0 Dati trovati.\n"
                "Molto probabilmente Health Connect è vuoto.\n"
                "1. Apri l'app 'Health Connect' (o Connessione Salute).\n"
                "2. Controlla se vedi dati lì dentro.\n"
                "3. Se è vuota, devi collegare Google Fit o Samsung Health a Health Connect dalle loro impostazioni.";
      }
      
      return msg;
    } catch (e) {
      return "Errore lettura: $e";
    }
  }
}
