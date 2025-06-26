import 'package:flutter/material.dart';
import 'package:energy_meter_app/core/constants/app_colors.dart';
import 'package:energy_meter_app/core/config/device_config.dart';
import '../model/firebase_schedule_model.dart';
import '../provider/firebase_schedule_provider.dart';

class FirebaseScheduleCard extends StatelessWidget {
  final FirebaseSchedule schedule;
  final FirebaseScheduleProvider provider;

  // Map relay numbers to device info
  static final Map<int, ({String name, String icon})> _relayDevices = {
    1: (name: 'Smart Light', icon: '💡'),
    2: (name: 'Smart Fan', icon: '🌀'),
    3: (name: 'Smart Heater', icon: '🔥'),
    4: (name: 'Smart AC', icon: '❄️'),
  };

  const FirebaseScheduleCard({
    Key? key,
    required this.schedule,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = _isScheduleActive(
      schedule.startTime,
      schedule.endTime,
      TimeOfDay.now(),
    );

    final device =
        _relayDevices[schedule.relay] ??
        (name: 'Relay ${schedule.relay}', icon: '🔌');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Center(
                  child: Text(
                    device.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${schedule.action} • ${schedule.startTime} - ${schedule.endTime}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: schedule.enabled,
                onChanged:
                    (val) =>
                        provider.updateSchedule(schedule.id, {'enabled': val}),
                activeColor: AppColors.secondary,
              ),
            ],
          ),

          if (schedule.enabled) ...[
            const SizedBox(height: 12),
            // Status and Actions Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? Icons.check_circle : Icons.schedule,
                        size: 16,
                        color: isActive ? Colors.green[600] : Colors.blue[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isActive ? 'Active Now' : 'Scheduled',
                        style: TextStyle(
                          color:
                              isActive ? Colors.green[700] : Colors.blue[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Delete Button
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, schedule.id),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _isScheduleActive(String start, String end, TimeOfDay now) {
    final startParts = start.split(':').map(int.parse).toList();
    final endParts = end.split(':').map(int.parse).toList();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startParts[0] * 60 + startParts[1];
    final endMinutes = endParts[0] * 60 + endParts[1];
    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
  }

  void _confirmDelete(BuildContext context, String scheduleId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Schedule'),
            content: const Text(
              'Are you sure you want to delete this schedule?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  provider.deleteSchedule(scheduleId);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
