import 'package:flutter/material.dart';
import 'dart:io';
import 'package:gpx/gpx.dart';
import 'dashboard_screen.dart';
import 'routes_library_screen.dart';
import 'settings_screen.dart';
import 'community_screen.dart';
import 'discovery_screen.dart';
import 'package:biciclistico/screens/gpx_import_screen.dart';

import 'manual_ride_screen.dart';
import 'qr_scan_screen.dart';
import 'route_planner_screen.dart';
import 'profile_screen.dart';
import 'ai_lab_screen.dart'; // Added for Phase 3

import 'garage_screen.dart';
import '../services/sync_service.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/planned_ride.dart';
import '../models/bicycle.dart';
import '../services/notification_service.dart';
import '../widgets/bike_selection_dialog.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final _crewRefreshNotifier = ValueNotifier<int>(0);
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const RoutesLibraryScreen(),
      const AiLabScreen(),
      const CommunityScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkExternalActivities());

    // Listen for Notification Tap (Sync Manager)
    NotificationService().onNotificationTap.listen((payload) {
      if (payload != null && mounted) {
        final parts = payload.split('|');
        final km = double.tryParse(parts[0]) ?? 0.0;
        final type = parts.length > 1 ? parts[1] : "Attività";
        
        showDialog(
          context: context,
          builder: (_) => BikeSelectionDialog(distanceKm: km, activityType: type),
        );
      }
    });
  }
  
  @override
  void dispose() {
    _crewRefreshNotifier.dispose();
    super.dispose();
  }

  Future<void> _checkExternalActivities() async {
    final syncService = SyncService();
    final db = DatabaseService();
    
    // 1. Check if we have credentials (e.g. Strava linked)
    if (await syncService.isAuthenticated(SyncProvider.strava)) { 
      try {
        final activities = await syncService.syncRecentActivities(limit: 5);
        final newActivities = <ImportedActivity>[];
        
        for (final activity in activities) {
           final exists = await db.doesRideExist(activity.date);
           if (!exists) {
             newActivities.add(activity);
           }
        }

        if (newActivities.isNotEmpty) {
          if (newActivities.length == 1) {
             _proposeImport(newActivities.first);
          } else {
             _proposeBulkImport(newActivities);
          }
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

  void _proposeBulkImport(List<ImportedActivity> activities) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Trovate ${activities.length} nuove attività! 🚴'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               const Text('Vuoi importare tutte le attività recenti?'),
               const SizedBox(height: 16),
               Flexible(
                 child: ListView.separated(
                   shrinkWrap: true,
                   itemCount: activities.length,
                   separatorBuilder: (_,__) => const Divider(),
                   itemBuilder: (context, index) {
                      final act = activities[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(act.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('${DateFormat('dd/MM').format(act.date)} • ${act.distance.toStringAsFixed(1)} km'),
                      );
                   },
                 ),
               ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ignora Tutto'),
          ),
          FilledButton(
            onPressed: () async {
               Navigator.pop(ctx);
               for (final activity in activities) {
                  await _importActivity(activity);
               }
            },
            child: const Text('Importa Tutte'),
          ),
        ],
      ),
    );
  }

  Future<void> _importActivity(ImportedActivity activity) async {
    final syncService = SyncService();
    final db = DatabaseService();
    
    try {
      // 1. Download GPX (if possible)
    File? gpxFile;
    double? startLat;
    double? startLng;
      
      try {
        if (activity.source == 'Strava') {
          // Notify user downloading is happening (optional, but good for UX)
          gpxFile = await syncService.downloadAndSaveGpx(activity.id, activity.name);
          
          if (gpxFile != null) {
            // Read first point for lat/lng
            final xml = await gpxFile.readAsString();
            final gpx = GpxReader().fromString(xml);
            if (gpx.trks.isNotEmpty && gpx.trks.first.trksegs.isNotEmpty && gpx.trks.first.trksegs.first.trkpts.isNotEmpty) {
               final pt = gpx.trks.first.trksegs.first.trkpts.first;
               startLat = pt.lat;
               startLng = pt.lon;
            }
          }
        }
      } catch (e) {
        debugPrint('GPX Download/Parse Error: $e');
      }

      // 2. Bike Matching Logic
      // Try to find a local bike that matches Strava gear name
      Bicycle? matchedBike;
      if (activity.gearName != null) {
         final allBikes = await db.getAllBicycles();
         // Simple case-insensitive match
         // Could be improved with Levenshtein or "contains" logic
         try {
           matchedBike = allBikes.firstWhere(
             (b) => b.name.toLowerCase().trim() == activity.gearName!.toLowerCase().trim(),
           );
         } catch (_) {
           // No match found
         }
      }

      // 3. Create PlannedRide entry
      final newRide = PlannedRide()
        ..rideName = activity.name
        ..rideDate = activity.date
        ..distance = activity.distance
        ..elevation = activity.elevation
        ..movingTime = activity.movingTime
        ..avgSpeed = activity.avgSpeed
        
        // Extended Stats
        ..avgHeartRate = activity.avgHeartRate
        ..maxHeartRate = activity.maxHeartRate
        ..avgPower = activity.avgPower
        ..maxPower = activity.maxPower
        ..avgCadence = activity.avgCadence
        ..calories = activity.calories
        
        ..isCompleted = true 
        ..gpxFilePath = gpxFile?.path
        ..latitude = startLat
        ..longitude = startLng
        ..bicycleId = matchedBike?.id // Auto-assign if matched
        ..aiAnalysis = 'Imported from ${activity.source} \nMoving Time: ${activity.movingTime ~/ 60} min \nAvg Speed: ${activity.avgSpeed.toStringAsFixed(1)} km/h';

      debugPrint('Saving imported ride: ${newRide.rideName}');
      await db.createPlannedRide(newRide);
      debugPrint('Ride saved successfully');

      if (mounted) {
         // 4. Handle Bike Stats Update
         if (matchedBike != null) {
            // Auto update logic
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('Attività importata e associata a "${matchedBike.name}"! 🚲'),
                 duration: const Duration(seconds: 4),
                 action: SnackBarAction(
                   label: 'Cambia', 
                   onPressed: () => _showBikeSelectionDialog(newRide), // Allow correction
                 ),
               )
            );
            // We need to trigger stats update for the matched bike silently or clearly
            // The method _completeRide logic is actually reusable but it's part of RouteDetailScreen logic usually...
            // Wait, here we just created the ride. We haven't updated the bike stats yet.
            // We need a helper to update bike stats.
            await _updateBikeStats(matchedBike, newRide);
            
         } else {
            // No match -> Ask user
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attività salvata! Seleziona la bici usata...')));
            await _showBikeSelectionDialog(newRide);
         }
      }
    } catch (e, stack) {
      debugPrint('Import Error: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Errore importazione: $e'),
          backgroundColor: Colors.red,
        ));
      }
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
                  await _updateBikeStats(bike, ride);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _updateBikeStats(Bicycle bike, PlannedRide ride) async {
    final db = DatabaseService();
    final double rideDist = ride.distance;

    // Update stats safely
    bike.totalKilometers = (bike.totalKilometers.isNaN ? 0.0 : bike.totalKilometers) + rideDist;
    bike.chainKms = (bike.chainKms.isNaN ? 0.0 : bike.chainKms) + rideDist;
    bike.tyreKms = (bike.tyreKms.isNaN ? 0.0 : bike.tyreKms) + rideDist;

    // Update dynamic components
    final notify = NotificationService();
    for (var component in bike.components) {
      component.currentKm = (component.currentKm.isNaN ? 0.0 : component.currentKm) + rideDist;
      
      // Check limits
      if (component.limitKm > 0 && component.currentKm >= component.limitKm * 0.9) {
          await notify.showMaintenanceAlert(
            id: ((bike.id?.hashCode ?? 0) % 100000) * 1000 + bike.components.indexOf(component), 
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
            ListTile(
              leading: const Icon(Icons.draw),
              title: const Text('Disegna su Mappa'),
              subtitle: const Text('Crea traccia su mappa con Snap-to-Road'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => RoutePlannerScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return Text('biciclistico', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold));
      case 1:
        return const Text('Percorsi');
      case 2:
        return const Text('Laboratorio AI');
      case 3:
        return const Text('Community');
      default:
        return const Text('biciclistico');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
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
              
              // 2. Refresh sync logic if settings returned true (sync enabled)
              if (result == true) {
                 await _checkExternalActivities();
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 60.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Home')),
            Expanded(child: _buildNavItem(1, Icons.directions_bike_outlined, Icons.directions_bike, 'Percorsi')),
            const SizedBox(width: 48), // Spazio per il FAB
            Expanded(child: _buildNavItem(2, Icons.psychology_outlined, Icons.psychology, 'AI Lab')),
            Expanded(child: _buildNavItem(3, Icons.people_outline, Icons.people, 'Community')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData solidIcon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected 
        ? Theme.of(context).colorScheme.primary 
        : Theme.of(context).colorScheme.onSurfaceVariant;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 3) {
          _crewRefreshNotifier.value++;
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? solidIcon : outlineIcon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

