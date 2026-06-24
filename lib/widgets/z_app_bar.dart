import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ZAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const ZAppBar({
    super.key,
    this.title = 'ZTextEditor',
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black87,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 15),
        overflow: TextOverflow.ellipsis,
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      actions: [
        ...actions,
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          onSelected: (value) {
            switch (value) {
              case 'home':
                context.goNamed('home');
              case 'projects':
                context.goNamed('projects');
              case 'settings':
                context.goNamed('settings');
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'home',
              child: ListTile(
                leading: Icon(Icons.home_outlined),
                title: Text('Home'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'projects',
              child: ListTile(
                leading: Icon(Icons.folder_outlined),
                title: Text('Projects'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
