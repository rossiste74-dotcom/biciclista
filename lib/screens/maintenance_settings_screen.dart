import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';

class MaintenanceSettingsScreen extends StatefulWidget {
  const MaintenanceSettingsScreen({super.key});

  @override
  State<MaintenanceSettingsScreen> createState() => _MaintenanceSettingsScreenState();
}

class _MaintenanceSettingsScreenState extends State<MaintenanceSettingsScreen> {
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
    if (mounted) {
      if (profile != null && profile.maintenanceDefinitions.isEmpty) {
        // Init defaults if missing (should be handled by migration but safe check)
        profile.maintenanceDefinitions = [
          MaintenanceDefinition()..name = 'Catena'..defaultInterval = 3500.0,
          MaintenanceDefinition()..name = 'Copertoni'..defaultInterval = 5000.0,
          MaintenanceDefinition()..name = 'Freni'..defaultInterval = 2500.0,
        ];
        await _db.updateUserProfile(profile);
      }
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  Future<void> _addOrEditDefinition({MaintenanceDefinition? def}) async {
    final nameController = TextEditingController(text: def?.name ?? '');
    final intervalController = TextEditingController(text: def?.defaultInterval?.toStringAsFixed(0) ?? '3000');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(def == null ? 'Nuova Manutenzione' : 'Modifica'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome componente',
                hintText: 'es. Sospensioni',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: intervalController,
              decoration: const InputDecoration(
                labelText: 'Intervallo km (default)',
                suffixText: 'km',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annulla')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salva'),
          ),
        ],
      ),
    );

    if (result == true && _profile != null) {
      final name = nameController.text.trim();
      final interval = double.tryParse(intervalController.text) ?? 3000.0;
      
      if (name.isEmpty) return;

      setState(() {
        if (def != null) {
          def.name = name;
          def.defaultInterval = interval;
        } else {
          _profile!.maintenanceDefinitions.add(
            MaintenanceDefinition()..name = name..defaultInterval = interval
          );
        }
      });
      
      await _db.updateUserProfile(_profile!);
    }
  }

  Future<void> _deleteDefinition(MaintenanceDefinition def) async {
    if (_profile == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina'),
        content: Text('Vuoi rimuovere "${def.name}" dalla lista delle manutenzioni disponibili?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sì')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _profile!.maintenanceDefinitions.remove(def);
      });
      await _db.updateUserProfile(_profile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni Manutenzione'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditDefinition(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('Profilo non trovato'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _profile!.maintenanceDefinitions.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final def = _profile!.maintenanceDefinitions[index];
                    return ListTile(
                      title: Text(def.name ?? 'Senza nome'),
                      subtitle: Text('Soglia default: ${def.defaultInterval?.toStringAsFixed(0)} km'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _addOrEditDefinition(def: def),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDefinition(def),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
