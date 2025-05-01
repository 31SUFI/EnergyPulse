import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../widgets/profile_section_card.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ProfileModel.dummyProfile;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // User Information Section
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profile.profilePicture),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          label: Text(
                            'ID: ${profile.householdId}',
                            style: const TextStyle(color: AppColors.textWhite),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            profile.accountType,
                            style: const TextStyle(color: AppColors.textWhite),
                          ),
                          backgroundColor: AppColors.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Account Management Section
            ProfileSectionCard(
              title: 'Account Management',
              child: ListTile(
                leading: Icon(Icons.lock_outline, color: AppColors.primary),
                title: Text(
                  'Change Password',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                trailing: Icon(Icons.chevron_right, color: AppColors.primary),
                onTap: () {
                  // TODO: Implement password change
                },
              ),
            ),

            // Support & Help Section
            ProfileSectionCard(
              title: 'Support & Help',
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.question_answer_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'FAQ',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                    ),
                    onTap: () {
                      // TODO: Navigate to FAQ
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.support_agent_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'Contact Support',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                    ),
                    onTap: () {
                      // TODO: Navigate to Support
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'Terms of Service & Privacy Policy',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                    ),
                    onTap: () {
                      // TODO: Navigate to Terms
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'App Version 1.0.0',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
