import 'package:flutter/material.dart';
import '../services/ai_service.dart';

/// Widget showing the "Community Daily Wisdom" from Il Biciclista
class BiciclistaWisdom extends StatefulWidget {
  const BiciclistaWisdom({super.key});

  @override
  State<BiciclistaWisdom> createState() => _BiciclistaWisdomState();
}

class _BiciclistaWisdomState extends State<BiciclistaWisdom> {
  final _aiService = AIService();
  String? _wisdom;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWisdom();
  }

  Future<void> _loadWisdom() async {
    try {
      final wisdom = await _aiService.getOrGenerateDailyWisdom();
      if (mounted) {
        setState(() {
          _wisdom = wisdom;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _wisdom = "Oggi il saggio è in fuga e non prende il telefono. Riprova domani.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/butler_avatar.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Il Biciclista Dice:',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
               Align(
                alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                       color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
               )
            else
              Text(
                _wisdom != null ? '"$_wisdom"' : '"Pedala e taci."',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Solo per veri biciclisti!!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
