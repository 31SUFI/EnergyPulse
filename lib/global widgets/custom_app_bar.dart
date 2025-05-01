import 'package:energy_meter_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const CustomAppBar({super.key, required this.title, this.actions});

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

      actions: actions,
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
