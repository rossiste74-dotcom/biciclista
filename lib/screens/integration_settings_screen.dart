import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class IntegrationSettingsScreen extends StatefulWidget {
  const IntegrationSettingsScreen({super.key});

  @override
  State<IntegrationSettingsScreen> createState() => _IntegrationSettingsScreenState();
}

class _IntegrationSettingsScreenState extends State<IntegrationSettingsScreen> {
  final _syncService = SyncService();
  bool _isStravaConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _isStravaConnected = await _syncService.isAuthenticated(SyncProvider.strava);
    setState(() => _isLoading = false);
  }

  Future<void> _connect(SyncProvider provider) async {
    try {
      await _syncService.authenticate(provider);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connessione riuscita! 🟢')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _disconnect(SyncProvider provider) async {
    await _syncService.logout();
    await _loadData();
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disconnesso.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integrazioni')),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
           if (didPop) return;
           Navigator.pop(context, _isStravaConnected);
        },
        child: _isLoading 
         ? const Center(child: CircularProgressIndicator())
         : Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               children: [
                 Card(
                   child: ListTile(
                     leading: const Icon(Icons.directions_bike, color: Colors.orange, size: 32),
                     title: const Text('Strava', style: TextStyle(fontWeight: FontWeight.bold)),
                     subtitle: Text(_isStravaConnected ? 'Connesso e pronto allo sync' : 'Non connesso'),
                     trailing: _isStravaConnected
                       ? OutlinedButton(onPressed: () => _disconnect(SyncProvider.strava), child: const Text('Disconnetti'))
                       : FilledButton.tonal(onPressed: () => _connect(SyncProvider.strava), child: const Text('Connetti Strava')),
                   ),
                 ),
                 const SizedBox(height: 16),
                 const Text(
                   'La tua privacy è al sicuro. Usiamo chiavi crittografate per accedere ai dati.',
                   style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                   textAlign: TextAlign.center,
                 ),
               ],
             ),
           ),
      ),
    );
  }
}
