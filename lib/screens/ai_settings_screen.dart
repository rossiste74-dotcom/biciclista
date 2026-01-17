import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/ai_provider.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';
import 'api_key_guide_screen.dart';

class AISettingsScreen extends StatefulWidget {
  const AISettingsScreen({super.key});

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  final _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  
  AIProvider? _selectedProvider;
  bool _isLoading = true;
  bool _obscureKey = true;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final profile = await _db.getUserProfile();
    if (profile != null) {
      setState(() {
        _selectedProvider = profile.getAIProvider();
        _apiKeyController.text = profile.aiApiKey ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = await _db.getUserProfile();
    if (profile == null) return;

    profile.setAIProvider(_selectedProvider);
    profile.aiApiKey = _apiKeyController.text.trim().isEmpty ? null : _apiKeyController.text.trim();
    
    await _db.saveUserProfile(profile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurazione AI salvata!')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _testConnection() async {
    if (_selectedProvider == null || _apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona un provider e inserisci una API key')),
      );
      return;
    }

    setState(() => _isTesting = true);

    // Save current settings temporarily to test
    final profile = await _db.getUserProfile();
    if (profile != null) {
      final previousProvider = profile.getAIProvider();
      final previousKey = profile.aiApiKey;
      
      // Set test values
      profile.setAIProvider(_selectedProvider);
      profile.aiApiKey = _apiKeyController.text.trim();
      await _db.saveUserProfile(profile);
      
      // Test connection
      final aiService = AIService();
      final result = await aiService.testConnection();
      
      // Restore previous values
      profile.setAIProvider(previousProvider);
      profile.aiApiKey = previousKey;
      await _db.saveUserProfile(profile);
      
      setState(() => _isTesting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    } else {
      setState(() => _isTesting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profilo non trovato')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurazione AI Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Bring Your Own Key (BYOK)',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Usa la tua API key personale per l\'AI Coach. La chiave viene salvata solo sul tuo dispositivo e non viene mai inviata ai nostri server.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Paghi solo per quello che consumi direttamente al fornitore.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Provider AI',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<AIProvider>(
                            value: _selectedProvider,
                            decoration: const InputDecoration(
                              labelText: 'Seleziona Provider',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.cloud_outlined),
                            ),
                            hint: const Text('Scegli il tuo provider AI'),
                            items: AIProvider.values.map((provider) {
                              return DropdownMenuItem(
                                value: provider,
                                child: Text(provider.displayName),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedProvider = value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const APIKeyGuideScreen()),
                            );
                          },
                          tooltip: 'Guida API',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'API Key',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: InputDecoration(
                        labelText: 'Inserisci la tua API key',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.key),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureKey = !_obscureKey),
                        ),
                        helperText: 'La chiave viene salvata solo sul tuo dispositivo',
                        helperMaxLines: 2,
                      ),
                      obscureText: _obscureKey,
                      maxLines: _obscureKey ? 1 : 3,
                    ),
                    const SizedBox(height: 16),
                    if (_selectedProvider != null) ...[
                      Card(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Come ottenere una API key:',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getProviderInstructions(_selectedProvider!),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isTesting ? null : _testConnection,
                            icon: _isTesting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.router_outlined),
                            label: Text(_isTesting ? 'Testing...' : 'Test Connessione'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _saveSettings,
                            icon: const Icon(Icons.save),
                            label: const Text('Salva'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getProviderInstructions(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return 'Vai su platform.openai.com/api-keys e crea una nuova chiave. GPT-4o mini costa circa \$0.15 per 1M di token di input.';
      case AIProvider.claude:
        return 'Vai su console.anthropic.com e crea una API key. Claude 3.5 Sonnet costa circa \$3 per 1M di token di input.';
      case AIProvider.gemini:
        return 'Vai su aistudio.google.com/app/apikey e crea una nuova chiave. Gemini 1.5 Pro ha un tier gratuito generoso.';
    }
  }
}
