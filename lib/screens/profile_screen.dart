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
}
