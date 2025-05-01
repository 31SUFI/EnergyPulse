import 'package:energy_meter_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  static const _titleStyle = TextStyle(
    fontFamily: 'AnekLatin',
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: const _MenuButton(),
      title: Text(
        title,
        style: _titleStyle.copyWith(color: AppColors.textPrimary),
      ),
      centerTitle: false,

      actions: const [_NotificationButton()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: AppColors.textPrimary),
      onPressed: () {
        // TODO: Implement drawer
      },
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: IconButton(
        icon: const Icon(
          Icons.notifications_none_outlined,
          color: AppColors.textPrimary,
        ),
        onPressed: () {
          // TODO: Implement notifications
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 16.0),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.cardBackground,
        child: Icon(Icons.person_outline, color: AppColors.textPrimary),
      ),
    );
  }
}
