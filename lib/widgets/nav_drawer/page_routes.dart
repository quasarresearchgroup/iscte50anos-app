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

  static Future<void> animateToPage(BuildContext context,
      {required Widget page}) async {
    Future<Widget> buildPageAsync({required Widget page}) async {
      return Future.microtask(
        () {
          return page;
        },
      );
    }

    Widget futurePage = await buildPageAsync(page: page);
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRoutes.createRoute(
        widget: futurePage,
      ),
    );
  }

  static Future<void> replacePushanimateToPage(BuildContext context,
      {required Widget page}) async {
    Future<Widget> buildPageAsync({required Widget page}) async {
      return Future.microtask(
        () {
          return page;
        },
      );
    }

    Widget futurePage = await buildPageAsync(page: page);
    Navigator.pushReplacement(
      context,
      PageRoutes.createRoute(
        widget: futurePage,
      ),
    );
  }
}
