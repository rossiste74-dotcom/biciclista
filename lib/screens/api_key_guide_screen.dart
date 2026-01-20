import 'package:flutter/material.dart';
import '../models/ai_provider.dart';

/// Screen showing step-by-step guide to get API keys
class APIKeyGuideScreen extends StatelessWidget {
  const APIKeyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Come Ottenere una API Key'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildIntroCard(context),
          const SizedBox(height: 24),
          _buildProviderGuide(context, AIProvider.gemini),
          const SizedBox(height: 16),
          _buildProviderGuide(context, AIProvider.openai),
          const SizedBox(height: 16),
          _buildProviderGuide(context, AIProvider.claude),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cosa sono le API Keys?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Le API keys sono "chiavi" che ti permettono di usare l\'intelligenza artificiale direttamente dai fornitori. '
              'Con BICICLISTICO, usi la TUA chiave personale, quindi:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            _buildBullet(context, '✓ Massima privacy (i dati restano sul tuo telefono)'),
            _buildBullet(context, '✓ Paghi solo quello che usi'),
            _buildBullet(context, '✓ Alcuni provider hanno piani gratuiti generosi'),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildProviderGuide(BuildContext context, AIProvider provider) {
    return Card(
      child: ExpansionTile(
        leading: Icon(
          _getProviderIcon(provider),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          provider.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_getProviderSubtitle(provider)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _getProviderSteps(context, provider),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProviderIcon(AIProvider provider) {
    switch (provider) {
      case AIProvider.gemini:
        return Icons.auto_awesome;
      case AIProvider.openai:
        return Icons.psychology;
      case AIProvider.claude:
        return Icons.smart_toy;
      case AIProvider.deepseek:
        return Icons.rocket_launch;
    }
  }

  String _getProviderSubtitle(AIProvider provider) {
    switch (provider) {
      case AIProvider.gemini:
        return 'CONSIGLIATO - Piano gratuito generoso';
      case AIProvider.openai:
        return 'Popolare - Da \$0.15 per 1M token';
      case AIProvider.claude:
        return 'Potente - Da \$3 per 1M token';
      case AIProvider.deepseek:
        return 'ECONOMICO - Performance elevate a bassissimo costo';
    }
  }

  List<Widget> _getProviderSteps(BuildContext context, AIProvider provider) {
    switch (provider) {
      case AIProvider.gemini:
        return [
          _buildStepTitle(context, '1️⃣ Vai al sito Google AI Studio'),
          _buildStepDescription(context, 'Apri il browser e vai su:'),
          _buildLink(context, 'aistudio.google.com/app/apikey'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '2️⃣ Accedi con il tuo account Google'),
          _buildStepDescription(context, 'Usa il tuo account Gmail personale (è gratuito).'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '3️⃣ Crea una nuova API key'),
          _buildStepDescription(context, 'Clicca su "Create API key" o "Get API key".'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '4️⃣ Copia la chiave'),
          _buildStepDescription(context, 'Apparirà una stringa tipo "AIzaSyC...". Copiala completamente.'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '5️⃣ Incolla in BICICLISTICO'),
          _buildStepDescription(context, 'Torna qui, seleziona "Google Gemini" e incolla la chiave.'),
          const SizedBox(height: 16),
          _buildCostCard(context, '💰 Gemini 2.5 Flash: Veloce, economico e molto capace - piano gratuito!'),
        ];
      
      case AIProvider.openai:
        return [
          _buildStepTitle(context, '1️⃣ Vai su OpenAI Platform'),
          _buildLink(context, 'platform.openai.com/api-keys'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '2️⃣ Crea un account'),
          _buildStepDescription(context, 'Serve email e numero di telefono per verificare.'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '3️⃣ Aggiungi credito'),
          _buildStepDescription(context, 'Minimo \$5. Ti basteranno per centinaia di consigli!'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '4️⃣ Crea API key'),
          _buildStepDescription(context, 'Nella sezione "API keys", clicca "+ Create new secret key".'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '5️⃣ Copia e incolla'),
          _buildStepDescription(context, 'La chiave inizia con "sk-...". Salvala subito, non la vedrai più!'),
          const SizedBox(height: 16),
          _buildCostCard(context, '💰 GPT-4o mini: circa \$0.15 per 1M token (~1000 consigli con \$1)'),
        ];
      
      case AIProvider.claude:
        return [
          _buildStepTitle(context, '1️⃣ Vai su Anthropic Console'),
          _buildLink(context, 'console.anthropic.com'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '2️⃣ Registrati'),
          _buildStepDescription(context, 'Serve email aziendale o verifica con carta di credito.'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '3️⃣ Aggiungi credito'),
          _buildStepDescription(context, 'Minimo \$5. Claude è il più costoso ma molto potente.'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '4️⃣ Crea API key'),
          _buildStepDescription(context, 'Vai in "API Keys" → "Create Key".'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '5️⃣ Copia e salva'),
          _buildStepDescription(context, 'La chiave inizia con "sk-ant-...".'),
          const SizedBox(height: 16),
          _buildCostCard(context, '💰 Claude Sonnet: circa \$3 per 1M token (~500 consigli con \$5)'),
        ];
      
      case AIProvider.deepseek:
        return [
          _buildStepTitle(context, '1️⃣ Vai su DeepSeek Platform'),
          _buildLink(context, 'platform.deepseek.com'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '2️⃣ Registrati'),
          _buildStepDescription(context, 'Crea un account (spesso serve numero di telefono).'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '3️⃣ Crea API Key'),
          _buildStepDescription(context, 'Vai nella sezione "API Keys" e clicca "Create API Key".'),
          const SizedBox(height: 12),
          _buildStepTitle(context, '4️⃣ Copia e Salva'),
          _buildStepDescription(context, 'Copia la chiave (sk-...) e incollala in BICICLISTICO.'),
          const SizedBox(height: 16),
          _buildCostCard(context, '💰 DeepSeek Chat: Estremamente economico (~100x meno di GPT-4)'),
        ];
    }
  }

  Widget _buildStepTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStepDescription(BuildContext context, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 4),
      child: Text(
        description,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildLink(BuildContext context, String url) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 4),
      child: Text(
        url,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCostCard(BuildContext context, String cost) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cost,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
