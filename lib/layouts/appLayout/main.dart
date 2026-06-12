import 'package:flutter/material.dart';
import 'package:z_txt_editor/widgets/appBar/main.dart';
import 'package:z_txt_editor/widgets/siteBar/main.dart';

class _AppLayoutState extends State<AppLayout> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(flexibleSpace: ZTxtEditorAppBar()),
          body: widget.child,
        ),
        SideBar(),
      ],
    );
  }
}

class AppLayout extends StatefulWidget {
  final Widget child;
  const AppLayout({required this.child, super.key});

  @override
  State<StatefulWidget> createState() => _AppLayoutState();
}
