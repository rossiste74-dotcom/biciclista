import '../services/data_mode_service.dart'; // Added
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../services/health_sync_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = DatabaseService();
  final _healthSyncService = HealthSyncService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  UserProfile? _profile;
  bool _isCommunityMode = false;
  
  final _dataModeService = DataModeService(); // Added
  String? _userEmail; // Added

  
  // Controllers

  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _rhrController = TextEditingController();
  final _hrvController = TextEditingController();
  final _sleepController = TextEditingController();
  final _ftpController = TextEditingController();
  
  String _selectedGender = 'Maschio';
  int _thermalSensitivity = 3;

  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _rhrController.dispose();
    _hrvController.dispose();
    _sleepController.dispose();
    _ftpController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await _db.getUserProfile();
    if (profile != null) {
      setState(() {
        _profile = profile;
        _isCommunityMode = profile.isCommunityMode;
        
        final user = _dataModeService.getCurrentUser();
        _userEmail = user?.email;

        _nameController.text = profile.name ?? '';
        _ageController.text = profile.age.toString();
        _weightController.text = profile.weight.toString();
        _heightController.text = profile.height?.toString() ?? '';
        _rhrController.text = profile.restingHeartRate.toString();
        _hrvController.text = profile.hrv.toString();
        _sleepController.text = profile.sleepHours.toString();
        _ftpController.text = profile.functionalThresholdPower.toString();
        _selectedGender = profile.gender ?? 'Maschio';
        _thermalSensitivity = profile.thermalSensitivity;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = _profile ?? UserProfile();
    profile.name = _nameController.text;
    profile.gender = _selectedGender;
    profile.age = int.parse(_ageController.text);
    profile.weight = double.parse(_weightController.text);
    profile.height = double.tryParse(_heightController.text);
    profile.restingHeartRate = int.parse(_rhrController.text);
    profile.hrv = int.parse(_hrvController.text);
    profile.sleepHours = double.parse(_sleepController.text);
    profile.functionalThresholdPower = int.parse(_ftpController.text);
    profile.thermalSensitivity = _thermalSensitivity;
    profile.preferredUnit = 'km'; // Default for now

    // Record manual update in health history for trends
    profile.updateHealthSnapshot(
      date: DateTime.now(),
      weight: double.tryParse(_weightController.text),
      hrv: int.tryParse(_hrvController.text),
      sleepHours: double.tryParse(_sleepController.text),
    );

    await _db.saveUserProfile(profile);

    // Auto-sync if in Community Mode
    if (_isCommunityMode) {
      // Run in background properly or await? 
      // Awaiting ensuring user knows it's synced.
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Salvataggio e sincronizzazione in corso...')),
         );
      }
      final syncResult = await _dataModeService.syncLocalToCloud();
      
      if (!syncResult['success'] && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Salvataggio locale OK, ma errore sync: ${syncResult['error']}'),
             backgroundColor: Colors.red,
           ),
         );
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profilo aggiornato con successo!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo Ciclista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
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
                    // Avatar & Community Status Logic
                    Center(
                      child: InkWell(
                        onTap: () async {
                           // Toggle logic moved to switch below
                           // _loadProfile(); // Refresh on return
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (_isCommunityMode)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                                  ),
                                  child: const Icon(Icons.cloud, size: 12, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Community & Sync Card (Merged)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                             Row(
                               children: [
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text('Modalità Community', style: Theme.of(context).textTheme.titleMedium),
                                       Text(
                                         _isCommunityMode ? 'Sincronizzazione attiva' : 'Solo locale',
                                         style: Theme.of(context).textTheme.bodySmall,
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
                               const Divider(),
                               Row(
                                 children: [
                                    const Icon(Icons.account_circle, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(_userEmail!, style: const TextStyle(fontSize: 12))),
                                    FilledButton.icon(
                                       onPressed: _syncCloud,
                                       icon: const Icon(Icons.cloud_upload, size: 16),
                                       label: const Text('Sync'),
                                       style: FilledButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                       ),
                                    ),
                                 ],
                               ),
                             ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('Dati Anagrafici'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Genere',
                              border: OutlineInputBorder(),
                            ),
                            items: ['Maschio', 'Femmina', 'Altro']
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedGender = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: 'Età',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Dati Biometrici'),
                        if (_profile?.lastHealthSync != null)
                          Text(
                            'Sinc: ${DateFormat('dd/MM HH:mm').format(_profile!.lastHealthSync!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: _syncHealth,
                      icon: const Icon(Icons.sync),
                      label: const Text('Sincronizza con App Salute'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: const InputDecoration(
                              labelText: 'Peso (kg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: 'Altezza (cm)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rhrController,
                            decoration: const InputDecoration(
                              labelText: 'FC riposo (bpm)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ftpController,
                            decoration: const InputDecoration(
                              labelText: 'FTP (Watt)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hrvController,
                            decoration: const InputDecoration(
                              labelText: 'HRV (ms)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _sleepController,
                            decoration: const InputDecoration(
                              labelText: 'Sonno (ore)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Sensibilità Termica'),
                    Text(
                      'Quanto soffri il freddo? (1 = Molto resistente, 5 = Molto freddoloso)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Slider(
                      value: _thermalSensitivity.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _thermalSensitivity.toString(),
                      onChanged: (v) => setState(() => _thermalSensitivity = v.toInt()),
                    ),
                    const SizedBox(height: 32),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _saveProfile,
                        child: const Text('Salva Profilo'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _syncHealth() async {
    final granted = await _healthSyncService.requestPermissions();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permessi salute non concessi')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sincronizzazione dati salute...')),
      );
    }

    try {
      await _healthSyncService.syncRecentData();
      await _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sincronizzazione completata')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sincronizzazione fallita: $e')),
        );
      }
    }
  }


  // --- Community Mode Helpers ---

  Future<void> _toggleMode(bool enabled) async {
    if (enabled) {
      final user = _dataModeService.getCurrentUser();
      if (user == null) {
        await _showAuthDialog();
      } else {
        await _enableCommunityMode();
      }
    } else {
      await _disableCommunityMode();
    }
  }

  Future<void> _enableCommunityMode() async {
    setState(() => _isLoading = true);
    final result = await _dataModeService.enableCommunityMode();
    // Refresh profile to see 'isCommunityMode' update from DB
    await _loadProfile(); 
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] ? 'Modalità Community attivata' : (result['error'] ?? 'Errore')),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _disableCommunityMode() async {
    // Confirm
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disattivare Community?'),
        content: const Text('I dati rimarranno solo sul dispositivo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Disattiva')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    await _dataModeService.disableCommunityMode();
    await _loadProfile();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modalità Autonoma attivata')));
    }
  }

  Future<void> _syncCloud() async {
     setState(() => _isLoading = true);
     final result = await _dataModeService.syncLocalToCloud();
     await _loadProfile(); // Update last sync timestamp if needed
     
     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(result['message'] ?? 'Sync completato'),
           backgroundColor: result['success'] ? Colors.green : Colors.red,
         ),
       );
     }
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
}

/// Dialog for authentication (Embedded in Profile)
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
                if (value == null || value.isEmpty) return 'Inserisci email';
                if (!value.contains('@')) return 'Email non valida';
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
                if (value == null || value.isEmpty) return 'Inserisci password';
                if (value.length < 6) return 'Minimo 6 caratteri';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _isSignUp = !_isSignUp),
          child: Text(_isSignUp ? 'Hai già un account? Accedi' : 'Non hai un account? Registrati', style: const TextStyle(fontSize: 12)),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isSignUp ? 'Registrati' : 'Accedi'),
        ),
      ],
    );
  }
}

