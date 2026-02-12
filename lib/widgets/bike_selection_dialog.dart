import 'package:flutter/material.dart';
import '../models/bicycle.dart';
import '../models/planned_ride.dart';
import '../services/database_service.dart';

class BikeSelectionDialog extends StatefulWidget {
  final double distanceKm;
  final String activityType;
  final VoidCallback? onRideSaved;

  const BikeSelectionDialog({
    super.key,
    required this.distanceKm,
    this.activityType = "Attività",
    this.onRideSaved,
  });

  @override
  State<BikeSelectionDialog> createState() => _BikeSelectionDialogState();
}

class _BikeSelectionDialogState extends State<BikeSelectionDialog> {
  final _db = DatabaseService();
  List<Bicycle> _bikes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBikes();
  }

  Future<void> _loadBikes() async {
    try {
      final bikes = await _db.getAllBicycles();
      if (mounted) {
        setState(() {
          _bikes = bikes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading bikes: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveRide(Bicycle bike) async {
    final ride = PlannedRide()
      ..rideName = "${widget.activityType} (Health)"
      ..rideDate = DateTime.now()
      ..distance = widget.distanceKm
      ..isCompleted = true
      ..bicycleId = bike.id;
      // Notes/Description ignored since column missing in DB

    try {
      await _db.createPlannedRide(ride);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uscita salvata e km aggiornati!')),
        );
        widget.onRideSaved?.call();
        Navigator.pop(context); // Close dialog
      }
      
      // Also update bike total km? Usually stored on bike model or aggregated.
      // DatabaseService.getAllBicycles fetches from 'bicycles' table.
      // We might want to increment bike.totalKilometers too if not auto-calculated.
      // Let's assume for now we just save the ride. Sync logic might handle bike totals later or DB trigger.
      // Actually, let's update the bike locally and save it to be safe/responsive.
      bike.totalKilometers += widget.distanceKm;
      await _db.updateBicycle(bike);

    } catch (e) {
      debugPrint("Error saving ride: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante il salvataggio.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nuova Pedalata Rilevata"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Il Biciclista ha trovato ${widget.distanceKm.toStringAsFixed(1)} km di ${widget.activityType} oggi. Su quale bici li carichiamo?",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_bikes.isEmpty)
              const Text("Nessuna bici nel Garage. Aggiungine una prima!")
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _bikes.length,
                  itemBuilder: (context, index) {
                    final bike = _bikes[index];
                    return ListTile(
                      leading: const Icon(Icons.pedal_bike),
                      title: Text(bike.name),
                      subtitle: Text("${bike.type} • ${bike.totalKilometers.toStringAsFixed(0)} km"),
                      onTap: () => _saveRide(bike),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Ignora"),
        ),
      ],
    );
  }
}
