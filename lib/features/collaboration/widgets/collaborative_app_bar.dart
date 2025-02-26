import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../features/auth/auth.dart';

class CollaborativeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool centerTitle;
  final double elevation;
  final Widget? leading;

  const CollaborativeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.centerTitle = true,
    this.elevation = 0,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? AppColors.surface,
      leading: leading,
      actions: [
        if (actions != null) ...actions!,
        Consumer<AuthProvider>(
          builder: (context, provider, child) {
            final user = provider.user;
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: user?.avatarUrl != null 
                    ? NetworkImage(user!.avatarUrl!) as ImageProvider
                    : null,
                child: user?.avatarUrl == null
                    ? Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
} 