import 'package:flutter/material.dart';
import '../services/data_mode_service.dart';
import '../services/database_service.dart';

/// Screen for managing data persistence mode (Autonomous vs Community)
class DataProfileScreen extends StatefulWidget {
  const DataProfileScreen({super.key});

  @override
  State<DataProfileScreen> createState() => _DataProfileScreenState();
}

class _DataProfileScreenState extends State<DataProfileScreen> {
  final _dataModeService = DataModeService();
  final _db = DatabaseService();
  
  bool _isCommunityMode = false;
  bool _isLoading = true;
  String? _userEmail;
  DateTime? _lastSync;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final profile = await _db.getUserProfile();
    final user = _dataModeService.getCurrentUser();
    
    setState(() {
      _isCommunityMode = profile?.isCommunityMode ?? false;
      _userEmail = user?.email;
      _isLoading = false;
    });
  }

  Future<void> _toggleMode(bool enabled) async {
    if (enabled) {
      // User wants to enable Community mode
      final user = _dataModeService.getCurrentUser();
      
      if (user == null) {
        // Need to sign in first
        await _showAuthDialog();
      } else {
        // Already signed in, just enable
        await _enableCommunityMode();
      }
    } else {
      // Disable Community mode
      await _disableCommunityMode();
    }
  }

  Future<void> _enableCommunityMode() async {
    setState(() => _isLoading = true);
    
    final result = await _dataModeService.enableCommunityMode();
    
    setState(() => _isLoading = false);
    
    if (!mounted) return;
    
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Modalità Community attivata'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Errore attivazione'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disableCommunityMode() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disattivare Modalità Community?'),
        content: const Text(
          'I tuoi dati rimarranno salvati localmente sul dispositivo. '
          'Potrai riattivare la modalità Community in qualsiasi momento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Disattiva'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() => _isLoading = true);
    
    final result = await _dataModeService.disableCommunityMode();
    
    setState(() => _isLoading = false);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Modalità Autonoma attivata'),
      ),
    );
    
    await _loadData();
  }

  Future<void> _showAuthDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) => _AuthDialog(
        onSuccess: () async {
          Navigator.pop(ctx);
          await _enableCommunityMode();
        },
      ),
    );
  }

  Future<void> _syncNow() async {
    setState(() => _isLoading = true);
    
    final result = await _dataModeService.syncLocalToCloud();
    
    setState(() {
      _isLoading = false;
      _lastSync = DateTime.now();
    });
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Sincronizzazione completata'),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Il Tuo Profilo Dati'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Biciclistico Logo
                Center(
                  child: Image.asset(
                    'assets/log1.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Mode Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Modalità Community',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isCommunityMode 
                                        ? 'I tuoi dati sono sincronizzati sul cloud'
                                        : 'I tuoi dati sono salvati solo localmente',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isCommunityMode,
                              onChanged: _toggleMode,
                            ),
                          ],
                        ),
                        if (_isCommunityMode && _userEmail != null) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.account_circle, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _userEmail!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _syncNow,
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text('Sincronizza Ora'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Explanation Cards
                _buildInfoCard(
                  context,
                  title: 'Modalità Autonoma',
                  icon: Icons.phone_android,
                  color: Colors.blue,
                  description: 'I tuoi dati sono salvati solo sul dispositivo. '
                      'Ideale per privacy e utilizzo offline.',
                  features: [
                    '✓ Massima privacy',
                    '✓ Nessun account richiesto',
                    '✓ Funziona offline',
                    '✗ Dati solo su questo dispositivo',
                  ],
                ),
                
                const SizedBox(height: 16),
                
                _buildInfoCard(
                  context,
                  title: 'Modalità Community',
                  icon: Icons.cloud,
                  color: Colors.green,
                  description: 'I tuoi dati sono sincronizzati sul cloud Supabase. '
                      'Accessibili da più dispositivi.',
                  features: [
                    '✓ Sincronizzazione cloud',
                    '✓ Accesso multi-dispositivo',
                    '✓ Backup automatico',
                    '✓ Condivisione futura',
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required List<String> features,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                feature,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// Dialog for authentication (sign in / sign up)
class _AuthDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  
  const _AuthDialog({required this.onSuccess});

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _dataModeService = DataModeService();
  
  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    final result = _isSignUp
        ? await _dataModeService.signUpWithEmail(email, password)
        : await _dataModeService.signInWithEmail(email, password);
    
    setState(() => _isLoading = false);
    
    if (!mounted) return;
    
    if (result['success']) {
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Errore autenticazione'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isSignUp ? 'Registrati' : 'Accedi'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci email';
                }
                if (!value.contains('@')) {
                  return 'Email non valida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci password';
                }
                if (value.length < 6) {
                  return 'Minimo 6 caratteri';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _isSignUp = !_isSignUp),
          child: Text(_isSignUp ? 'Hai già un account? Accedi' : 'Non hai un account? Registrati'),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isSignUp ? 'Registrati' : 'Accedi'),
        ),
      ],
    );
  }
}
