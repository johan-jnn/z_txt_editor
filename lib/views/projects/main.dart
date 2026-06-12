import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectIndex extends StatelessWidget {
  const ProjectIndex({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            context.goNamed("home");
          },
          child: const Text("Go back your mf"),
        ),
      ],
    );
  }
}
