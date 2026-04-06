import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:biciclistico/services/ai_service.dart';
import 'package:biciclistico/services/database_service.dart';
import 'package:biciclistico/models/user_profile.dart';
import 'package:image_picker/image_picker.dart';

class AnonimaCiclistiStrip extends StatefulWidget {
  const AnonimaCiclistiStrip({super.key});

  @override
  State<AnonimaCiclistiStrip> createState() => _AnonimaCiclistiStripState();
}

class _AnonimaCiclistiStripState extends State<AnonimaCiclistiStrip> {
  final _aiService = AIService();
  final _db = DatabaseService();
  final _promptController = TextEditingController();

  String? _comicPath;
  String _activityLevel = 'avg';
  bool _isLoading = true;
  bool _isSavingPrompt = false;
  bool _isUploading = false;
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadComic();
  }

  Future<void> _loadComic() async {
    try {
      final path = await _aiService.getDailyComicPath();
      final level = await _aiService.getCommunityActivityLevel();
      final user = await _db.getUserProfile();

      String? currentPrompt;
      if (user?.role == UserRole.presidente ||
          user?.role == UserRole.capitano) {
        currentPrompt = await _db.getDailyComicPrompt(DateTime.now());
        if (currentPrompt != null) {
          _promptController.text = currentPrompt;
        }
      }

      debugPrint(
        '[ComicStrip] Loading path: $path, Activity Level: $level, Role: ${user?.role}',
      );

      if (mounted) {
        setState(() {
          _comicPath = path;
          _activityLevel = level;
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[ComicStrip] Error loading comic: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePrompt() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() => _isSavingPrompt = true);
    try {
      // 1. Save prompt to cloud
      await _db.saveDailyComicPrompt(
        DateTime.now(),
        _promptController.text.trim(),
      );

      // 2. Trigger immediate regeneration
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Storia salvata! L\'AI sta disegnando la nuova striscia...',
            ),
          ),
        );
      }

      final success = await _aiService.regenerateDailyComic();

      if (success && mounted) {
        setState(() => _isLoading = true);
        await _loadComic(); // Ricarica la striscia (il percorso rimarrà simile o punterà a una nuova versione)

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ehilà! La nuova striscia è pronta!')),
          );
        }
      }
    } catch (e) {
      debugPrint('[ComicStrip] Error saving prompt: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore durante il salvataggio o la generazione.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingPrompt = false);
      }
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      final bytes = await image.readAsBytes();
      final fileName = 'upload_${DateTime.now().millisecondsSinceEpoch}.png';

      final url = await _db.uploadDailyComicImage(
        DateTime.now(),
        bytes,
        fileName,
      );

      if (url != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Immagine caricata con successo!')),
        );
        setState(() => _isLoading = true);
        await _loadComic();
      }
    } catch (e) {
      debugPrint('[ComicStrip] Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore durante l\'upload dell\'immagine.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _shareComic() async {
    if (_comicPath == null) return;

    // For assets, we typically share the image with a message.
    await Share.share(
      'Guarda la striscia di oggi dell\'Anonima Ciclisti! 😂 #biciclista #cyclinglife',
      subject: 'Anonima Ciclisti - La Striscia Quotidiana',
    );
  }

  String _getLocalizedSubtitle() {
    final key = 'strip.subtitle_$_activityLevel';
    final localized = key.tr();
    if (localized == key) {
      // Fallback if key not found in assets yet
      switch (_activityLevel) {
        case 'lazy':
          return 'Speciale: Equipaggio in letargo 🛋️';
        case 'pro':
          return 'Speciale: Gambe in fiamme! 🔥';
        default:
          return 'La striscia quotidiana';
      }
    }
    return localized;
  }

  String _getLocalizedFooter() {
    const key = 'strip.footer';
    final localized = key.tr();
    return (localized == key) ? 'La motivazione è facoltativa.' : localized;
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      height: 200,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ANONIMA CICLISTI',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          _getLocalizedSubtitle(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _shareComic,
                    icon: Icon(
                      Icons.share_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 22,
                    ),
                    tooltip: 'Condividi',
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_comicPath != null)
              Builder(
                builder: (context) {
                  final isNetwork = _comicPath!.startsWith('http');
                  final imageKey = ValueKey(
                    _comicPath! +
                        DateTime.now().millisecondsSinceEpoch.toString(),
                  );

                  if (isNetwork) {
                    return Image.network(
                      _comicPath!,
                      key: imageKey,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorPlaceholder(context),
                    );
                  } else {
                    return Image.asset(
                      _comicPath!,
                      key: imageKey,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorPlaceholder(context),
                    );
                  }
                },
              )
            else
              const SizedBox(
                height: 100,
                child: Center(
                  child: Text('Nessuna striscia disponibile per oggi.'),
                ),
              ),
            if (_comicPath != null &&
                (_currentUser?.role == UserRole.presidente ||
                    _currentUser?.role == UserRole.capitano))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'IDEA PER LA STORIA DI OGGI',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText:
                            'Esempio: MarcoTrek si perde cercando una scorciatoia...',
                        hintStyle: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        SizedBox(
                          width: 200, // Sufficient width for the button
                          child: ElevatedButton.icon(
                            onPressed: _isSavingPrompt ? null : _savePrompt,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                            icon: _isSavingPrompt
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.auto_awesome_outlined,
                                    size: 18,
                                  ),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isSavingPrompt
                                    ? 'Generando...'
                                    : 'Aggiorna Storia AI',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 200, // Sufficient width for the button
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : _uploadImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                            icon: _isUploading
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.upload_file_outlined,
                                    size: 18,
                                  ),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isUploading
                                    ? 'Caricamento...'
                                    : 'Carica Immagine',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () async {
                            final statsStr = await _aiService
                                .getCommunityAIContext();
                            final fullPrompt = await _aiService
                                .getFullDailyComicPrompt();
                            final scenario = await _db.getDailyComicScenario(
                              DateTime.now(),
                            );

                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Contesto e Prompt AI'),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'DATI DELLA COMMUNITY:',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            statsStr,
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 12,
                                            ),
                                          ),
                                          const Divider(height: 24),

                                          Text(
                                            'SCENARIO GENERATO (Prompt Immagine):',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer
                                                  .withValues(alpha: 0.3),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Text(
                                              scenario ??
                                                  'Generazione in corso o non disponibile...',
                                              style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const Divider(height: 24),

                                          Text(
                                            'FULL PROMPT SENT TO AI:',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              fullPrompt,
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Rigenerazione scenario in corso...',
                                              ),
                                            ),
                                          );
                                          Navigator.pop(
                                            context,
                                          ); // Chiudi la dialog
                                        }
                                        final success = await _aiService
                                            .regenerateDailyScenarioOnly();
                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Scenario rigenerato con successo! Riapri la finestra per vederlo.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Rigenera scenario'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final textToCopy =
                                            scenario ??
                                            'Generazione in corso o non disponibile...';
                                        await Clipboard.setData(
                                          ClipboardData(text: textToCopy),
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Scenario copiato negli appunti! Ora incollalo su Gemini.',
                                              ),
                                            ),
                                          );
                                        }
                                        final url = Uri.parse(
                                          'https://gemini.google.com/app',
                                        );
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      },
                                      child: const Text('Apri in Gemini'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Chiudi'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          tooltip: 'Vedi dati e prompt AI',
                          icon: const Icon(Icons.info_outline, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Text(
                _getLocalizedFooter(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
