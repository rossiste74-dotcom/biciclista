import 'package:easy_localization/easy_localization.dart';
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
          _wisdom = "wisdom.fallback".tr();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: const AssetImage('assets/butler_avatar.png'),
                  child: const Align(
                    alignment: Alignment.bottomRight,
                    child:
                        SizedBox(), // Fallback handled by background image failing gracefully
                  ),
                  onBackgroundImageError: (_, _) {
                    // This callback allows us to handle errors without crashing
                    debugPrint('Error loading butler avatar');
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'wisdom.title'.tr(),
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
                _wisdom != null ? '"$_wisdom"' : '"${"wisdom.loading".tr()}"',
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
                'wisdom.subtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
