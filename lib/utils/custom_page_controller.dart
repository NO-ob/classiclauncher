import 'package:classiclauncher/models/key_press.dart';
import 'package:flutter/widgets.dart';

class CustomPageController extends ChangeNotifier {
  final TickerProvider vsync;
  late final AnimationController animationController;

  ValueNotifier<int> currentPage = ValueNotifier(0);
  final ValueNotifier<Direction?> direction = ValueNotifier(null);
  late Animation<double> animation;
  int? pages;

  CustomPageController({required this.vsync, int initialPage = 0}) {
    currentPage.value = initialPage;

    animationController = AnimationController(vsync: vsync)
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed) {
          return;
        }

        if (animationController.value == 0) {
          return;
        }

        if (animationController.value == 1) {
          currentPage.value = direction.value == Direction.left ? currentPage.value + 1 : currentPage.value - 1;
          animationController.reset();
        }
      });
  }

  void jumpTo(int page) {
    currentPage.value = page;
  }

  void animateTo(int page, {Duration? duration, Curve curve = Curves.bounceIn}) {
    if (page == currentPage.value) {
      return;
    }

    if (page < 0) {
      return;
    }

    if (pages != null && page > pages! - 1) {
      return;
    }

    direction.value = (page > currentPage.value) ? Direction.left : Direction.right;

    animation = Tween<double>(begin: animationController.value, end: 1).animate(CurvedAnimation(parent: animationController, curve: curve));

    if (duration != null) {
      animationController.duration = duration;
    } else {
      animationController.duration = Duration(milliseconds: ((1 - animationController.value) * 300).round());
    }

    animationController.forward();
  }

  void next({Duration? duration, Curve curve = Curves.bounceIn}) {
    animateTo(currentPage.value + 1, duration: duration, curve: curve);
  }

  void previous({Duration? duration, Curve curve = Curves.bounceIn}) {
    animateTo(currentPage.value - 1, duration: duration, curve: curve);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
