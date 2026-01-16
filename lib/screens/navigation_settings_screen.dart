import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import 'alert_rules_screen.dart';

class NavigationSettingsScreen extends StatefulWidget {
  const NavigationSettingsScreen({super.key});

  @override
  State<NavigationSettingsScreen> createState() => _NavigationSettingsScreenState();
}

class _NavigationSettingsScreenState extends State<NavigationSettingsScreen> {
  final _db = DatabaseService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _db.getUserProfile();
    if (mounted && profile != null) {
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_profile != null) {
      await _db.saveUserProfile(_profile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profile == null) {
      return const Scaffold(body: Center(child: Text('Profilo non trovato')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni Navigazione'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Regole Alert'),
          ListTile(
            leading: const Icon(Icons.rule),
            title: const Text('Configura Regole'),
            subtitle: const Text('Personalizza eventi e messaggi vocali'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AlertRulesScreen()),
            ),
          ),
          const Divider(),
          _buildSectionHeader('Energia'),
          SwitchListTile(
            title: const Text('Risparmio Energetico'),
            subtitle: const Text('Schermo si spegne, si riattiva per gli alert'),
            value: _profile!.energySavingMode,
            onChanged: (val) {
              setState(() => _profile!.energySavingMode = val);
              _saveProfile();
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Nota: In modalità Risparmio Energetico, lo schermo si riaccenderà automaticamente quando ricevi un alert.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
