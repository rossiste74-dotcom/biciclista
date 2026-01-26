import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/database_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  Map<String, dynamic> _data = {
    'most_active': [],
    'organizers': [], // Actually cartographers now
    'laziest': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await _db.getFullLeaderboard();
    if (mounted) {
      setState(() {
        _data = res;
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
            Tab(icon: const Icon(Icons.directions_bike), text: 'leaderboard.most_active_title'.tr()),
            Tab(icon: const Icon(Icons.map), text: 'leaderboard.cartographer_title'.tr()),
            Tab(icon: const Icon(Icons.weekend), text: 'leaderboard.laziest_title'.tr()),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_data['most_active'] ?? [], 'km', Colors.yellow.shade700),
                _buildList(_data['organizers'] ?? [], 'leaderboard.unit_tracks'.tr(), Colors.blue.shade700),
                _buildList(_data['laziest'] ?? [], 'km', Colors.orange.shade700, ascending: true),
              ],
            ),
    );
  }

  Widget _buildList(List<dynamic> items, String unit, Color rankColor, {bool ascending = false}) {
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
        final value = item['value'];
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
              style: TextStyle(fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal),
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
}
