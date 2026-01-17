import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/bicycle.dart';
import '../services/database_service.dart';
import 'dashboard_screen.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final DatabaseService _db = DatabaseService();
  
  int _currentPage = 0;
  
  // Profile Data
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  double _thermalSensitivity = 3.0;
  
  // Bike Data
  final _bikeNameController = TextEditingController();
  String _bikeType = 'Road';
  final _bikeKmController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _bikeNameController.dispose();
    _bikeKmController.dispose();
    super.dispose();
  }

  void _nextPage() {
    debugPrint('Next page button pressed. Current page: $_currentPage');
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    debugPrint('Completing onboarding...');
    try {
      // 1. Save User Profile
      final profile = UserProfile()
        ..name = _nameController.text.isEmpty ? 'Ciclista' : _nameController.text
        ..age = int.tryParse(_ageController.text) ?? 30
        ..weight = double.tryParse(_weightController.text) ?? 75.0
        ..thermalSensitivity = _thermalSensitivity.toInt()
        ..restingHeartRate = 60 // Default base value
        ..functionalThresholdPower = 150 // Default base value
        ..preferredUnit = 'km'; // Default
      
      debugPrint('Saving profile...');
      await _db.saveUserProfile(profile);
      debugPrint('Profile saved.');

      // 2. Save First Bicycle
      final bike = Bicycle()
        ..name = _bikeNameController.text.isEmpty ? 'My First Bike' : _bikeNameController.text
        ..type = _bikeType
        ..gearingSystem = 'Mechanical' // Default
        ..lastMaintenance = DateTime.now() // Default
        ..totalKilometers = double.tryParse(_bikeKmController.text) ?? 0.0;
        
      bike.applyDefaults(); // Apply threshold defaults based on type
      
      debugPrint('Saving bike...');
      await _db.createBicycle(bike);
      debugPrint('Bike saved.');

      if (mounted) {
        debugPrint('Navigating to Main App...');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        ); // Fixed: Navigate to Main shell, not just Dashboard
      }
    } catch (e, stack) {
      debugPrint('Error completing onboarding: $e');
      debugPrint(stack.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 3,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Indietro'),
                    )
                  else
                    const SizedBox.shrink(),
                  FilledButton.icon(
                    onPressed: _nextPage,
                    icon: Icon(_currentPage == 2 ? Icons.check : Icons.arrow_forward),
                    label: Text(_currentPage == 2 ? 'Fine' : 'Avanti'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parlaci di te',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Utilizziamo questi dati per personalizzare i consigli per le tue pedalate.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: 'Età',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cake),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Peso (kg)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.monitor_weight),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calibrazione Biciclista',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Quanto soffri il freddo? (1: Mai, 5: Sempre)',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 64),
          Center(
            child: Text(
              _thermalSensitivity.toInt().toString(),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _thermalSensitivity,
            min: 1,
            max: 5,
            divisions: 4,
            label: _thermalSensitivity.round().toString(),
            onChanged: (value) => setState(() => _thermalSensitivity = value),
          ),
          const SizedBox(height: 48),
          _buildSensitivityHint(),
        ],
      ),
    );
  }

  Widget _buildSensitivityHint() {
    String hint = "";
    IconData icon = Icons.thermostat;
    if (_thermalSensitivity <= 1) {
      hint = "Sono un orso polare. Pantaloncini anche a 5°C.";
      icon = Icons.ac_unit;
    } else if (_thermalSensitivity <= 2) {
      hint = "Gestisco bene il freddo.";
      icon = Icons.cloud_outlined;
    } else if (_thermalSensitivity <= 3) {
      hint = "Resistenza standard.";
      icon = Icons.thermostat;
    } else if (_thermalSensitivity <= 4) {
      hint = "Preferisco vestirmi a strati.";
      icon = Icons.wb_sunny_outlined;
    } else {
      hint = "Sempre gelato. Doppia giacca, grazie.";
      icon = Icons.local_fire_department;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(child: Text(hint)),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'La tua prima bici',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Aggiungi il tuo mezzo principale per iniziare.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _bikeNameController,
            decoration: const InputDecoration(
              labelText: 'Nome Bici',
              border: OutlineInputBorder(),
              hintText: 'es. Specialized Tarmac',
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _bikeType,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
            items: ['Road', 'MTB', 'Gravel', 'E-Bike']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _bikeType = v!),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _bikeKmController,
            decoration: const InputDecoration(
              labelText: 'KM Totali Attuali',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
