import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/ai_service.dart';

class AnonimaCiclistiStrip extends StatefulWidget {
  const AnonimaCiclistiStrip({super.key});

  @override
  State<AnonimaCiclistiStrip> createState() => _AnonimaCiclistiStripState();
}

class _AnonimaCiclistiStripState extends State<AnonimaCiclistiStrip> {
  final _aiService = AIService();
  String? _comicPath;
  String _activityLevel = 'avg';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComic();
  }

  Future<void> _loadComic() async {
    try {
      final path = await _aiService.getDailyComicPath();
      final level = await _aiService.getCommunityActivityLevel();
      
      debugPrint('[ComicStrip] Loading path: $path, Activity Level: $level');
      
      if (mounted) {
        setState(() {
          _comicPath = path;
          _activityLevel = level;
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

  Future<void> _shareComic() async {
    if (_comicPath == null) return;
    
    // In a real app, we might need to share the file bytes or a URL.
    // For assets, we typically share the image with a message.
    await Share.share(
      'Guarda la striscia di oggi dell\'Anonima Ciclisti! 😂 #biciclista #cyclinglife',
      subject: 'Anonima Ciclisti - La Striscia Quotidiana',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          'strip.subtitle_$_activityLevel'.tr(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              Image.asset(
                _comicPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined, size: 48),
                    ),
                  );
                },
              )
            else
              const SizedBox(
                height: 100,
                child: Center(child: Text('Nessuna striscia disponibile per oggi.')),
              ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Text(
                'strip.footer'.tr(),
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
