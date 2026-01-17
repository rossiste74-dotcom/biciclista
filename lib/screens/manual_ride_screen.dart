import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/planned_ride.dart';
import '../models/bicycle.dart';
import '../services/database_service.dart';

class ManualRideScreen extends StatefulWidget {
  const ManualRideScreen({super.key});

  @override
  State<ManualRideScreen> createState() => _ManualRideScreenState();
}

class _ManualRideScreenState extends State<ManualRideScreen> {
  final _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  
  DateTime _selectedDate = DateTime.now();
  final _nameController = TextEditingController();
  final _distanceController = TextEditingController();
  final _elevationController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  Map<String, dynamic>? _selectedLocation;
  
  List<Bicycle> _bicycles = [];
  Bicycle? _selectedBicycle;

  @override
  void initState() {
    super.initState();
    _loadBicycles();
  }

  Future<void> _loadBicycles() async {
    final bicycles = await _db.getAllBicycles();
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
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null) {
        setState(() => _selectedDate = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ));
      }
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}&count=5&language=it&format=json'
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _searchResults = data['results'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Search failed: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _saveRide() async {
    if (!_formKey.currentState!.validate()) return;

    final ride = PlannedRide()
      ..rideDate = _selectedDate
      ..rideName = _nameController.text
      ..distance = double.parse(_distanceController.text)
      ..elevation = double.parse(_elevationController.text)
      ..notes = _notesController.text
      ..latitude = _selectedLocation?['latitude']
      ..longitude = _selectedLocation?['longitude'];
      
    // Use the location name as a note prefix if provided
    if (_selectedLocation != null) {
      final locName = _selectedLocation!['name']; 
      final admin = _selectedLocation!['admin1'] ?? '';
      ride.notes = 'Partenza: $locName ($admin)\n\n${_notesController.text}';
    }

    // Save bicycle ID if selected
    if (_selectedBicycle != null) {
      ride.bicycleId = _selectedBicycle!.id;
      
      // Update bicycle total distance
      _selectedBicycle!.totalKilometers += ride.distance;
      await _db.updateBicycle(_selectedBicycle!);
    }

    await _db.createPlannedRide(ride);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Percorso salvato con successo!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo Percorso Manuale'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Dettagli Base'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Percorso',
                          hintText: 'es. Giro dell\'Adda',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Data e Ora'),
                        subtitle: Text(DateFormat('EEEE, d MMMM y - HH:mm', 'it_IT').format(_selectedDate)),
                        trailing: const Icon(Icons.edit),
                        onTap: _selectDateTime,
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _distanceController,
                              decoration: const InputDecoration(
                                labelText: 'Distanza (km)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _elevationController,
                              decoration: const InputDecoration(
                                labelText: 'D+ (m)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Obbligatorio' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_bicycles.length > 1) ...[
                const SizedBox(height: 24),
                _buildSectionHeader('Bicicletta'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<Bicycle>(
                      value: _selectedBicycle,
                      decoration: const InputDecoration(
                        labelText: 'Scegli bicicletta',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Seleziona la bicicletta usata'),
                      items: _bicycles.map((bike) => DropdownMenuItem(
                        value: bike,
                        child: Text('${bike.name} (${bike.type})'),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedBicycle = v),
                      validator: (v) => v == null ? 'Seleziona una bicicletta' : null,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildSectionHeader('Località (per il meteo)'),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Cerca città di partenza...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isSearching ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) : null,
                  border: const OutlineInputBorder(),
                  hintText: 'es. Milano, Roma...',
                  helperText: _selectedLocation != null 
                    ? 'Selezionato: ${_selectedLocation!['name']}'
                    : 'Cerca una località per avere le previsioni meteo',
                  helperStyle: TextStyle(color: _selectedLocation != null ? Colors.green : null),
                ),
                onChanged: _searchLocation,
              ),
              if (_searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: _searchResults.map((res) {
                      return ListTile(
                        dense: true,
                        title: Text('${res['name']}, ${res['admin1'] ?? ''}'),
                        subtitle: Text(res['country'] ?? ''),
                        onTap: () {
                          setState(() {
                            _selectedLocation = res;
                            _searchResults = [];
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 24),
              _buildSectionHeader('Note'),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Appunti sul percorso...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _saveRide,
                  child: const Text('Salva Percorso'),
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
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
