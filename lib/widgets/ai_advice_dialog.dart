import 'package:flutter/material.dart';
import '../services/ai_service.dart';

/// Dialog for interacting with AI Coach
class AIAdviceDialog extends StatefulWidget {
  const AIAdviceDialog({super.key});

  @override
  State<AIAdviceDialog> createState() => _AIAdviceDialogState();
}

class _AIAdviceDialogState extends State<AIAdviceDialog> {
  final _aiService = AIService();
  final _questionController = TextEditingController();
  
  bool _isLoading = false;
  String? _response;
  String? _error;

  final List<String> _exampleQuestions = [
    'Posso fare il giro oggi?',
    'Che intensità mi consigli?',
    'Cosa indosso per il prossimo giro?',
    'Come miglioro il mio HRV?',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _getAdvice() async {
    if (_questionController.text.trim().isEmpty) {
      setState(() {
        _error = 'Inserisci una domanda';
        _response = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _response = null;
    });

    final result = await _aiService.getAdvice(
      userQuestion: _questionController.text,
    );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _response = result['content'];
      } else {
        _error = result['error'] ?? 'Errore sconosciuto';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: screenHeight * 0.85, // Dynamic max height
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView( // Make content scrollable
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Coach',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Chiedi un consiglio personalizzato in base ai tuoi dati biometrici, meteo e percorsi.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _exampleQuestions.map((q) {
                  return ActionChip(
                    label: Text(q),
                    onPressed: () {
                      _questionController.text = q;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'La tua domanda',
                  hintText: 'es: Posso fare il giro oggi?',
                  border: const OutlineInputBorder(),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                maxLines: 2,
                enabled: !_isLoading,
                onSubmitted: (_) => _getAdvice(),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isLoading ? null : _getAdvice,
                icon: const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? 'Generando...' : 'Chiedi al Butler'),
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_response != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Consiglio',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _response!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Fai una domanda per ricevere\nconsigli personalizzati',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
