import 'package:flutter/material.dart';
import '../models/group_ride.dart';
import '../services/crew_service.dart';
import 'group_ride_detail_screen.dart';
import 'explore_community_screen.dart';
import 'package:intl/intl.dart';

/// Main Crew screen showing group rides
class CrewScreen extends StatefulWidget {
  const CrewScreen({super.key});

  @override
  State<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends State<CrewScreen> {
  final _crewService = CrewService();
  List<GroupRide> _rides = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, upcoming, my

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() => _isLoading = true);

    try {
      List<GroupRide> rides;
      if (_filter == 'my') {
        rides = await _crewService.getMyParticipatingRides();
      } else if (_filter == 'upcoming') {
        rides = await _crewService.getPublicGroupRides(
          status: 'planned',
          afterDate: DateTime.now(),
        );
      } else {
        rides = await _crewService.getPublicGroupRides(
          afterDate: DateTime.now(),
        );
      }
      setState(() {
        _rides = rides;
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
        title: const Text('Crew - Uscite di Gruppo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'Esplora Tracce Community',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExploreCommunityScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRides,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(),
          
          // Rides list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _rides.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadRides,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _rides.length,
                          itemBuilder: (context, index) => _buildRideCard(_rides[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Tutte', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('In Arrivo', 'upcoming'),
          const SizedBox(width: 8),
          _buildFilterChip('Le Mie', 'my'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = value);
        _loadRides();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nessuna uscita disponibile',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Crea la prima uscita di gruppo!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(GroupRide ride) {
    final dateFormat = DateFormat('dd MMM', 'it_IT');
    final timeFormat = DateFormat('HH:mm', 'it_IT');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRideDetails(ride),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ride.rideName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildDifficultyBadge(ride.difficultyLevel),
                ],
              ),
              const SizedBox(height: 8),
              
              // Meeting info
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormat.format(ride.meetingTime)} - ${timeFormat.format(ride.meetingTime)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ride.meetingPoint,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              if (ride.distance != null || ride.elevation != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (ride.distance != null) ...[
                      const Icon(Icons.route, size: 16),
                      const SizedBox(width: 4),
                      Text('${ride.distance!.toStringAsFixed(1)} km'),
                      const SizedBox(width: 16),
                    ],
                    if (ride.elevation != null) ...[
                      const Icon(Icons.terrain, size: 16),
                      const SizedBox(width: 4),
                      Text('${ride.elevation!.toStringAsFixed(0)} m'),
                    ],
                  ],
                ),
              ],
              
              // Participants
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(
                    '${ride.currentParticipants}/${ride.maxParticipants} partecipanti',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    String label;
    switch (difficulty) {
      case 'easy':
        color = Colors.green;
        label = 'Facile';
        break;
      case 'medium':
        color = Colors.orange;
        label = 'Medio';
        break;
      case 'hard':
        color = Colors.red;
        label = 'Difficile';
        break;
      case 'expert':
        color = Colors.purple;
        label = 'Esperto';
        break;
      default:
        color = Colors.grey;
        label = difficulty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showRideDetails(GroupRide ride) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupRideDetailScreen(groupRide: ride),
      ),
    );
    
    if (result == true) {
      _loadRides(); // Reload if joined/left or deleted
    }
  }

  Future<void> _joinRide(GroupRide ride) async {
    try {
      await _crewService.joinGroupRide(ride.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Iscritto all\'uscita!')),
        );
        _loadRides();
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
