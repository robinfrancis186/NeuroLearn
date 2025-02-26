import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/auth.dart';

class CollaborativeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showAvatar;
  final PreferredSizeWidget? bottom;

  const CollaborativeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showAvatar = true,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      bottom: bottom,
      actions: [
        if (showAvatar) ...[
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final user = authProvider.user;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
                      ? Text(user?.name?.substring(0, 1).toUpperCase() ?? '')
                      : null,
                ),
              );
            },
          ),
        ],
        if (actions != null) ...actions!,
      ],
    );
  }
} 