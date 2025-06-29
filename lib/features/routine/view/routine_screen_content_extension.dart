import 'package:energy_meter_app/core/constants/app_colors.dart';
import 'package:energy_meter_app/features/routine/model/firebase_schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/firebase_schedule_provider.dart';
import '../widgets/firebase_schedule_card.dart';

/// Extension widget to be included in RoutineScreenContent for relay scheduling
class RelayScheduleSection extends StatelessWidget {
  const RelayScheduleSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FirebaseScheduleProvider(),
      child: const _RelayScheduleSectionContent(),
    );
  }
}

class _RelayScheduleSectionContent extends StatelessWidget {
  const _RelayScheduleSectionContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FirebaseScheduleProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scheduled Devices',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Set up schedules to automatically control your devices',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 16),

        if (provider.schedules.isEmpty)
          _buildEmptyState(context)
        else
          ...provider.schedules
              .map(
                (schedule) => FirebaseScheduleCard(
                  schedule: schedule,
                  provider: provider,
                ),
              )
              .toList(),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showAddScheduleDialog(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('Add New Schedule'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.schedule_outlined, size: 36, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'No Schedules Yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a schedule to automatically control your devices',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(
    BuildContext context,
    FirebaseScheduleProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => _AddScheduleDialog(provider: provider),
    );
  }
}

class _AddScheduleDialog extends StatefulWidget {
  final Map<int, String> relayDeviceNames = {
    1: 'Smart Light',
    2: 'Smart Fan',
    3: 'Smart Heater',
    4: 'Smart AC',
  };
  final FirebaseScheduleProvider provider;
  _AddScheduleDialog({required this.provider});

  @override
  State<_AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<_AddScheduleDialog> {
  int relay = 1;
  String action = 'ON';
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Schedule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Relay Selection
              const Text(
                'Relay',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: relay,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 24),
                    items: widget.relayDeviceNames.keys.map((relay) {
                      return DropdownMenuItem(
                        value: relay,
                        child: Text(widget.relayDeviceNames[relay] ?? 'Relay $relay'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => relay = val ?? 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Selection
              const Text(
                'Action',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: action,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 24),
                    items:
                        ['ON', 'OFF'].map((e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),
                    onChanged: (val) => setState(() => action = val ?? 'ON'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Selection
              const Text(
                'Time Range',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeTile('Start Time', startTime, (picked) {
                      if (picked != null) setState(() => startTime = picked);
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeTile('End Time', endTime, (picked) {
                      if (picked != null) setState(() => endTime = picked);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Enabled Switch
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Enable Schedule',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: enabled,
                  onChanged: (val) => setState(() => enabled = val),
                  activeColor: AppColors.secondary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTile(
    String title,
    TimeOfDay time,
    ValueChanged<TimeOfDay?> onTimePicked,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.secondary,
                  onPrimary: Colors.white,
                  onSurface: Colors.black87,
                ),
              ),
              child: child!,
            );
          },
        );
        onTimePicked(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        constraints: const BoxConstraints(minWidth: 120),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSchedule() {
    widget.provider.createSchedule(
      FirebaseSchedule(
        id: '',
        relay: relay,
        action: action,
        startTime: _formatTime(startTime),
        endTime: _formatTime(endTime),
        enabled: enabled,
      ),
    );
    Navigator.of(context).pop();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
