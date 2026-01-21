import 'package:flutter/material.dart';
import '../models/group_ride.dart';
import '../services/crew_service.dart';
import '../widgets/activity_card.dart';
import 'group_ride_detail_screen.dart';
import 'create_group_ride_screen.dart';

/// Unified agenda screen showing all user activities (created + joined)
class UnifiedAgendaScreen extends StatefulWidget {
  const UnifiedAgendaScreen({super.key});

  @override
  State<UnifiedAgendaScreen> createState() => _UnifiedAgendaScreenState();
}

class _UnifiedAgendaScreenState extends State<UnifiedAgendaScreen> {
  final _crewService = CrewService();
  List<GroupRide> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    try {
      final activities = await _crewService.getUnifiedActivityAgenda();
      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text('Le Mie Attività'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActivities,
            tooltip: 'Aggiorna',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadActivities,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      final activity = _activities[index];
                      return ActivityCard(
                        activity: activity,
                        showJoinButton: false, // Already joined
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GroupRideDetailScreen(groupRide: activity),
                            ),
                          );
                          if (result == true) _loadActivities();
                        },
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Nessuna Attività',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea la tua prima attività o esplora quelle pubbliche!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupRideScreen(),
                  ),
                );
                if (result == true) _loadActivities();
              },
              icon: const Icon(Icons.add),
              label: const Text('Crea Attività'),
            ),
          ],
        ),
      ),
    );
  }
}
