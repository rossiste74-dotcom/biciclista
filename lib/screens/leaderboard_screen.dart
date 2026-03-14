import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';
import '../models/user_avatar_config.dart';
import '../widgets/avatar/avatar_preview.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  Map<String, dynamic> _data = {
    'most_active': [],
    'organizers': [],
    'laziest': [],
  };
  List<Map<String, dynamic>> _crew = [];
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await _db.getFullLeaderboard();
    final crew = await _db.getCrewWithStats();
    final me = await _db.getUserProfile();
    if (mounted) {
      setState(() {
        _data = res;
        _crew = crew;
        _currentUser = me;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('leaderboard.title'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(icon: Icon(Icons.groups), text: 'Crew'),
            Tab(
              icon: const Icon(Icons.directions_bike),
              text: 'leaderboard.most_active_title'.tr(),
            ),
            Tab(
              icon: const Icon(Icons.map),
              text: 'leaderboard.cartographer_title'.tr(),
            ),
            Tab(
              icon: const Icon(Icons.weekend),
              text: 'leaderboard.laziest_title'.tr(),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCrewList(),
                _buildList(
                  _data['most_active'] ?? [],
                  'km',
                  Colors.yellow.shade700,
                ),
                _buildList(
                  _data['organizers'] ?? [],
                  'leaderboard.unit_tracks'.tr(),
                  Colors.blue.shade700,
                ),
                _buildList(
                  _data['laziest'] ?? [],
                  'km',
                  Colors.orange.shade700,
                  ascending: true,
                ),
              ],
            ),
    );
  }

  Widget _buildList(
    List<dynamic> items,
    String unit,
    Color rankColor, {
    bool ascending = false,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('leaderboard.no_data'.tr()),
          ],
        ),
      );
    }
    // ... rest of the buildList logic is same structure, but I'll replace it to ensure unit handling is correct
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = items[index];
        final rank = item['rank'] as int;
        final name = item['name'] as String? ?? 'Sconosciuto';
        final rawValue = item['value'];
        final value = rawValue is num
            ? rawValue.toStringAsFixed(0)
            : rawValue.toString();
        final isTop3 = rank <= 3;

        return Card(
          elevation: isTop3 ? 4 : 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isTop3
                ? BorderSide(color: rankColor.withOpacity(0.5), width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isTop3 ? rankColor : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: isTop3 ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              name,
              style: TextStyle(
                fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$value $unit',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCrewList() {
    if (_crew.isEmpty) {
      return Center(child: Text('leaderboard.no_data'.tr()));
    }

    final canManageRoles =
        _currentUser?.role == UserRole.capitano ||
        _currentUser?.role == UserRole.presidente;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _crew.length,
        itemBuilder: (context, index) {
          final member = _crew[index];
          final name = member['name'] as String? ?? 'Sconosciuto';
          final roleStr = member['role'] as String? ?? 'Gregario';
          final role = UserRoleExtension.fromString(roleStr);
          final totalKm = (member['total_km'] as num?)?.toDouble() ?? 0.0;
          final rideCount = (member['ride_count'] as num?)?.toInt() ?? 0;
          final lastRideRaw = member['last_ride_date'] as String?;
          final lastRide = lastRideRaw != null
              ? DateTime.tryParse(lastRideRaw)
              : null;
          final avatarJson = member['avatar_data'];
          final avatarStr = avatarJson != null
              ? (avatarJson is String ? avatarJson : json.encode(avatarJson))
              : null;
          final avatarConfig = avatarStr != null
              ? UserAvatarConfig.fromJsonString(avatarStr)
              : null;
          final isMe = member['user_id'] == _currentUser?.id;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: isMe ? 3 : 1,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: avatarConfig != null
                    ? ClipOval(
                        child: AvatarPreview(config: avatarConfig, size: 56),
                      )
                    : const Icon(Icons.person, size: 28),
              ),
              title: Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  role.iconWidget(height: 20),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'tu',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.route, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${totalKm.toStringAsFixed(0)} km',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.celebration, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '$rideCount uscite',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (lastRide != null) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yy').format(lastRide),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              trailing: (canManageRoles && !isMe && role != UserRole.presidente)
                  ? PopupMenuButton<UserRole>(
                      icon: const Icon(Icons.more_vert),
                      tooltip: 'Gestisci ruolo',
                      onSelected: (newRole) async {
                        final userId = member['user_id'] as String?;
                        if (userId == null) return;
                        final ok = await _db.updateUserRole(userId, newRole);
                        if (ok && mounted) {
                          await _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('$name è ora '),
                                  newRole.iconWidget(height: 16),
                                  Text(' ${newRole.name}'),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        if (role != UserRole.capitano)
                          const PopupMenuItem(
                            value: UserRole.capitano,
                            child: Row(
                              children: [
                                Text('⭐ ', style: TextStyle(fontSize: 18)),
                                Text('Promuovi a Capitano'),
                              ],
                            ),
                          ),
                        if (role != UserRole.gregario)
                          const PopupMenuItem(
                            value: UserRole.gregario,
                            child: Row(
                              children: [
                                Text('🚴 ', style: TextStyle(fontSize: 18)),
                                Text('Retrocedi a Gregario'),
                              ],
                            ),
                          ),
                      ],
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
