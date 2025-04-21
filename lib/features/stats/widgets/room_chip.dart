import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/room_selection_provider.dart';

class RoomChip extends StatelessWidget {
  final String roomName;

  const RoomChip({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomSelectionProvider>(
      builder: (context, provider, _) {
        final bool isSelected = provider.selectedRoom == roomName;

        return FilterChip(
          selected: isSelected,
          selectedColor: AppColors.secondary,
          backgroundColor: AppColors.cardBackground,
          checkmarkColor: AppColors.textWhite,
          label: Text(
            roomName,
            style: TextStyle(
              color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onSelected: (_) => provider.selectRoom(roomName),
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
