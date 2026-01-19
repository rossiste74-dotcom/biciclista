import 'package:flutter/material.dart';
import '../models/public_profile.dart';
import '../services/social_service.dart';
import '../services/database_service.dart';

/// Public profile screen showing user stats and garage
class PublicProfileScreen extends StatefulWidget {
  final String? userId; // null = my profile
  
  const PublicProfileScreen({super.key, this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final _socialService = SocialService();
  final _db = DatabaseService();
  
  PublicProfile? _profile;
  bool _isLoading = true;
  bool _isMyProfile = false;
  bool _isFriend = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      PublicProfile? profile;
      
      if (widget.userId == null) {
        // My profile
        profile = await _socialService.getMyPublicProfile();
        _isMyProfile = true;
        
        // Create if doesn't exist
        if (profile == null) {
          final userProfile = await _db.getUserProfile();
          if (userProfile != null) {
            profile = await _socialService.upsertPublicProfile(
              displayName: userProfile.name ?? 'Ciclista',
            );
          }
        }
      } else {
        // Other user's profile
        profile = await _socialService.getPublicProfile(widget.userId!);
        _isFriend = await _socialService.areFriends(widget.userId!);
      }

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore caricamento: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isMyProfile ? 'Il Mio Profilo' : 'Profilo'),
        actions: _isMyProfile ? [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ] : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? _buildEmptyState()
              : _buildProfileContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 80),
          const SizedBox(height: 16),
          const Text('Profilo non trovato'),
          if (_isMyProfile) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _editProfile,
              child: const Text('Crea Profilo'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profile header
        _buildProfileHeader(),
        const SizedBox(height: 24),

        // Privacy toggle (only for my profile)
        if (_isMyProfile) ...[
          SwitchListTile(
            title: const Text('Profilo Privato'),
            subtitle: Text(_profile!.isPrivate
                ? 'Visibile solo agli amici'
                : 'Visibile a tutti'),
            value: _profile!.isPrivate,
            onChanged: (value) async {
              await _socialService.togglePrivacy(value);
              _loadProfile();
            },
          ),
          const Divider(),
          const SizedBox(height: 16),
        ],

        // Statistics (if enabled)
        if (_profile!.showStats || _isMyProfile) ...[
          _buildStatsSection(),
          const SizedBox(height: 24),
        ],

        // Friend button (for other users)
        if (!_isMyProfile && !_isFriend) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _sendFriendRequest,
              icon: const Icon(Icons.person_add),
              label: const Text('Aggiungi Amico'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          backgroundImage: _profile!.profileImageUrl != null
              ? NetworkImage(_profile!.profileImageUrl!)
              : null,
          child: _profile!.profileImageUrl == null
              ? Icon(
                  Icons.person,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        ),
        const SizedBox(height: 16),
        
        // Name
        Text(
          _profile!.displayName,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        
        // Bio
        if (_profile!.bio != null) ...[
          const SizedBox(height: 8),
          Text(
            _profile!.bio!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiche',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.route,
                  value: '${_profile!.totalKm.toStringAsFixed(0)} km',
                  label: 'Totali',
                ),
                _buildStatItem(
                  icon: Icons.pedal_bike,
                  value: '${_profile!.totalRides}',
                  label: 'Uscite',
                ),
                _buildStatItem(
                  icon: Icons.terrain,
                  value: '${_profile!.totalElevation.toStringAsFixed(0)} m',
                  label: 'Dislivello',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _editProfile() {
    // TODO: Implement edit profile dialog/screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica Profilo'),
        content: const Text('Funzionalità in arrivo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFriendRequest() async {
    try {
      await _socialService.sendFriendRequest(widget.userId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Richiesta amicizia inviata!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }
}
