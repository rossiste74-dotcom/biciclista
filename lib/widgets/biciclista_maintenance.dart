import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Widget showing bike maintenance alerts with Il Biciclista's sarcastic tone
class BiciclistaMaintenance extends StatelessWidget {
  final String? componentName;
  final double? kmRemaining;
  final bool allOk;
  final Map<String, String>? maintenanceMessages;

  const BiciclistaMaintenance({
    super.key,
    this.componentName,
    this.kmRemaining,
    this.allOk = true,
    this.maintenanceMessages,
  });

  String _getMaintenanceComment() {
    if (allOk) {
      return maintenanceMessages?['all_ok'] ?? "maintenance.all_ok".tr();
    }

    if (kmRemaining == null || kmRemaining! <= 0) {
      return maintenanceMessages?['critical'] ?? "maintenance.critical".tr();
    }

    final percentage = (kmRemaining! / 1000 * 100).clamp(0, 100);
    
    if (percentage < 10) {
      return "$componentName ${maintenanceMessages?['warning'] ?? "maintenance.warning".tr()}";
    } else if (percentage < 30) {
      return "$componentName ${maintenanceMessages?['notice'] ?? "maintenance.notice".tr()}";
    } else {
      return "$componentName ${maintenanceMessages?['attention'] ?? "maintenance.attention".tr()}";
    }
  }

  Color _getGradientStartColor() {
    if (allOk) return Colors.green.shade400;
    if (kmRemaining == null || kmRemaining! <= 0) return Colors.red.shade600;
    
    final percentage = (kmRemaining! / 1000 * 100).clamp(0, 100);
    if (percentage < 10) return Colors.red.shade500;
    if (percentage < 30) return Colors.orange.shade500;
    return Colors.yellow.shade600;
  }

  Color _getGradientEndColor() {
    if (allOk) return Colors.lime.shade600;
    if (kmRemaining == null || kmRemaining! <= 0) return Colors.red.shade900;
    
    final percentage = (kmRemaining! / 1000 * 100).clamp(0, 100);
    if (percentage < 10) return Colors.red.shade800;
    if (percentage < 30) return Colors.orange.shade700;
    return Colors.yellow.shade800;
  }

  @override
  Widget build(BuildContext context) {
    final comment = _getMaintenanceComment();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getGradientStartColor(),
              _getGradientEndColor(),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allOk ? Icons.check_circle : Icons.build,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'maintenance.title'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!allOk && componentName != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          componentName!,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (kmRemaining != null && kmRemaining! > 0)
                          Text(
                            '${kmRemaining!.toStringAsFixed(0)} ${'maintenance.remaining'.tr()}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text(
              '"$comment"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
