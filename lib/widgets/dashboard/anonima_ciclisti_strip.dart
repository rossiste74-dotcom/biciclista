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
  List<String> _comicPaths = [];
  int _currentPage = 0;
  String _activityLevel = 'avg';
  bool _isLoading = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadComic();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadComic() async {
    try {
      final paths = await _aiService.getDailyComicPaths();
      final level = await _aiService.getCommunityActivityLevel();
      
      debugPrint('[ComicStrip] Loading paths: $paths, Activity Level: $level');
      
      if (mounted) {
        setState(() {
          _comicPaths = paths;
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
    if (_comicPaths.isEmpty) return;
    
    final currentComic = _comicPaths[_currentPage];
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
        case 'lazy': return 'Speciale: Equipaggio in letargo 🛋️';
        case 'pro': return 'Speciale: Gambe in fiamme! 🔥';
        default: return 'La striscia quotidiana';
      }
    }
    return localized;
  }

  String _getLocalizedFooter() {
    const key = 'strip.footer';
    final localized = key.tr();
    return (localized == key) ? 'La motivazione è facoltativa.' : localized;
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
                          _getLocalizedSubtitle(),
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
            else if (_comicPaths.isNotEmpty)
              Stack(
                children: [
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _comicPaths.length,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        return Image.asset(
                          _comicPaths[index],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined, size: 48),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  if (_comicPaths.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _comicPaths.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentPage == index ? 20 : 6,
                            decoration: BoxDecoration(
                              color: _currentPage == index 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Swipe hints
                  if (_currentPage == 0 && _comicPaths.length > 1)
                    Positioned(
                      right: 12,
                      top: 0,
                      bottom: 0,
                      child: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                ],
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
