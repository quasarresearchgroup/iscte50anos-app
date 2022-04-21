
import 'package:flutter/widgets.dart';

class PageRoutes {
  static Route createRoute({
    required Widget widget,
    Duration transitionDuration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder(
      transitionDuration: transitionDuration,
      maintainState: true,
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.ease));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

}
