// import '../services/data_mode_service.dart'; // Removed
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../models/user_avatar_config.dart';
import '../widgets/avatar/avatar_customizer.dart';
import '../widgets/avatar/avatar_preview.dart';
import '../services/health_sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';

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
        SnackBar(content: Text('profile.update_success'.tr())),
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
        title: Text('profile.title'.tr()),
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
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                           await Supabase.instance.client.auth.signOut();
                           if (context.mounted) {
                             // Navigate effectively to login
                             Navigator.of(context).pushAndRemoveUntil(
                               MaterialPageRoute(builder: (_) => const AuthScreen()),
                               (route) => false,
                             );
                           }
                        },
                        icon: const Icon(Icons.logout, size: 16, color: Colors.red),
                        label: const Text('Disconnetti', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Community & Sync Card (Merged)
                    // Community Mode UI Removed


                    _buildSectionHeader('profile.section_personal'.tr()),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'profile.name_label'.tr(),
                        prefixIcon: const Icon(Icons.person_outline),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: InputDecoration(
                              labelText: 'profile.gender_label'.tr(),
                              border: const OutlineInputBorder(),
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
                            decoration: InputDecoration(
                              labelText: 'profile.age_label'.tr(),
                              border: const OutlineInputBorder(),
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
                        _buildSectionHeader('profile.section_biometric'.tr()),
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
                      label: Text('profile.sync_health_btn'.tr()),
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
                            decoration: InputDecoration(
                              labelText: 'profile.weight_label'.tr(),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: InputDecoration(
                              labelText: 'profile.height_label'.tr(),
                              border: const OutlineInputBorder(),
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
                            decoration: InputDecoration(
                              labelText: 'profile.rhr_label'.tr(),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ftpController,
                            decoration: InputDecoration(
                              labelText: 'profile.ftp_label'.tr(),
                              border: const OutlineInputBorder(),
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
                            decoration: InputDecoration(
                              labelText: 'profile.hrv_label'.tr(),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _sleepController,
                            decoration: InputDecoration(
                              labelText: 'profile.sleep_label'.tr(),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('profile.section_thermal'.tr()),
                    Text(
                      'profile.thermal_hint'.tr(),
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
                        child: Text('profile.save_btn'.tr()),
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
          SnackBar(content: Text('profile.health_perms_denied'.tr())),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile.sync_ongoing'.tr())),
      );
    }

    try {
      await _healthSyncService.syncRecentData();
      await _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.sync_completed'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profile.sync_failed'.tr(args: [e.toString()]))),
        );
      }
    }
  }


  // --- Community Mode Helpers ---

  // --- Community Mode Helpers ---
  // (Removed as part of Cloud-First refactor)
}


