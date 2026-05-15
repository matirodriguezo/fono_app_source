import 'package:flutter/material.dart';

class Breakpoints {
  Breakpoints._();

  static const double mobileWidth = 800;
  static const double desktopWidth = 1200;
  static const double tabletShortestSide = 650;
  static const double minContentHeight = 600;
  static const double landscapeMinHeight = 500;
}

extension ResponsiveContext on BuildContext {
  bool get isMobileWidth => MediaQuery.of(this).size.width < Breakpoints.mobileWidth;
  bool get isDesktopWidth => MediaQuery.of(this).size.width >= Breakpoints.desktopWidth;

  bool get isMobileScreen {
    final size = MediaQuery.of(this).size;
    return size.shortestSide < Breakpoints.tabletShortestSide || size.height < Breakpoints.minContentHeight;
  }

  bool get isMobileLandscape {
    final size = MediaQuery.of(this).size;
    final orientation = MediaQuery.of(this).orientation;
    return isMobileScreen && orientation == Orientation.landscape && size.height < Breakpoints.landscapeMinHeight;
  }
}
