import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
// Ensure fl_chart is added or use simple progress bars

class AISettingsScreen extends StatefulWidget {
  const AISettingsScreen({super.key});

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  final _db = DatabaseService();
  bool _isLoading = true;
  UserProfile? _profile;

  // Usage Stats
  int _totalRequests = 0;
  int _successRate = 0;
  String _mostUsedModel = 'N/A';
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _fetchUsageStats();
  }

  Future<void> _loadProfile() async {
    final profile = await _db.getUserProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUsageStats() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _loadingStats = false);
        return;
      }

      // Explicitly select only necessary fields to minimize data transfer
      final response = await Supabase.instance.client
          .from('ai_logs')
          .select('status, model')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);

      // Cast response to List<Map<String, dynamic>> safely
      final List<dynamic> data = response as List<dynamic>;

      if (data.isEmpty) {
        setState(() => _loadingStats = false);
        return;
      }

      int successCount = 0;
      Map<String, int> modelCounts = {};

      for (var log in data) {
        if (log['status'] == 'success') successCount++;

        final model = log['model'] as String? ?? 'Unknown';
        modelCounts[model] = (modelCounts[model] ?? 0) + 1;
      }

      String topModel = 'N/A';
      if (modelCounts.isNotEmpty) {
        topModel = modelCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      if (mounted) {
        setState(() {
          _totalRequests = data.length; // Of last 100
          _successRate = ((successCount / data.length) * 100).toInt();
          _mostUsedModel = topModel;
          _loadingStats = false;
        });
      }
    } catch (e) {
      print('Error fetching stats: $e');
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _savePersonality(String personality) async {
    if (_profile == null) return;

    _profile!.coachPersonality = personality;
    await _db.saveUserProfile(_profile!);

    setState(() {}); // Refresh UI

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personalità Coach aggiornata!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard AI Coach')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Service Status Card
                  _buildStatusCard(),
                  const SizedBox(height: 24),

                  // 2. Personality Selector
                  Text(
                    'Personalità Coach',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scegli lo stile con cui il tuo assistente ti darà consigli.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  _buildPersonalitySelector(),

                  const SizedBox(height: 32),

                  // 3. Usage Statistics
                  Text(
                    'Statistiche Utilizzo (Ultimi 100)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      color: Colors.green[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Service: ONLINE',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Modelli Attivi: Gemini 1.5 Flash, GPT-4o, Claude 3.5 Sonnet',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.green[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalitySelector() {
    final current = _profile?.coachPersonality ?? 'friendly';

    final personalities = [
      {
        'id': 'friendly',
        'name': 'Il Biciclista',
        'icon': '🚴',
        'desc': 'Esperto, simpatico e ironico. Il compagno ideale.',
      },
      {
        'id': 'sergeant',
        'name': 'Il Sergente',
        'icon': '🪖',
        'desc': 'Duro, diretto, urla per motivarti. Niente scuse.',
      },
      {
        'id': 'zen',
        'name': 'Maestro Zen',
        'icon': '🧘',
        'desc': 'Calmo, filosofico. Focus su respiro e armonia.',
      },
      {
        'id': 'analytical',
        'name': 'L\'Ingegnere',
        'icon': '📐',
        'desc': 'Solo dati, numeri e watt. Freddo e preciso.',
      },
    ];

    return Column(
      children: personalities.map((p) {
        final isSelected = current == p['id'];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () => _savePersonality(p['id']!),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(p['icon']!, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['name']!,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                        ),
                        Text(
                          p['desc']!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.radio_button_checked,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsCard() {
    if (_loadingStats) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Richieste', '$_totalRequests', Icons.analytics),
                _buildStatItem(
                  'Successo',
                  '$_successRate%',
                  Icons.check_circle_outline,
                  color: _successRate > 80 ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                const Icon(Icons.memory, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Modello più usato: $_mostUsedModel',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
