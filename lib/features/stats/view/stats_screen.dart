import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/home/providers/space_provider.dart';
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
              Consumer<SpaceProvider>(
                builder: (context, spaceProvider, _) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: spaceProvider.spaces.map((space) => [
                        RoomChip(roomName: space.name),
                        const SizedBox(width: 8),
                      ]).expand((widgets) => widgets).toList()
                        ..removeLast(), // Remove last SizedBox
                    ),
                  );
                },
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
