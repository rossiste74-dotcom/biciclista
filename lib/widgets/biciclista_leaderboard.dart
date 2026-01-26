import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Widget showing community leaderboard with sarcastic titles
class BiciclistaLeaderboard extends StatelessWidget {
  final Map<String, dynamic> leaderboardData;
  final VoidCallback? onTap;

  const BiciclistaLeaderboard({
    super.key,
    required this.leaderboardData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple.shade500,
                Colors.purple.shade800,
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'leaderboard.title'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildRankRow(
                context,
                icon: Icons.directions_bike,
                title: 'leaderboard.most_active_title'.tr(),
                name: leaderboardData['most_active']?['name'] ?? 'Nessuno',
                value: '${leaderboardData['most_active']?['value'] ?? 0} km',
                color: Colors.yellowAccent,
              ),
              const Divider(color: Colors.white24, height: 24),
              _buildRankRow(
                context,
                icon: Icons.map, // Changed icon to map for Cartographer
                title: 'leaderboard.cartographer_title'.tr(),
                name: leaderboardData['organizer']?['name'] ?? 'Nessuno',
                value: '${leaderboardData['organizer']?['value'] ?? 0} ${'leaderboard.unit_tracks'.tr()}',
                color: Colors.lightBlueAccent,
              ),
              const Divider(color: Colors.white24, height: 24),
              _buildRankRow(
                context,
                icon: Icons.weekend,
                title: 'leaderboard.laziest_title'.tr(),
                name: leaderboardData['laziest']?['name'] ?? 'Nessuno',
                value: '${leaderboardData['laziest']?['value'] ?? 0} km',
                color: Colors.orangeAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String name,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
