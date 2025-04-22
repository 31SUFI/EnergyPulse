import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../home_screen/providers/space_provider.dart';
import '../providers/room_selection_provider.dart';

class RoomChip extends StatelessWidget {
  final String roomName;

  const RoomChip({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RoomSelectionProvider, SpaceProvider>(
      builder: (context, roomProvider, spaceProvider, _) {
        final bool isSelected = roomProvider.selectedRoom == roomName;
        spaceProvider.spaces.firstWhere(
          (space) => space.name == roomName,
          orElse: () => spaceProvider.spaces.first,
        );

        return FilterChip(
          selected: isSelected,
          selectedColor: AppColors.secondary,
          backgroundColor: AppColors.cardBackground,
          checkmarkColor: AppColors.textWhite,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                roomName,
                style: TextStyle(
                  color:
                      isSelected
                          ? AppColors.textWhite
                          : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          onSelected: (_) => roomProvider.selectRoom(roomName),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? AppColors.secondary : Colors.transparent,
              width: 1,
            ),
          ),
        );
      },
    );
  }
}
