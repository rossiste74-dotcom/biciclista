import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/bicycle.dart';
import '../models/user_profile.dart'; // Needed for type safety if used
import '../services/database_service.dart';
import '../services/ai_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  final _db = DatabaseService();
  final _picker = ImagePicker();
  List<Bicycle> _bikes = [];
  bool _isLoading = true;
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _loadBikes();

    // Listen for DB changes
    _subscriptions.add(_db.watchBicycles().listen((_) => _loadBikes()));
    _subscriptions.add(_db.watchPlannedRides().listen((_) => _loadBikes()));
    _subscriptions.add(_db.watchUserProfile().listen((_) => _loadBikes()));
  }

  @override
  void dispose() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  Future<void> _loadBikes() async {
    final profile = await _db.getUserProfile();
    final bikes = await _db.getAllBicycles();

    bool needsUpdate = false;

    if (profile != null && profile.maintenanceDefinitions.isNotEmpty) {
      for (var bike in bikes) {
        // Sync components with profile definitions
        final existingNames = bike.components.map((c) => c.name).toSet();

        for (var def in profile.maintenanceDefinitions) {
          if (!existingNames.contains(def.name)) {
            bike.components.add(
              BicycleComponent()
                ..name = def.name
                ..limitKm = def.defaultInterval ?? 3000.0
                ..currentKm = 0.0
                ..lastMaintenance = DateTime.now(),
            );
            needsUpdate = true;
          } else {
            // Update limit if it changed? Maybe better to leave it as is if customized per bike
            // For now, let's keep it simple and just add missing ones.
          }
        }

        if (needsUpdate) {
          await _db.updateBicycle(bike);
        }
      }
    } else {
      // Fallback for empty profile or legacy
      for (var bike in bikes) {
        if (bike.components.isEmpty) {
          bike.applyDefaults();
          await _db.updateBicycle(bike);
          needsUpdate = true;
        }
      }
    }

    if (mounted) {
      setState(() {
        _bikes = bikes;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(Bicycle bike) async {
    final hasCamera = await _isCameraAvailable();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'garage.update_photo'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  Icons.camera_alt,
                  'garage.camera'.tr(),
                  ImageSource.camera,
                  context,
                ),
                _buildSourceOption(
                  Icons.photo_library,
                  'garage.gallery'.tr(),
                  ImageSource.gallery,
                  context,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'bike_${bike.id}_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final savedImage = await File(
        image.path,
      ).copy('${appDir.path}/$fileName');

      bike.bikeImagePath = savedImage.path;

      await _db.updateBicycle(bike);

      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildSourceOption(
    IconData icon,
    String label,
    ImageSource source,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () => Navigator.pop(context, source),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<bool> _isCameraAvailable() async => true;

  Future<void> _replaceComponent(Bicycle bike, BicycleComponent component) async {
    DateTime selectedDate = DateTime.now();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Sostituisci ${component.name ?? 'Componente'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Questa azione registrerà la sostituzione e azzererà il contatore km.'),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data sostituzione'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.edit, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Km attuali: ${component.currentKm.toStringAsFixed(0)} km',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Conferma sostituzione'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      // Record this replacement in history
      component.addReplacement(ReplacementRecord(
        date: selectedDate,
        kmAtReplacement: component.currentKm,
      ));

      // Reset counter
      component.currentKm = 0.0;
      component.lastMaintenance = selectedDate;

      // Legacy sync
      if (component.name == 'Catena') bike.chainKms = 0.0;
      if (component.name == 'Copertoni') bike.tyreKms = 0.0;

      bike.lastMaintenance = selectedDate;
      await _db.updateBicycle(bike);
    }
  }

  Future<void> _askMechanic(Bicycle bike, String componentName) async {
    final aiService = AIService();

    if (!mounted) return;

    if (!await aiService.isConfigured()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('garage.ai_config_error'.tr())));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String prompt =
        "Ho una bicicletta ${bike.name} (${bike.type}). "
        "Devo fare manutenzione a: $componentName. "
        "Guidami passo dopo passo (max 5 punti) su come controllare l'usura o sostituirlo. "
        "Sii tecnico ma chiaro.";

    try {
      final result = await aiService.getAdvice(
        userQuestion: prompt,
        useHealthContext: false,
      );

      if (!mounted) return;
      Navigator.pop(context);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.build_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'garage.ai_mechanic'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    result['success']
                        ? result['content']
                        : "garage.ai_error".tr(args: [result['error']]),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('common.understood'.tr()),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore AI: $e')));
    }
  }

  Color _getStatusColor(double current, double limit) {
    double percentage = current / limit;
    if (percentage < 0.7) return Colors.green;
    if (percentage < 0.9) return Colors.orange;
    return Colors.red;
  }

  Future<void> _showBicycleDialog({Bicycle? bike}) async {
    final nameController = TextEditingController(text: bike?.name ?? '');
    final typeController = TextEditingController(text: bike?.type ?? 'Road');
    final gearingController = TextEditingController(
      text: bike?.gearingSystem ?? 'Mechanical',
    );
    final kmController = TextEditingController(
      text: bike?.totalKilometers.toStringAsFixed(0) ?? '0',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          bike == null
              ? 'garage.add_bike_title'.tr()
              : 'garage.edit_bike_title'.tr(),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'garage.bike_name_label'.tr(),
                  hintText: 'garage.bike_name_hint'.tr(),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kmController,
                decoration: InputDecoration(
                  labelText: 'garage.total_km_label'.tr(),
                  suffixText: 'km',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: typeController.text,
                decoration: InputDecoration(
                  labelText: 'garage.bike_type_label'.tr(),
                  border: const OutlineInputBorder(),
                ),
                items: ['Road', 'MTB', 'Gravel', 'City', 'E-Bike']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => typeController.text = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: gearingController.text,
                decoration: InputDecoration(
                  labelText: 'garage.transmission_label'.tr(),
                  border: const OutlineInputBorder(),
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
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('garage.name_required'.tr())),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(
              bike == null ? 'garage.add_bike'.tr() : 'common.save'.tr(),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final newBike = bike ?? Bicycle();
      newBike.name = nameController.text;
      newBike.type = typeController.text;
      newBike.gearingSystem = gearingController.text;
      newBike.totalKilometers = double.tryParse(kmController.text) ?? 0.0;

      if (bike == null) {
        newBike.lastMaintenance = DateTime.now();
        // Fetch UserProfile to get definitions
        final profile = await _db.getUserProfile();
        if (profile != null && profile.maintenanceDefinitions.isNotEmpty) {
          // Use global definitions
          newBike.components = profile.maintenanceDefinitions
              .map(
                (def) => BicycleComponent()
                  ..name = def.name
                  ..limitKm = def.defaultInterval ?? 3000.0
                  ..currentKm = 0
                  ..lastMaintenance = DateTime.now(),
              )
              .toList();
        } else {
          // Fallback to legacy
          newBike.applyDefaults();
        }
        await _db.createBicycle(newBike);
      } else {
        await _db.updateBicycle(newBike);
      }

      // _loadBikes(); // Handled by stream
    }
  }

  Future<void> _deleteBicycle(Bicycle bike) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('garage.delete_confirm_title'.tr()),
        content: Text('garage.delete_confirm_body'.tr(args: [bike.name])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (bike.id != null) await _db.deleteBicycle(bike.id!);
    }
  }

  Widget _buildComponentStatus(
    BuildContext context,
    Bicycle bike,
    BicycleComponent component,
  ) {
    final double safeCurrent = component.currentKm.isNaN
        ? 0.0
        : component.currentKm;
    final double safeMax = (component.limitKm.isNaN || component.limitKm == 0)
        ? 1.0
        : component.limitKm;

    final color = _getStatusColor(safeCurrent, safeMax);
    final progress = (safeCurrent / safeMax).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              component.name ?? 'Componente',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${safeCurrent.toStringAsFixed(0)} / ${safeMax.toStringAsFixed(0)} km',
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: color.withOpacity(0.2),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () =>
                  _askMechanic(bike, component.name ?? 'Componente'),
              icon: const Icon(Icons.smart_toy, size: 16),
              label: Text('garage.ai_help_btn'.tr()),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _replaceComponent(bike, component),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                minimumSize: const Size(0, 32),
                side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              icon: const Icon(Icons.swap_horiz, size: 14),
              label: const Text(
                'Sostituisci',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        // Replacement history
        if (component.replacementHistory.isNotEmpty) ...[
          const Divider(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.history, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Storico interventi',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          ...component.replacementHistory.map((record) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.build, size: 12, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd MMM yyyy', 'it_IT').format(record.date),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  '${record.kmAtReplacement.toStringAsFixed(0)} km al momento',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'garage_fab',
        onPressed: () => _showBicycleDialog(),
        icon: const Icon(Icons.add),
        label: Text('garage.add_bike'.tr()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bikes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pedal_bike, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('garage.empty_state'.tr()),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _showBicycleDialog(),
                    child: Text('garage.add_bike'.tr()),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 80,
              ),
              itemCount: _bikes.length,
              itemBuilder: (context, index) {
                final bike = _bikes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ... Image Header ...
                      GestureDetector(
                        onTap: () => _pickImage(bike),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: Stack(
                            children: [
                              Center(
                                child:
                                    (bike.bikeImagePath != null &&
                                        bike.bikeImagePath!.isNotEmpty)
                                    ? Image.file(
                                        File(bike.bikeImagePath!),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (_, _, _) =>
                                            const Icon(Icons.broken_image),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 48,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                          const SizedBox(height: 8),
                                          Text('garage.tap_to_add_photo'.tr()),
                                        ],
                                      ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit')
                                      _showBicycleDialog(bike: bike);
                                    if (value == 'delete') _deleteBicycle(bike);
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit, size: 20),
                                          const SizedBox(width: 8),
                                          Text('common.edit'.tr()),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'common.delete'.tr(),
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  bike.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${bike.totalKilometers.isNaN ? 0.0 : bike.totalKilometers.toStringAsFixed(0)} km',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                ),
                              ],
                            ),
                            Text(
                              bike.type,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),

                            // Dynamic Components List
                            ...bike.components.map(
                              (c) => Column(
                                children: [
                                  _buildComponentStatus(context, bike, c),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),

                            if (bike.components.isEmpty)
                              Text(
                                'garage.no_components'.tr(),
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
