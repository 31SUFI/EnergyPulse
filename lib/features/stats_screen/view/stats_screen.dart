import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home_screen/providers/space_provider.dart';
import '../providers/room_selection_provider.dart';
import '../widgets/room_chip.dart';
import '../widgets/room_usage_stats.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late final RoomSelectionProvider _roomSelectionProvider;

  @override
  void initState() {
    super.initState();
    _roomSelectionProvider = RoomSelectionProvider();
    // Initialize room selection after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _roomSelectionProvider.initializeWithFirstRoom(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _roomSelectionProvider,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Room selection chips
            SizedBox(
              width: double.infinity,
              child: Consumer<SpaceProvider>(
                builder: (context, spaceProvider, _) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: spaceProvider.spaces.map((space) => [
                        RoomChip(roomName: space.name),
                        const SizedBox(width: 8),
                      ]).expand((widgets) => widgets).toList()
                        ..removeLast(), // Remove last SizedBox
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const RoomUsageStats(),
          ],
        ),
      ),
    );
  }
}
