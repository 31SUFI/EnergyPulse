import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_selection_provider.dart';
import '../widgets/room_chip.dart';
import '../widgets/room_usage_stats.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomSelectionProvider(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Room selection chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    RoomChip(roomName: "Oliver's Bedroom"),
                    SizedBox(width: 8),
                    RoomChip(roomName: "Living Room"),
                    SizedBox(width: 8),
                    RoomChip(roomName: "Kitchen"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const RoomUsageStats()
            ],
          ),
        ),
      ),
    );
  }
}
