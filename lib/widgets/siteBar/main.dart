import 'package:flutter/material.dart';
import 'package:z_txt_editor/widgets/siteBar/states/is_open.dart';

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin {
  final openStatus = IsSideBarOpen.instance;

  late final _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300),
  );
  late final _animation = Tween<Offset>(
    begin: Offset(-1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: openStatus,
      builder: (_, Widget? child) {
        if (openStatus.value) {
          _controller.forward();
        } else {
          _controller.reverse();
        }

        return child!;
      },
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: SlideTransition(
              position: _animation,
              child: Column(
                children: [Text("1"), Text("2"), Text("3"), Text("4")],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SideBarState();
  }
}
