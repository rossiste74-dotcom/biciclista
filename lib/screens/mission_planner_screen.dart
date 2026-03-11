import 'package:flutter/material.dart';

class MissionPlannerScreen extends StatelessWidget {
  const MissionPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pianificatore di Missioni')),
      body: const Center(
        child: Text('Interfaccia di creazione eventi.\nCaricamento GPX e notifiche in arrivo...'),
      ),
    );
  }
}
