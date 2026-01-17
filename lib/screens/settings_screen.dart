import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/backup_service.dart';
import 'profile_screen.dart';
import 'clothing_settings_screen.dart';
import 'maintenance_settings_screen.dart';
import 'navigation_settings_screen.dart';
import 'ai_settings_screen.dart';
import 'user_guide_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backupService = BackupService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.checkroom),
            title: const Text('Soglie Abbigliamento'),
            subtitle: const Text('Personalizza le temperature del "Biciclista"'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ClothingSettingsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.explore_outlined),
            title: const Text('Navigazione'),
            subtitle: const Text('GPS, bussola e alert di sicurezza'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NavigationSettingsScreen()),
            ),
          ),
          const Divider(),
          _buildHeader(context, 'Manutenzione'),
          ListTile(
            leading: const Icon(Icons.build_circle_outlined),
            title: const Text('Componenti & Soglie'),
            subtitle: const Text('Gestisci intervalli e nuovi componenti'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MaintenanceSettingsScreen()),
            ),
          ),
          const Divider(),
          _buildHeader(context, 'AI Coach'),
          ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('Configurazione AI'),
            subtitle: const Text('Bring Your Own Key (OpenAI, Claude, Gemini)'),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AISettingsScreen()),
              );
              // If AI config changed, pop with result
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          const Divider(),
          _buildHeader(context, 'Gestione Dati'),
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('Esporta Backup'),
            subtitle: const Text('Salva il database come file JSON'),
            onTap: () async {
              try {
                await backupService.exportBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup esportato con successo')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Esportazione fallita: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_open_outlined),
            title: const Text('Importa Backup'),
            subtitle: const Text('Ripristina il database da un file JSON'),
            onTap: () => _confirmImport(context, backupService),
          ),
          _buildHeader(context, 'Supporto & Guida'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Guida all\'Utilizzo'),
            subtitle: const Text('Scopri come usare l\'app e i dati biometrici'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserGuideScreen()),
            ),
          ),
          const Divider(),
          _buildHeader(context, 'Informazioni App'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Versione'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Sviluppato con'),
            trailing: Text('Isar & OpenStreetMap'),
          ),
          const SizedBox(height: 32),
          Center(
            child: Opacity(
              opacity: 0.8,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Image.asset(
                  'assets/log1.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _confirmImport(BuildContext context, BackupService service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confermare il ripristino?'),
        content: const Text(
          'Tutti i dati correnti verranno sovrascritti. L\'azione è irreversibile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ripristina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        try {
          await service.importBackup(content);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Database ripristinato! Per favore riavvia l\'app.')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Importazione fallita: $e')),
            );
          }
        }
      }
    }
  }
}
