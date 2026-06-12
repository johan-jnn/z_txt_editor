import 'package:go_router/go_router.dart';
import 'package:z_txt_editor/layouts/appLayout/main.dart';
import 'package:z_txt_editor/views/home/main.dart';
import 'package:z_txt_editor/views/projects/main.dart';

final appRoutes = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppLayout(child: child);
      },
      routes: [
        GoRoute(path: '/', name: "home", builder: (context, state) => Home()),
        GoRoute(
          path: '/projects',
          name: "projects",
          builder: (context, state) => ProjectIndex(),
        ),
      ],
    ),
  ],
);
