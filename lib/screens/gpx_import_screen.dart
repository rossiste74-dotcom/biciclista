import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bicycle.dart';
import '../services/database_service.dart';
import '../services/gpx_service.dart';

/// Screen for importing GPX files and creating planned rides
class GpxImportScreen extends StatefulWidget {
  const GpxImportScreen({super.key});

  @override
  State<GpxImportScreen> createState() => _GpxImportScreenState();
}

class _GpxImportScreenState extends State<GpxImportScreen> {
  final _gpxService = GpxService();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _gpxPreview;
  
  List<Bicycle> _bicycles = [];
  Bicycle? _selectedBicycle;
  
  @override
  void initState() {
    super.initState();
    _loadBicycles();
  }

  Future<void> _loadBicycles() async {
    final db = DatabaseService();
    final bicycles = await db.getAllBicycles();
    setState(() {
      _bicycles = bicycles;
      if (bicycles.length == 1) {
        _selectedBicycle = bicycles.first;
      }
    });
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _importGpx() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plannedRide = await _gpxService.createPlannedRideFromGpx(
        rideDate: _selectedDate,
        bicycleId: _selectedBicycle?.id,
      );

      if (plannedRide != null && mounted) {
        // Success! Navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Percorso importato con successo!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(plannedRide);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importa Percorso GPX'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Come importare',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '1. Seleziona un file GPX dal tuo dispositivo\n'
                            '2. Scegli la data per la tua pedalata\n'
                            '3. L\'app estrarrà distanza e dislivello\n'
                            '4. Il tuo percorso verrà salvato localmente',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date picker
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Data e Ora Inizio'),
                      subtitle: Text(
                        DateFormat('EEEE, d MMMM y - HH:mm', 'it_IT').format(_selectedDate),
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectDateTime,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bicycle selector (if multiple bikes)
                  if (_bicycles.length > 1) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bicicletta',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<Bicycle>(
                              value: _selectedBicycle,
                              decoration: const InputDecoration(
                                labelText: 'Scegli bicicletta',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              hint: const Text('Seleziona la bicicletta usata'),
                              items: _bicycles.map((bike) => DropdownMenuItem(
                                value: bike,
                                child: Text('${bike.name} (${bike.type})'),
                              )).toList(),
                              onChanged: (v) => setState(() => _selectedBicycle = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Import button
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _importGpx,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Seleziona File GPX'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Preview (if available)
                  if (_gpxPreview != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anteprima Percorso',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            _buildPreviewRow(
                              Icons.straighten,
                              'Distanza',
                              '${(_gpxPreview!['distance'] as double).toStringAsFixed(1)} km',
                            ),
                            const SizedBox(height: 8),
                            _buildPreviewRow(
                              Icons.terrain,
                              'Dislivello',
                              '${(_gpxPreview!['elevation'] as double).toStringAsFixed(0)} m',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildPreviewRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text('$label: '),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
