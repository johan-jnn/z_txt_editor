import 'package:flutter/material.dart';
import 'package:z_txt_editor/widgets/siteBar/toggler.dart';

class ZTxtEditorAppBar extends StatelessWidget {
  const ZTxtEditorAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [SideBarToggler(), Text("Z-Txt-Editor")]);
  }
}
