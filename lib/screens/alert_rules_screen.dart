import 'package:flutter/material.dart';
import '../models/alert_rule.dart';
import '../services/database_service.dart';

class AlertRulesScreen extends StatefulWidget {
  const AlertRulesScreen({super.key});

  @override
  State<AlertRulesScreen> createState() => _AlertRulesScreenState();
}

class _AlertRulesScreenState extends State<AlertRulesScreen> {
  final _db = DatabaseService();
  List<AlertRule> _rules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    await _db.initDefaultAlertRulesIfNeeded();
    final rules = await _db.getAlertRules();
    if (mounted) {
      setState(() {
        _rules = rules;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regole Alert'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nuova regola',
            onPressed: _showAddRuleDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rules.isEmpty
              ? const Center(child: Text('Nessuna regola configurata'))
              : ListView.builder(
                  itemCount: _rules.length,
                  itemBuilder: (context, index) => _buildRuleTile(_rules[index]),
                ),
    );
  }

  Widget _buildRuleTile(AlertRule rule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          _getEventIcon(rule.eventType),
          color: rule.isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        title: Text(rule.eventName),
        subtitle: Text(rule.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: rule.isEnabled,
              onChanged: (val) => _toggleRule(rule, val),
            ),
            PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'edit') _showEditRuleDialog(rule);
                if (action == 'delete') _confirmDeleteRule(rule);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Modifica')),
                const PopupMenuItem(value: 'delete', child: Text('Elimina')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(AlertEventType type) {
    switch (type) {
      case AlertEventType.offCourse:
        return Icons.wrong_location;
      case AlertEventType.distanceToFinish:
        return Icons.flag;
      case AlertEventType.climbStart:
        return Icons.trending_up;
      case AlertEventType.climbEnd:
        return Icons.trending_down;
      case AlertEventType.halfway:
        return Icons.timelapse;
      case AlertEventType.approachingTurn:
        return Icons.turn_right;
    }
  }

  void _toggleRule(AlertRule rule, bool enabled) async {
    rule.isEnabled = enabled;
    await _db.saveAlertRule(rule);
    setState(() {});
  }

  void _confirmDeleteRule(AlertRule rule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina regola?'),
        content: Text('Vuoi eliminare la regola "${rule.eventName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              if (rule.id != null) await _db.deleteAlertRule(rule.id!);
              _loadRules();
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  void _showAddRuleDialog() {
    _showRuleDialog(AlertRule()
      ..eventType = AlertEventType.offCourse
      ..action = AlertActionType.voice
      ..triggerValue = 30.0);
  }

  void _showEditRuleDialog(AlertRule rule) {
    _showRuleDialog(rule);
  }

  void _showRuleDialog(AlertRule rule) {
    final isNew = rule.id == null;
    int selectedEventIndex = rule.eventTypeIndex;
    int selectedActionIndex = rule.actionIndex;
    double? triggerValue = rule.triggerValue;
    String? voiceMessage = rule.voiceMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isNew ? 'Nuova Regola' : 'Modifica Regola'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Evento:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  isExpanded: true,
                  value: selectedEventIndex,
                  items: AlertEventType.values.map((e) {
                    return DropdownMenuItem(
                      value: e.index,
                      child: Text(_getEventName(e)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedEventIndex = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Azione:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  isExpanded: true,
                  value: selectedActionIndex,
                  items: AlertActionType.values.map((e) {
                    return DropdownMenuItem(
                      value: e.index,
                      child: Text(_getActionName(e)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedActionIndex = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Show trigger value for certain events
                if (selectedEventIndex == AlertEventType.offCourse.index ||
                    selectedEventIndex == AlertEventType.distanceToFinish.index) ...[
                  Text(
                    selectedEventIndex == AlertEventType.offCourse.index
                        ? 'Soglia (metri):'
                        : 'Distanza (km):',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: triggerValue?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      triggerValue = double.tryParse(val);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Custom voice message
                if (selectedActionIndex == AlertActionType.voice.index ||
                    selectedActionIndex == AlertActionType.both.index) ...[
                  const Text('Messaggio (opzionale):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: voiceMessage ?? '',
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: _getDefaultMessage(selectedEventIndex, triggerValue),
                    ),
                    onChanged: (val) {
                      voiceMessage = val.isNotEmpty ? val : null;
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () async {
                rule.eventTypeIndex = selectedEventIndex;
                rule.actionIndex = selectedActionIndex;
                rule.triggerValue = triggerValue;
                rule.voiceMessage = voiceMessage;
                await _db.saveAlertRule(rule);
                if (mounted) {
                  Navigator.pop(context);
                  _loadRules();
                }
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  String _getEventName(AlertEventType type) {
    switch (type) {
      case AlertEventType.offCourse: return 'Fuori percorso';
      case AlertEventType.distanceToFinish: return 'Distanza dall\'arrivo';
      case AlertEventType.climbStart: return 'Inizio salita';
      case AlertEventType.climbEnd: return 'Fine salita';
      case AlertEventType.halfway: return 'Metà percorso';
      case AlertEventType.approachingTurn: return 'Prossima svolta';
    }
  }

  String _getActionName(AlertActionType type) {
    switch (type) {
      case AlertActionType.none: return 'Nessuno';
      case AlertActionType.vibration: return 'Vibrazione';
      case AlertActionType.voice: return 'Messaggio vocale';
      case AlertActionType.both: return 'Vibrazione + Voce';
    }
  }

  String _getDefaultMessage(int eventIndex, double? value) {
    final type = AlertEventType.values[eventIndex];
    switch (type) {
      case AlertEventType.offCourse:
        return 'Attenzione, sei fuori percorso';
      case AlertEventType.distanceToFinish:
        final km = value?.toInt() ?? 5;
        return km == 1 ? 'Manca 1 chilometro' : 'Mancano $km chilometri';
      case AlertEventType.climbStart:
        return 'Inizia una salita';
      case AlertEventType.climbEnd:
        return 'Fine della salita';
      case AlertEventType.halfway:
        return 'Hai raggiunto metà percorso';
      case AlertEventType.approachingTurn:
        return 'Svolta tra poco';
    }
  }
}
