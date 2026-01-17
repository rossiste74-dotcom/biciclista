import 'package:flutter/material.dart';
import '../models/bicycle.dart';
import '../services/database_service.dart';

class BicyclesScreen extends StatefulWidget {
  const BicyclesScreen({super.key});

  @override
  State<BicyclesScreen> createState() => _BicyclesScreenState();
}

class _BicyclesScreenState extends State<BicyclesScreen> {
  final _db = DatabaseService();
  List<Bicycle> _bicycles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBicycles();
  }

  Future<void> _loadBicycles() async {
    final bicycles = await _db.getAllBicycles();
    setState(() {
      _bicycles = bicycles;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le Mie Biciclette'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bicycles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pedal_bike,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nessuna bicicletta registrata',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aggiungi la tua prima bicicletta!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bicycles.length,
                  itemBuilder: (context, index) {
                    final bike = _bicycles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          radius: 28,
                          child: Icon(
                            Icons.pedal_bike,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          bike.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${bike.type} • ${bike.gearingSystem}'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.straighten, size: 16, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  '${bike.totalKilometers.toStringAsFixed(1)} km totali',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showBicycleDialog(bike: bike),
                              tooltip: 'Modifica',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteBicycle(bike),
                              tooltip: 'Elimina',
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBicycleDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi Bicicletta'),
      ),
    );
  }

  Future<void> _showBicycleDialog({Bicycle? bike}) async {
    final nameController = TextEditingController(text: bike?.name ?? '');
    final typeController = TextEditingController(text: bike?.type ?? 'Road');
    final gearingController = TextEditingController(text: bike?.gearingSystem ?? 'Mechanical');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bike == null ? 'Aggiungi Bicicletta' : 'Modifica Bicicletta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'es: La mia Specialized',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: typeController.text,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: ['Road', 'MTB', 'Gravel', 'City', 'E-Bike']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => typeController.text = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: gearingController.text,
                decoration: const InputDecoration(
                  labelText: 'Sistema di Trasmissione',
                  border: OutlineInputBorder(),
                ),
                items: ['Mechanical', 'Electronic', 'Single Speed']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => gearingController.text = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inserisci un nome')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(bike == null ? 'Aggiungi' : 'Salva'),
          ),
        ],
      ),
    );

    if (result == true) {
      final newBike = bike ?? Bicycle();
      newBike.name = nameController.text;
      newBike.type = typeController.text;
      newBike.gearingSystem = gearingController.text;
      
      if (bike == null) {
        newBike.totalKilometers = 0;
        newBike.lastMaintenance = DateTime.now();
        newBike.applyDefaults(); // Apply threshold defaults
        await _db.createBicycle(newBike);
      } else {
        await _db.updateBicycle(newBike);
      }
      
      await _loadBicycles();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(bike == null ? 'Bicicletta aggiunta!' : 'Bicicletta aggiornata!')),
        );
      }
    }
    
    nameController.dispose();
    typeController.dispose();
    gearingController.dispose();
  }

  Future<void> _deleteBicycle(Bicycle bike) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Sei sicuro di voler eliminare "${bike.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteBicycle(bike.id);
      await _loadBicycles();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bicicletta eliminata')),
        );
      }
    }
  }
}
