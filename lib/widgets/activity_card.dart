import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/group_ride.dart';
import '../services/crew_service.dart';
import '../services/supabase_config.dart';
import '../widgets/difficulty_badge.dart';
import '../models/terrain_analysis.dart';
import '../models/user_avatar_config.dart';
import '../widgets/avatar/avatar_preview.dart';

/// Enhanced activity card with creator avatar, participant row, and join button
class ActivityCard extends StatefulWidget {
  final GroupRide activity;
  final VoidCallback? onTap;
  final bool showJoinButton;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.showJoinButton = true,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  final _crewService = CrewService();
  late Stream<int> _participantCountStream;
  int _participantCount = 0;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _participantCount = widget.activity.currentParticipants;
    // Subscribe to realtime updates
    _participantCountStream = _crewService.subscribeToActivityUpdates(widget.activity.id);
  }

  bool get _isCreator {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    return userId == widget.activity.creatorId;
  }

  bool get _isParticipating {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    return widget.activity.participants.any((p) => p.userId == userId);
  }

  Future<void> _handleJoin() async {
    setState(() => _isJoining = true);
    try {
      await _crewService.joinGroupRide(widget.activity.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ti sei unito all\'attività! 🎉')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title + Date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.activity.rideName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE d MMMM, HH:mm', 'it_IT')
                              .format(widget.activity.meetingTime),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Realtime participant count badge
                  StreamBuilder<int>(
                    stream: _participantCountStream,
                    initialData: _participantCount,
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? _participantCount;
                      // Animate on change
                      if (count != _participantCount) {
                        _participantCount = count;
                      }
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.activity.meetingPoint,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.activity.distance != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.route, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.activity.distance!.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (widget.activity.elevation != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.terrain, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.activity.elevation!.toStringAsFixed(0)} m',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              
              // Difficulty indicator row
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.bar_chart, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Difficoltà:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  DifficultyIndicator(
                    difficulty: _parseDifficulty(widget.activity.difficultyLevel),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Creator section
              if (widget.activity.participants.isNotEmpty)
                Row(
                  children: [
                    Builder(
                      builder: (context) {
                        final creator = widget.activity.participants.firstWhere(
                          (p) => p.userId == widget.activity.creatorId,
                          orElse: () => widget.activity.participants.first,
                        );
                        return _buildAvatar(
                           context, 
                           displayName: creator.displayName,
                           avatarData: creator.avatarData,
                           profileImageUrl: creator.profileImageUrl,
                           size: 32,
                           isHighlight: true,
                        );
                      }
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Organizzato da ${widget.activity.participants.firstWhere(
                              (p) => p.userId == widget.activity.creatorId,
                              orElse: () => widget.activity.participants.first,
                            ).displayName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // Participants row (horizontal scrollable)
              if (widget.activity.participants.isNotEmpty) ...[
                Text(
                  'Partecipanti',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.activity.participants.length,
                    itemBuilder: (context, index) {
                      final participant = widget.activity.participants[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Tooltip(
                          message: participant.displayName,
                          child: _buildAvatar(
                             context,
                             displayName: participant.displayName,
                             avatarData: participant.avatarData,
                             profileImageUrl: participant.profileImageUrl,
                             size: 40,
                             isHighlight: participant.userId == widget.activity.creatorId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // Join button (only if not creator and not already joined)
              if (widget.showJoinButton && !_isCreator && !_isParticipating) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isJoining ? null : _handleJoin,
                    icon: _isJoining
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(_isJoining ? 'Unione...' : 'Unisciti'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  DifficultyRating _parseDifficulty(String level) {
    switch (level.toLowerCase()) {
      case 'easy':
        return DifficultyRating.easy;
      case 'medium':
        return DifficultyRating.moderate;
      case 'hard':
        return DifficultyRating.hard;
      case 'expert':
        return DifficultyRating.expert;
      default:
        return DifficultyRating.moderate;
    }
  }

  Widget _buildAvatar(BuildContext context, {
    required String displayName, 
    String? avatarData, 
    String? profileImageUrl, 
    double size = 32,
    bool isHighlight = false, // For creator or self
  }) {
    // 1. SVG Avatar
    if (avatarData != null) {
      final config = UserAvatarConfig.fromJsonString(avatarData);
      if (config != null) {
        return ClipOval(
          child: Container(
            width: size,
            height: size,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: AvatarPreview(config: config, size: size),
          ),
        );
      }
    }

    // 2. Raster Image (URL)
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(profileImageUrl),
        backgroundColor: Colors.transparent,
      );
    }

    // 3. Initials Fallback
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: isHighlight 
          ? Theme.of(context).colorScheme.primary 
          : Colors.grey[300],
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: TextStyle(
          color: isHighlight ? Colors.white : Colors.black87,
          fontSize: size * 0.45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
