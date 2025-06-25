import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/firebase_schedule_provider.dart';
import '../widgets/firebase_schedule_card.dart';
import '../model/firebase_schedule_model.dart';

class FirebaseScheduleScreen extends StatelessWidget {
  const FirebaseScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FirebaseScheduleProvider(),
      child: const FirebaseScheduleScreenContent(),
    );
  }
}

class FirebaseScheduleScreenContent extends StatelessWidget {
  const FirebaseScheduleScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FirebaseScheduleProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Relay Schedules')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: provider.schedules.map((schedule) =>
          FirebaseScheduleCard(schedule: schedule, provider: provider)
        ).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => _AddScheduleDialog(provider: provider),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddScheduleDialog extends StatefulWidget {
  final FirebaseScheduleProvider provider;
  const _AddScheduleDialog({required this.provider});

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
    return AlertDialog(
      title: const Text('Add Schedule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: relay,
              items: List.generate(4, (i) => i + 1)
                  .map((e) => DropdownMenuItem(value: e, child: Text('Relay $e')))
                  .toList(),
              onChanged: (val) => setState(() => relay = val ?? 1),
              decoration: const InputDecoration(labelText: 'Relay'),
            ),
            DropdownButtonFormField<String>(
              value: action,
              items: ['ON', 'OFF']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => action = val ?? 'ON'),
              decoration: const InputDecoration(labelText: 'Action'),
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text('${startTime.format(context)}'),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: startTime,
                      );
                      if (picked != null) setState(() => startTime = picked);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Time'),
                    subtitle: Text('${endTime.format(context)}'),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: endTime,
                      );
                      if (picked != null) setState(() => endTime = picked);
                    },
                  ),
                ),
              ],
            ),
            SwitchListTile(
              value: enabled,
              onChanged: (val) => setState(() => enabled = val),
              title: const Text('Enabled'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
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
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
