import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/comic_character.dart';
import '../models/user_profile.dart';
import '../models/user_avatar_config.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';

class ComicCharactersScreen extends StatefulWidget {
  const ComicCharactersScreen({super.key});

  @override
  State<ComicCharactersScreen> createState() => _ComicCharactersScreenState();
}

class _ComicCharactersScreenState extends State<ComicCharactersScreen> {
  final _db = DatabaseService();
  final _aiService = AIService();
  bool _isLoading = true;
  bool _isAnalyzing = false;
  bool _isGeneratingPortrait = false;
  List<ComicCharacter> _characters = [];
  UserProfile? _currentUserProfile;
  List<UserProfile> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    setState(() => _isLoading = true);
    try {
      final chars = await _db.getComicCharacters();
      final profile = await _db.getUserProfile();
      List<UserProfile> allUsers = [];
      if (profile != null && (profile.role == UserRole.presidente || profile.role == UserRole.capitano)) {
        allUsers = await _db.getAllProfiles();
      }
      
      setState(() {
        _characters = chars;
        _currentUserProfile = profile;
        _allUsers = allUsers;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel caricamento: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showEditDialog([ComicCharacter? character]) async {
    final nameController = TextEditingController(text: character?.name);
    final descController = TextEditingController(text: character?.description);
    String? currentAvatarUrl = character?.avatarUrl;
    String? currentVisualDesc = character?.visualDescription;
    String? currentLinkedUserId = character?.userId;

    final canAssignUser = _currentUserProfile?.role == UserRole.presidente || _currentUserProfile?.role == UserRole.capitano;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(character == null ? 'Nuovo Personaggio' : 'Modifica Personaggio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _isAnalyzing ? null : () async {
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                    
                    if (image != null) {
                      setDialogState(() => _isAnalyzing = true);
                      try {
                        final bytes = await image.readAsBytes();
                        final charId = character?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
                        final url = await _db.uploadCharacterAvatar(charId, bytes, image.name);
                        
                        if (url != null) {
                          currentAvatarUrl = url;
                          final aiDesc = await _aiService.analyzeCharacterAvatar(url);
                          if (aiDesc != null) {
                            currentVisualDesc = aiDesc;
                            descController.text = aiDesc;
                          }
                        }
                      } finally {
                        setDialogState(() => _isAnalyzing = false);
                      }
                    }
                  },
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      image: currentAvatarUrl != null 
                          ? DecorationImage(image: NetworkImage(currentAvatarUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _isAnalyzing 
                        ? const Center(child: CircularProgressIndicator())
                        : currentAvatarUrl == null 
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 32),
                                  SizedBox(height: 4),
                                  Text('Aggiungi Foto', style: TextStyle(fontSize: 10)),
                                ],
                              )
                            : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome (es. IL PRESIDENTE)'),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione / Caratteristiche',
                    hintText: 'Verrà compilata automaticamente se carichi una foto',
                  ),
                  maxLines: 4,
                ),
                if (canAssignUser) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    value: currentLinkedUserId,
                    decoration: const InputDecoration(labelText: 'Associa Utente'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Nessun utente associato')),
                      ..._allUsers.map((u) => DropdownMenuItem(
                            value: u.id,
                            child: Text(u.name ?? 'Utente Sconosciuto'),
                          )),
                    ],
                    onChanged: (val) {
                      setDialogState(() => currentLinkedUserId = val);
                    },
                  ),
                ],
                if (currentVisualDesc != null || descController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isGeneratingPortrait ? null : () async {
                        setDialogState(() => _isGeneratingPortrait = true);
                        try {
                          final portraitUrl = await _aiService.generateCharacterPortrait(
                            currentVisualDesc ?? descController.text
                          );
                          if (portraitUrl != null) {
                            setDialogState(() => currentAvatarUrl = portraitUrl);
                          }
                        } finally {
                          if (mounted) setDialogState(() => _isGeneratingPortrait = false);
                        }
                      },
                      icon: _isGeneratingPortrait 
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.palette_outlined),
                      label: Text(_isGeneratingPortrait ? 'Generazione...' : 'Genera Ritratto Fumetto'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
            FilledButton(
              onPressed: _isAnalyzing ? null : () => Navigator.pop(context, true),
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final newChar = ComicCharacter(
        id: character?.id ?? '',
        name: nameController.text.trim().toUpperCase(),
        description: descController.text.trim(),
        avatarUrl: currentAvatarUrl,
        visualDescription: currentVisualDesc,
        userId: currentLinkedUserId,
        createdAt: character?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await _db.saveComicCharacter(newChar);

        // Se è associato un utente e c'è un'immagine, aggiorniamo la sua foto avatar!
        if (currentLinkedUserId != null && currentAvatarUrl != null) {
          try {
            final profile = _allUsers.firstWhere(
              (u) => u.id == currentLinkedUserId,
              // Fallback nel caso non fosse in _allUsers (improbabile se l'ha scelto dalla combo)
              orElse: () => UserProfile()..id = '',
            );
            if (profile.id.isNotEmpty) {
              final config = profile.avatarConfig ?? UserAvatarConfig.defaultConfig();
              config.customImageUrl = currentAvatarUrl;
              profile.avatarData = config.toJsonString();
              await _db.saveUserProfile(profile);
            }
          } catch (e) {
            print('Errore aggiornamento avatar profilo: $e');
          }
        }

        _loadCharacters();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore nel salvataggio: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteCharacter(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Personaggio'),
        content: const Text('Sei sicuro di voler eliminare questo personaggio?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _db.deleteComicCharacter(id);
        _loadCharacters();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore nell\'eliminazione: $e')),
          );
        }
      }
    }
  }

  Future<void> _importDefaults() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ripristina Predefiniti'),
        content: const Text('Vuoi importare i personaggi classici della crew? I doppioni verranno ignorati o aggiornati.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Importa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final defaults = [
          ComicCharacter(id: '', name: 'IL PRESIDENTE', description: 'Uomo con barba, casco bianco con piccola ananas sulla fronte, occhiali scuri, maglia "MTB CREW" con palma.', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          ComicCharacter(id: '', name: 'MARCOTREK', description: 'Uomo con casco Rosso acceso sempre pronto a scattare in fuga, maglia verde con strisce nere.', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          ComicCharacter(id: '', name: 'ENZOCHAR', description: 'Il nonno con un 10 marce in più. Ti stacca dopo 2 km. Maglia giallo nera MtbCrew.', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          ComicCharacter(id: '', name: 'E-DAVIDE', description: 'Il e-bike robotico, maglia bianca con riferimenti al tricolore.', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          ComicCharacter(id: '', name: 'DANY', description: 'DanySucciaruota, maglia nera con palma, sempre in scia a chi è davanti.', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          ComicCharacter(id: '', name: 'PANTE', description: 'Magro e alto, pieno di tecnologia per filmati, maglia nera con palma.', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          ComicCharacter(id: '', name: 'TANCIO', description: 'Marc-Tancio, il ciclista con lo zainetto misterioso. Maglia nero-verde.', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        ];

        for (var char in defaults) {
          await _db.saveComicCharacter(char);
        }
        await _loadCharacters();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore importazione: $e')));
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personaggi Fumetto'),
        actions: [
          IconButton(
            onPressed: _loadCharacters,
            icon: const Icon(Icons.refresh),
            tooltip: 'Ricarica',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'defaults') _importDefaults();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'defaults',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20),
                    SizedBox(width: 8),
                    Text('Ripristina Predefiniti'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _characters.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.groups_outlined, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Nessun personaggio attivo', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _showEditDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Crea Nuovo'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _importDefaults,
                        icon: const Icon(Icons.history),
                        label: const Text('Importa Equipaggio Classico'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _characters.length,
                  itemBuilder: (context, index) {
                    final char = _characters[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage: char.avatarUrl != null ? NetworkImage(char.avatarUrl!) : null,
                          child: char.avatarUrl == null ? const Icon(Icons.person_outlined) : null,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          char.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(char.description),
                              if (char.userId != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 14, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text('Utente associato', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showEditDialog(char),
                              icon: const Icon(Icons.edit_outlined, size: 20),
                            ),
                            IconButton(
                              onPressed: () => _deleteCharacter(char.id),
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nuovo Personaggio'),
      ),
    );
  }
}
