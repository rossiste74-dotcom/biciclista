import 'package:flutter/material.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guida all\'Utilizzo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeroSection(context),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Dati Biometrici & Salute'),
          _buildGuideCard(
            context,
            title: 'HRV (Variabilità Battito Cardiaco)',
            icon: Icons.favorite,
            color: Colors.red,
            content: 'L\'HRV è l\'indicatore principale del recupero. Un valore alto indica un sistema nervoso equilibrato e pronto allo sforzo. Un calo improvviso suggerisce stress, stanchezza o inizio di malessere. Monitoralo al mattino per decidere l\'intensità dell\'allenamento.',
          ),
          _buildGuideCard(
            context,
            title: 'Readiness Score',
            icon: Icons.bolt,
            color: Colors.orange,
            content: 'Il punteggio di "Prontezza" combina HRV, qualità del sonno e trend recenti. \n\n'
                '• 80-100: Sei al top! Ideale per salite dure o gare.\n'
                '• 50-79: Buona forma, procedi con l\'allenamento previsto.\n'
                '• Sotto 50: Considera un giro di scarico o riposo attivo.',
          ),
          _buildGuideCard(
            context,
            title: 'Sonno e Recupero',
            icon: Icons.bed,
            color: Colors.indigo,
            content: 'Il sonno è dove avviene la riparazione muscolare. Biciclistico analizza le ore di sonno per regolare i consigli sull\'abbigliamento e sull\'intensità. Cerca di mantenere una media costante per migliorare la tua precisione AI.',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Funzionalità Principali'),
          _buildGuideCard(
            context,
            title: 'Importazione GPX',
            icon: Icons.map,
            color: Colors.blue,
            content: 'Puoi caricare percorsi GPX da Strava, Komoot o Garmin. L\'app analizzerà pendenze e dislivelli per suggerirti l\'abbigliamento perfetto e calcolare la difficoltà del giro.',
          ),
          _buildGuideCard(
            context,
            title: 'Manutenzione Intelligente',
            icon: Icons.build,
            color: Colors.grey,
            content: 'Ogni km che percorri viene scalato dai componenti della tua bici (catena, copertoni, ecc.). Quando la barra diventa rossa, è il momento di un controllo! Chiedi al "Meccanico AI" istruzioni su come procedere.',
          ),
          _buildGuideCard(
            context,
            title: 'AI Coach & Meccanico',
            icon: Icons.psychology,
            color: Colors.purple,
            content: 'Il Coach analizza meteo e biometria per dirti cosa indossare. Il Meccanico ti guida nelle riparazioni. Ricorda di inserire la tua "Chiave API" nelle impostazioni per sbloccare queste funzioni.',
          ),
          const SizedBox(height: 32),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_bike, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            'Benvenuto su Biciclistico',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'La tua centrale operativa per il ciclismo consapevole. Qui impari come interpretare i tuoi dati per pedalare meglio.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Buone Pedalate!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
