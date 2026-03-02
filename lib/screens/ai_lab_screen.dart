import 'package:flutter/material.dart';
import '../widgets/ai_coach_card.dart';
import '../widgets/biomechanics_card.dart';

class AiLabScreen extends StatelessWidget {
  const AiLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratorio AI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Text(
              'Benvenuto nel Laboratorio AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Qui trovi tutti gli strumenti avanzati basati sull\'Intelligenza Artificiale per migliorare le tue performance in bicicletta.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            AICoachCard(),
            SizedBox(height: 24),
            BiomechanicsCard(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
