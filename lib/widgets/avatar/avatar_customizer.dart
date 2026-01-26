import 'package:flutter/material.dart';

import '../../models/user_avatar_config.dart';

import 'avatar_preview.dart';

class AvatarCustomizerScreen extends StatefulWidget {
  final UserAvatarConfig? initialConfig;

  const AvatarCustomizerScreen({super.key, this.initialConfig});

  @override
  State<AvatarCustomizerScreen> createState() => _AvatarCustomizerScreenState();
}

class _AvatarCustomizerScreenState extends State<AvatarCustomizerScreen> with SingleTickerProviderStateMixin {
  late UserAvatarConfig _config;
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig ?? UserAvatarConfig.defaultConfig();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  void _saveAvatar() async {
    // 1. Save locally via service
    // In a real app, this would update the Isar profile and trigger a sync.
    // For now, we simulate success and return.
    
    // We need to access the current UserProfile, update avatarData, and save.
    // Since DataModeService manages this high level, we might need a method there.
    // Or we simply return the config and let the caller handle saving.
    Navigator.pop(context, _config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizza Avatar'),
        actions: [
          TextButton(
            onPressed: () {
              // Reset to default
               setState(() {
                 _config = UserAvatarConfig.defaultConfig();
               });
            },
            child: const Text('Reset'),
          ),
          FilledButton(
            onPressed: _saveAvatar,
            child: const Text('Salva'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Preview Area
          Expanded(
            flex: 4,
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Center(
                child: AvatarPreview(config: _config, size: 250),
              ),
            ),
          ),
          
          // Controls Area
          Expanded(
            flex: 5,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.person), text: 'Corpo'),
                    Tab(icon: Icon(Icons.face), text: 'Testa'),
                    Tab(icon: Icon(Icons.sports_motorsports), text: 'Equipaggiamento'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBodyTab(),
                      _buildHeadTab(),
                      _buildGearTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        const SizedBox(height: 16),
        _buildSectionTitle('Carnagione'),
        _buildColorPicker(
          _config.skinTone,
          [
            const Color(0xFFFFE0BD), // Light
            const Color(0xFFEACCB4),
            const Color(0xFFD1B499),
            const Color(0xFFBD9E83),
            const Color(0xFFA5856F),
            const Color(0xFF8D6D5C),
            const Color(0xFF745348),
            const Color(0xFF5B3B36), // Dark
          ],
          (c) => setState(() => _config.skinTone = c),
        ),
      ],
    );
  }

  Widget _buildHeadTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Acconciatura'),
        Wrap(
          spacing: 8,
          children: HairStyle.values.map((s) {
            return ChoiceChip(
              label: Text(s.name),
              selected: _config.hairStyle == s,
              onSelected: (selected) {
                if (selected) setState(() => _config.hairStyle = s);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Colore Capelli'),
        _buildColorPicker(
          _config.hairColor,
          [
            Colors.black,
            Colors.brown,
            const Color(0xFFE6CEA0), // Blonde
            const Color(0xFFB03060), // Red
            Colors.grey,
            Colors.white,
            Colors.blue, // Fun
          ],
          (c) => setState(() => _config.hairColor = c),
        ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Barba'),
            value: _config.hasBeard,
            onChanged: (v) => setState(() => _config.hasBeard = v),
          ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Occhiali'),
          value: _config.hasGlasses,
          onChanged: (v) => setState(() => _config.hasGlasses = v),
        ),

      ],
    );
  }

  Widget _buildGearTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Colore Casco'),
        _buildColorPicker(
          _config.helmetColor,
          [
             Colors.blue, Colors.red, Colors.green, Colors.black, 
             Colors.white, Colors.orange, Colors.purple, Colors.yellow
          ],
          (c) => setState(() => _config.helmetColor = c),
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        _buildSectionTitle('Colore Maglia - Base'),
        _buildColorPicker(
          _config.jerseyColor,
          [
             Colors.blue, Colors.red, Colors.green, Colors.black, 
             Colors.white, Colors.orange, Colors.purple, Colors.yellow, Colors.teal, Colors.pink
          ],
          (c) => setState(() => _config.jerseyColor = c),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Colore Maglia - Dettagli 1'),
        _buildColorPicker(
          _config.jerseyColor2,
          [
             Colors.blue, Colors.red, Colors.green, Colors.black, 
             Colors.white, Colors.orange, Colors.purple, Colors.yellow, Colors.teal, Colors.pink
          ],
          (c) => setState(() => _config.jerseyColor2 = c),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Colore Maglia - Dettagli 2'),
        _buildColorPicker(
          _config.jerseyColor3,
          [
             Colors.blue, Colors.red, Colors.green, Colors.black, 
             Colors.white, Colors.orange, Colors.purple, Colors.yellow, Colors.teal, Colors.pink
          ],
          (c) => setState(() => _config.jerseyColor3 = c),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildColorPicker(Color selected, List<Color> colors, Function(Color) onSelect) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((c) {
        final isSelected = c.value == selected.value;
        return GestureDetector(
          onTap: () => onSelect(c),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)
              ] : null,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
          ),
        );
      }).toList(),
    );
  }
}
