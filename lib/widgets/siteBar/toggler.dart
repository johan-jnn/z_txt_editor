import 'package:flutter/material.dart';
import 'package:z_txt_editor/widgets/siteBar/states/is_open.dart';

class _SideBarTogglerState extends State<SideBarToggler> {
  final openStatus = IsSideBarOpen.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: openStatus,
      builder: (context, _) => TextButton(
        onPressed: () {
          openStatus.value = !openStatus.value;
        },
        child: Text(openStatus.value ? "Fermer le menu" : "Ouvrir le menu"),
      ),
    );
  }
}

class SideBarToggler extends StatefulWidget {
  const SideBarToggler({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SideBarTogglerState();
  }
}
