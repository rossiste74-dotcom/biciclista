import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/clothing_item.dart';
import '../services/database_service.dart';

class ClothingSettingsScreen extends StatefulWidget {
  const ClothingSettingsScreen({super.key});

  @override
  State<ClothingSettingsScreen> createState() => _ClothingSettingsScreenState();
}

class _ClothingSettingsScreenState extends State<ClothingSettingsScreen> {
  final _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  UserProfile? _profile;

  // Controllers
  final _hotController = TextEditingController();
  final _warmController = TextEditingController();
  final _coolController = TextEditingController();
  final _coldController = TextEditingController();
  final _adjustmentController = TextEditingController();
  final _distWeightController = TextEditingController();
  final _elevWeightController = TextEditingController();

  // Kit lists (indexes)
  List<int> _hotKit = [];
  List<int> _warmKit = [];
  List<int> _coolKit = [];
  List<int> _coldKit = [];
  List<int> _veryColdKit = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _hotController.dispose();
    _warmController.dispose();
    _coolController.dispose();
    _coldController.dispose();
    _adjustmentController.dispose();
    _distWeightController.dispose();
    _elevWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await _db.getUserProfile();
    if (profile != null) {
      setState(() {
        _profile = profile;
        _hotController.text = profile.hotThreshold.toString();
        _warmController.text = profile.warmThreshold.toString();
        _coolController.text = profile.coolThreshold.toString();
        _coldController.text = profile.coldThreshold.toString();
        _adjustmentController.text = profile.sensitivityAdjustment.toString();
        _distWeightController.text = profile.difficultyDistanceWeight.toString();
        _elevWeightController.text = profile.difficultyElevationWeight.toString();
        _hotKit = List<int>.from(profile.hotKit);
        _warmKit = List<int>.from(profile.warmKit);
        _coolKit = List<int>.from(profile.coolKit);
        _coldKit = List<int>.from(profile.coldKit);
        _veryColdKit = List<int>.from(profile.veryColdKit);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = _profile ?? UserProfile();
    profile.hotThreshold = double.parse(_hotController.text);
    profile.warmThreshold = double.parse(_warmController.text);
    profile.coolThreshold = double.parse(_coolController.text);
    profile.coldThreshold = double.parse(_coldController.text);
    profile.sensitivityAdjustment = double.parse(_adjustmentController.text);
    profile.difficultyDistanceWeight = double.parse(_distWeightController.text);
    profile.difficultyElevationWeight = double.parse(_elevWeightController.text);
    profile.hotKit = _hotKit;
    profile.warmKit = _warmKit;
    profile.coolKit = _coolKit;
    profile.coldKit = _coldKit;
    profile.veryColdKit = _veryColdKit;
    profile.updatedAt = DateTime.now();

    await _db.saveUserProfile(profile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Soglie aggiornate con successo!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni Algoritmi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Temperature di Soglia (°C)'),
                    _buildThresholdItem(
                      'Kit Estivo (Caldo)',
                      'Sopra ${_hotController.text}°C',
                      _hotController,
                      Icons.wb_sunny_outlined,
                      _hotKit,
                      (val) => setState(() => _hotKit = val),
                    ),
                    _buildThresholdItem(
                      'Kit Mite (Veste gilet)',
                      'Tra ${_warmController.text} e ${_hotController.text}°C',
                      _warmController,
                      Icons.wb_cloudy_outlined,
                      _warmKit,
                      (val) => setState(() => _warmKit = val),
                    ),
                    _buildThresholdItem(
                      'Kit Fresco (Manica Lunga)',
                      'Tra ${_coolController.text} e ${_warmController.text}°C',
                      _coolController,
                      Icons.ac_unit_outlined,
                      _coolKit,
                      (val) => setState(() => _coolKit = val),
                    ),
                    _buildThresholdItem(
                      'Kit Freddo (Giacca Leggera)',
                      'Tra ${_coldController.text} e ${_coolController.text}°C',
                      _coldController,
                      Icons.severe_cold,
                      _coldKit,
                      (val) => setState(() => _coldKit = val),
                    ),
                    _buildThresholdItem(
                      'Kit Invernale (Sotto soglia)',
                      'Sotto ${_coldController.text}°C',
                      null,
                      Icons.ac_unit,
                      _veryColdKit,
                      (val) => setState(() => _veryColdKit = val),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Sensibilità Personale'),
                    _buildThresholdInput(
                      'Regolazione Sensibilità',
                      'Gradi di correzione per ogni livello dello slider (default: 3°)',
                      _adjustmentController,
                      Icons.tune,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Indice Difficoltà'),
                    _buildThresholdInput(
                      'Peso Chilometri',
                      'Contributo dei KM (default: 0.05)',
                      _distWeightController,
                      Icons.straighten,
                      suffix: '',
                    ),
                    _buildThresholdInput(
                      'Peso Dislivello',
                      'Contributo dei metri D+ (default: 0.008)',
                      _elevWeightController,
                      Icons.terrain,
                      suffix: '',
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _saveSettings,
                        child: const Text('Salva Impostazioni'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _hotController.text = '20.0';
                            _warmController.text = '15.0';
                            _coolController.text = '10.0';
                            _coldController.text = '5.0';
                            _adjustmentController.text = '3.0';
                            _distWeightController.text = '0.05';
                            _elevWeightController.text = '0.008';
                            _hotKit = [0];
                            _warmKit = [0];
                            _coolKit = [0, 4, 2];
                            _coldKit = [8, 5, 3];
                            _veryColdKit = [8, 6, 3, 9, 10, 11];
                          });
                        },
                        child: const Text('Ripristina Default'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Personalizza i gradi a cui vuoi cambiare tipo di vestiti.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Il "Biciclista" userà queste soglie insieme alla tua sensibilità termica per darti consigli su misura.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThresholdItem(
    String title,
    String subtitle,
    TextEditingController? controller,
    IconData icon,
    List<int> currentKit,
    Function(List<int>) onKitChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          if (controller != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildThresholdInput(title, subtitle, controller, icon),
            )
          else
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(subtitle),
            ),
          const Divider(height: 1),
          ListTile(
            dense: true,
            leading: const Icon(Icons.checkroom, size: 20),
            title: Text(
              currentKit.isEmpty
                  ? 'Nessun capo selezionato'
                  : currentKit.map((i) => ClothingItem.values[i].displayName).join(', '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.edit, size: 18),
            onTap: () => _showKitPicker(title, currentKit, onKitChanged),
          ),
        ],
      ),
    );
  }

  void _showKitPicker(String title, List<int> currentKit, Function(List<int>) onKitChanged) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Personalizza $title',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ClothingItem.values.length,
                      itemBuilder: (context, index) {
                        final item = ClothingItem.values[index];
                        final isSelected = currentKit.contains(index);
                        return CheckboxListTile(
                          title: Text(item.displayName),
                          subtitle: Text(item.description),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                currentKit.add(index);
                              } else {
                                currentKit.remove(index);
                              }
                              // Sort to keep UI consistent
                              currentKit.sort();
                            });
                            onKitChanged(currentKit);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fatto'),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildThresholdInput(String label, String help, TextEditingController controller, IconData icon, {String suffix = '°C'}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        helperText: help,
        prefixIcon: Icon(icon),
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (v) => setState(() {}), // Update subtitle in real-time
      validator: (v) {
        if (v == null || v.isEmpty) return 'Obbligatorio';
        if (double.tryParse(v) == null) return 'Numero non valido';
        return null;
      },
    );
  }
}
