import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Controlla se è disponibile un nuovo aggiornamento guardando la tabella app_versions
  Future<void> checkForUpdates(BuildContext context, {bool manualCheck = false}) async {
    // Check update on Android only, because the CI/CD uploads an APK
    if (!Platform.isAndroid) {
      if (manualCheck && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aggiornamento in-app disponibile solo su Android.')),
        );
      }
      return;
    }

    try {
      // 1. Legge la versione e il build number locali
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      // 2. Interroga Supabase per l'ultima versione disponibile
      final response = await _supabase
          .from('app_versions')
          .select()
          .order('build_number', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        if (manualCheck && context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Sei già all\'ultima versione della crew! 🚴')),
           );
        }
        return;
      }

      final latestBuildNumber = response['build_number'] as int?;
      final apkUrl = response['apk_url'] as String?;

      if (latestBuildNumber == null || apkUrl == null || apkUrl.isEmpty) {
         if (manualCheck && context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Nessuna build disponibile al momento.')),
           );
         }
         return;
      }

      // 3. Confronta i build number
      if (latestBuildNumber > currentBuildNumber) {
        if (context.mounted) {
          _showUpdateDialog(context, apkUrl, response['version_name']?.toString());
        }
      } else {
        if (manualCheck && context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Sei già all\'ultima versione della crew! 🚴')),
           );
        }
      }
    } catch (e) {
      debugPrint('Errore durante il controllo aggiornamenti: $e');
      if (manualCheck && context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Errore: impossibile verificare gli aggiornamenti ($e)')),
         );
      }
    }
  }

  void _showUpdateDialog(BuildContext context, String apkUrl, String? latestVersion) {
    showDialog(
      context: context,
      barrierDismissible: false, // L'utente deve scegliere se aggiornare o no
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.directions_bike, color: Colors.blue),
              SizedBox(width: 8),
              Text('Aggiornamento Bici! 🚴'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nuovi sentieri disponibili! Abbiamo migliorato l\'aerodinamica dell\'app.\n'
                'Aggiorna per visualizzare tutte le novità della crew.',
              ),
              if (latestVersion != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Nuova versione: $latestVersion',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ignora l'aggiornamento
              },
              child: const Text('Resta nel gruppo', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () async {
                final Uri url = Uri.parse(apkUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossibile aprire il link di aggiornamento.')),
                    );
                  }
                }
              },
              child: const Text('Scatta e Aggiorna Ora'),
            ),
          ],
        );
      },
    );
  }
}
