import 'package:flutter/material.dart';
import 'dart:math';

/// Widget showing sarcastic quotes from Il Biciclista when no rides are planned
class BiciclistaWisdom extends StatelessWidget {
  const BiciclistaWisdom({super.key});

  static final List<String> _quotes = [
    "Vedo che la bici è ancora pulita. O sei un maniaco dell'ordine o oggi hai preferito il divano. Nel secondo caso, sappi che la catena sta piangendo.",
    "Il meteo dice sole, le tue gambe dicono sì, ma il tuo GPS segna zero km. Cos'è, hai perso le scarpe o aspetti che la salita venga da te?",
    "Guardare i video dei professionisti su YouTube non conta come allenamento, sai? Muovi quel rapportone!",
    "C'è chi scollina e chi sta in cucina. Tu oggi a quale categoria appartieni?",
    "Ricorda: non esiste il cattivo tempo, esiste solo il ciclista che ha paura di sporcare la divisa nuova.",
    "Hai un HRV da atleta olimpico e sei ancora lì a fissare lo schermo? Vai fuori a farti venire il fiatone!",
    "La tua bici in garage sta iniziando a fare amicizia con i ragni. Vedi di rimediare prima che aprano un mutuo sul telaio.",
    "Se aspetti la giornata perfetta per uscire, finirai per pedalare solo a Ferragosto. Forza, che il fango fa bene alla pelle!",
    "Vedo che non hai pianificato nulla. Il tuo spirito agonistico è andato in vacanza o è solo rimasto sotto le coperte?",
    "La vita è troppo breve per pedalare con la sella bassa e la pancia piena. Esci e fai vedere a quel segmento chi comanda!",
  ];

  String _getRandomQuote() {
    return _quotes[Random().nextInt(_quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    final quote = _getRandomQuote();

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
                Icon(
                  Icons.directions_bike,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 28,
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
            Text(
              '"$quote"',
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
