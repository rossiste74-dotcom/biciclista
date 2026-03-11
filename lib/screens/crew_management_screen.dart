import 'package:flutter/material.dart';

class CrewManagementScreen extends StatelessWidget {
  const CrewManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestione Crew (Presidente)')),
      body: const Center(
        child: Text('Interfaccia per promuovere Capitani e gestire la Crew...'),
      ),
    );
  }
}
