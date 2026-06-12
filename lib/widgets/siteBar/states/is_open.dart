import 'package:flutter/widgets.dart';

class IsSideBarOpen extends ValueNotifier<bool> {
  IsSideBarOpen({bool? isOpenByDefault}) : super(isOpenByDefault ?? false);

  static final IsSideBarOpen _instance = IsSideBarOpen();
  static IsSideBarOpen get instance => _instance;
}
