import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../screens/ai_coach_screen.dart';

/// AI Coach card for the dashboard
class AICoachCard extends StatefulWidget {
  const AICoachCard({super.key});

  @override
  State<AICoachCard> createState() => _AICoachCardState();
}

class _AICoachCardState extends State<AICoachCard> {
  final _aiService = AIService();
  bool _isConfigured = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkConfiguration();
  }

  Future<void> _checkConfiguration() async {
    final configured = await _aiService.isConfigured();
    if (mounted) {
      setState(() {
        _isConfigured = configured;
        _isLoading = false;
      });
    }
  }

  /// Reload configuration status (can be called externally)
  Future<void> reload() async {
    setState(() => _isLoading = true);
    await _checkConfiguration();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_isConfigured) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AICoachScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Coach',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chiedi consigli personalizzati',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
