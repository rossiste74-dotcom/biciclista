// import '../services/data_mode_service.dart'; // Removed
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../models/user_avatar_config.dart';
import '../widgets/avatar/avatar_customizer.dart';
import '../widgets/avatar/avatar_preview.dart';
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
  UserAvatarConfig? _avatarConfig; // Added
  // final _dataModeService = DataModeService(); // Removed
  // bool _isCommunityMode = false; // Removed
  // String? _userEmail; // Removed 

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

  @override
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
        // _isCommunityMode = profile.isCommunityMode; // Removed
        
        // Parse avatar data
        _avatarConfig = profile.avatarData != null
            ? UserAvatarConfig.fromJsonString(profile.avatarData!)
            : null;
        
        // final user = _dataModeService.getCurrentUser(); // Removed
        // _userEmail = user?.email; // Removed

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
    
    // Save avatar config if exists
    if (_avatarConfig != null) {
      profile.avatarData = _avatarConfig!.toJsonString();
    }

    // Record manual update in health history for trends
    profile.updateHealthSnapshot(
      date: DateTime.now(),
      weight: double.tryParse(_weightController.text),
      hrv: int.tryParse(_hrvController.text),
      sleepHours: double.tryParse(_sleepController.text),
    );

    await _db.saveUserProfile(profile);

    // Auto-sync if in Community Mode
    // Auto-sync block removed
    /*
    if (_isCommunityMode) {
       ...
    }
    */

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profilo aggiornato con successo!')),
      );
      Navigator.pop(context);
    }
  }
  
  Future<void> _openAvatarCustomizer() async {
    final result = await Navigator.push<UserAvatarConfig>(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarCustomizerScreen(initialConfig: _avatarConfig),
      ),
    );
    
    if (result != null) {
      setState(() {
        _avatarConfig = result;
      });
      // We don't save immediately here to keep "Save Profile" button as the main fetch
      // But we could suggest user to save.
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
                        onTap: _openAvatarCustomizer,
                        borderRadius: BorderRadius.circular(50),
                        child: Stack(
                          children: [
                            if (_avatarConfig != null)
                              ClipOval(
                                child: Container(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: AvatarPreview(config: _avatarConfig!, size: 100),
                                ),
                              )
                            else
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                              ),
                             Positioned(
                               bottom: 0,
                               right: 0,
                               child: Container(
                                 padding: const EdgeInsets.all(4),
                                 decoration: BoxDecoration(
                                   color: Theme.of(context).colorScheme.primary,
                                   shape: BoxShape.circle,
                                   border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                                 ),
                                 child: const Icon(Icons.edit, size: 16, color: Colors.white),
                               ),
                             ),
                             // Cloud icon removed
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Community & Sync Card (Merged)
                    // Community Mode UI Removed


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

  // --- Community Mode Helpers ---
  // (Removed as part of Cloud-First refactor)
}


