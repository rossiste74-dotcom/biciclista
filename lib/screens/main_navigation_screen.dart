import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'rides_list_screen.dart';
import 'settings_screen.dart';
import 'gpx_import_screen.dart';
import 'manual_ride_screen.dart';
import 'qr_scan_screen.dart';
import 'profile_screen.dart';

import 'garage_screen.dart';
import '../services/sync_service.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/planned_ride.dart';
import '../models/bicycle.dart';
import '../services/notification_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const RidesListScreen(),
    const GarageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkExternalActivities());
  }

  Future<void> _checkExternalActivities() async {
    final syncService = SyncService();
    // 1. Check if we have credentials (e.g. Strava linked)
    if (await syncService.isAuthenticated(SyncProvider.strava)) { 
      try {
        final activity = await syncService.syncLastActivity();
        if (activity != null) {
          _proposeImport(activity);
        }
      } catch (e) {
          debugPrint('Sync Error: $e');
      }
    }
  }

  void _proposeImport(ImportedActivity activity) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Attività Trovata! 🚴'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trovata nuova attività da ${activity.source}:'),
            const SizedBox(height: 8),
            Text('Nome: ${activity.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Data: ${DateFormat('dd/MM HH:mm').format(activity.date)}'),
            Text('Distanza: ${activity.distance.toStringAsFixed(1)} km'),
            Text('Velocità Media: ${activity.avgSpeed.toStringAsFixed(1)} km/h'),
            const SizedBox(height: 16),
            const Text('Vuoi importarla nel diario?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ignora'),
          ),
          FilledButton(
            onPressed: () {
               Navigator.pop(ctx);
               _importActivity(activity);
            },
            child: const Text('Importa'),
          ),
        ],
      ),
    );
  }

  Future<void> _importActivity(ImportedActivity activity) async {
      final db = DatabaseService();
      
      // 1. Create PlannedRide entry
      final newRide = PlannedRide()
        ..rideName = activity.name
        ..rideDate = activity.date
        ..distance = activity.distance
        ..elevation = activity.elevation
        ..isCompleted = true // It's already done
        ..gpxFilePath = null // No GPX file initially, unless we download stream later
        ..aiAnalysis = 'Imported from ${activity.source} \nMoving Time: ${activity.movingTime ~/ 60} min \nAvg Speed: ${activity.avgSpeed.toStringAsFixed(1)} km/h';

      await db.createPlannedRide(newRide);

      
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attività salvata! Seleziona la bici usata...')));
         // 2. Prompt for Bike to update stats
         _showBikeSelectionDialog(newRide);
      }
  }

  Future<void> _showBikeSelectionDialog(PlannedRide ride) async {
    final db = DatabaseService();
    final bicycles = await db.getAllBicycles();

    if (!mounted) return;

    if (bicycles.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nessuna bici in garage. Km non assegnati.')));
       return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Con quale bici? 🚲'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: bicycles.length,
            itemBuilder: (context, index) {
              final bike = bicycles[index];
              return ListTile(
                leading: const Icon(Icons.directions_bike),
                title: Text(bike.name),
                subtitle: Text('${bike.totalKilometers.toInt()} km totali'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _updateBikeStats(bike, ride.distance, db);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _updateBikeStats(Bicycle bike, double distance, DatabaseService db) async {
    bike.totalKilometers += distance;
    
    // Update components
    final notify = NotificationService();
    for (var component in bike.components) {
      component.currentKm += distance;
      
      // Check limits
      if (component.limitKm > 0 && component.currentKm >= component.limitKm * 0.9) {
         await notify.showMaintenanceAlert(
           id: (bike.id * 1000) + bike.components.indexOf(component), 
           title: '⚠️ Manutenzione necessaria su ${bike.name}',
           body: 'Il componente "${component.name}" ha raggiunto ${component.currentKm.toInt()} km. Verifica lo stato!',
         );
      }
    }
    
    await db.updateBicycle(bike);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Km aggiunti a ${bike.name} e componenti aggiornati!')));
    }
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Carica File GPX'),
              subtitle: const Text('Estrai dati e percorso dal file'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GpxImportScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Inserimento Manuale'),
              subtitle: const Text('Inserisci data, km e dislivello'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManualRideScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scansiona QR Code'),
              subtitle: const Text('Importa percorso da un altro ciclista'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QrScanScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Biciclistico' : 'Le Mie Attività'),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              radius: 16,
              child: Icon(
                Icons.person,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              // Navigate to settings and check if AI config changed
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              
              // If AI configuration changed, reload current page
              if (result == true && _selectedIndex == 0) {
                // Force rebuild of DashboardScreen
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_bike_outlined),
            selectedIcon: Icon(Icons.directions_bike),
            label: 'Attività',
          ),
          NavigationDestination(
            icon: Icon(Icons.garage_outlined),
            selectedIcon: Icon(Icons.garage),
            label: 'Garage',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1 
          ? FloatingActionButton(
              onPressed: _showAddMenu,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
