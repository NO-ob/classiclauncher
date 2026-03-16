import 'package:classiclauncher/models/key_press.dart';
import 'package:classiclauncher/screens/select_gesture_detector.dart';
import 'package:classiclauncher/utils/custom_page_controller.dart';
import 'package:classiclauncher/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/*class CustomPageTest extends StatefulWidget {
  final List<Widget> children;
  final double width;
  final double height;
  final AnimationController controller;
  final ValueNotifier<Direction?> directionNotifier;

  final int currentPage;

  const CustomPageTest({
    super.key,
    required this.children,
    required this.width,
    required this.height,
    required this.controller,
    required this.directionNotifier,
    required this.currentPage,
  });

  @override
  State<CustomPageTest> createState() => _CustomPageTestState();
}

class _CustomPageTestState extends State<CustomPageTest> {
  late final Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return SizedBox.shrink();

    print("moving ${widget.currentPage} -> ${widget.directionNotifier.value}");

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ValueListenableBuilder<Direction?>(
        valueListenable: widget.directionNotifier,
        builder: (context, direction, _) => AnimatedBuilder(
          animation: widget.controller,
          builder: (_, __) {
            double t = widget.controller.value;
            return Stack(
              children: [
                Positioned(
                  left: -t * widget.width + (-widget.width * widget.currentPage),
                  height: widget.height,
                  top: 0,
                  child: SizedBox(
                    width: widget.children.length * widget.width,
                    height: widget.height,
                    child: Row(
                      children: [for (Widget child in widget.children) SizedBox(height: widget.height, width: widget.width, child: child)],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}*/

class CustomPage extends StatefulWidget {
  final List<Widget> children;
  final double width;
  final double height;
  final AnimationController controller;
  final ValueNotifier<Direction?> directionNotifier;

  final int currentPage;

  const CustomPage({
    super.key,
    required this.children,
    required this.width,
    required this.height,
    required this.controller,
    required this.directionNotifier,
    required this.currentPage,
  });

  @override
  State<CustomPage> createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  late final Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return SizedBox.shrink();

    Logger().log(location: "CustomPage.build", message: "moving ${widget.currentPage} -> ${widget.directionNotifier.value}");

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ValueListenableBuilder<Direction?>(
        valueListenable: widget.directionNotifier,
        builder: (context, direction, _) => AnimatedBuilder(
          animation: widget.controller,
          builder: (_, __) {
            double t = widget.controller.value;
            return Stack(
              children: [
                if (widget.currentPage + 1 < widget.children.length)
                  Transform.translate(
                    offset: Offset(direction == Direction.left ? (widget.width - (t * widget.width) - ((1 - t) * (widget.width * 0.3))) : widget.width, 0),
                    child: Opacity(
                      opacity: widget.controller.value,
                      child: Transform.scale(scale: scaleAnimation.value, child: widget.children[widget.currentPage + 1]),
                    ),
                  ),

                if (widget.currentPage - 1 >= 0)
                  Transform.translate(
                    offset: Offset(direction == Direction.right ? -(widget.width - (t * widget.width) - ((1 - t) * (widget.width * 0.3))) : widget.width, 0),
                    child: Opacity(
                      opacity: widget.controller.value,
                      child: Transform.scale(scale: scaleAnimation.value, child: widget.children[widget.currentPage - 1]),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(direction == Direction.left ? -(t * widget.width) : t * widget.width, 0),
                  child: widget.children[widget.currentPage],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CustomPageView extends StatefulWidget {
  final BoxConstraints constraints;
  final List<Widget> children;
  final CustomPageController controller;

  const CustomPageView({super.key, required this.constraints, required this.children, required this.controller});

  @override
  State<CustomPageView> createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> with SingleTickerProviderStateMixin {
  late List<Widget> children;

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    currentPage = widget.controller.currentPage.value;
    widget.controller.pages = widget.children.length;

    children = widget.children.map((c) => RepaintBoundary(child: c)).toList();

    widget.controller.currentPage.addListener(() {
      if (widget.controller.currentPage.value < 0) {
        widget.controller.currentPage.value == 0;
      }

      if (widget.controller.currentPage.value >= widget.children.length) {
        widget.controller.currentPage.value == widget.children.length - 1;
      }

      setState(() {
        currentPage = widget.controller.currentPage.value;
      });
    });
  }

  @override
  void didUpdateWidget(CustomPageView old) {
    super.didUpdateWidget(old);
    if (widget.children != old.children) {
      widget.controller.pages = widget.children.length;
      children = widget.children.map((c) => RepaintBoundary(child: c)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = widget.constraints.maxWidth;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => widget.controller.direction.value = null,
      onHorizontalDragUpdate: (details) {
        widget.controller.direction.value ??= details.delta.dx < 0 ? Direction.left : Direction.right;
        if (widget.controller.direction.value == Direction.right) {
          widget.controller.animationController.value += details.delta.dx / maxWidth;
        } else {
          widget.controller.animationController.value -= details.delta.dx / maxWidth;
        }
      },
      onHorizontalDragEnd: (_) {
        int pageTime = 200;
        int timeLeft = ((1 - widget.controller.animationController.value) * pageTime).round();
        if (currentPage <= 0 && widget.controller.direction.value == Direction.right) {
          widget.controller.animationController.animateTo(
            0,
            duration: Duration(milliseconds: timeLeft),
            curve: Curves.bounceIn,
          );
          return;
        }
        if (currentPage >= children.length - 1 && widget.controller.direction.value == Direction.left) {
          widget.controller.animationController.animateTo(
            0,
            duration: Duration(milliseconds: timeLeft),
            curve: Curves.bounceIn,
          );
          return;
        }

        if (widget.controller.animationController.value < 0.2) {
          widget.controller.animationController.animateTo(
            0,
            duration: Duration(milliseconds: timeLeft),
            curve: Curves.bounceIn,
          );
          return;
        }

        widget.controller.direction.value == Direction.left ? widget.controller.next() : widget.controller.previous();
      },
      child: AnimatedBuilder(
        animation: widget.controller.animationController,
        child: CustomPage(
          width: widget.constraints.maxWidth,
          height: widget.constraints.maxHeight,
          directionNotifier: widget.controller.direction,
          controller: widget.controller.animationController,
          currentPage: currentPage,
          children: children,
        ),
        builder: (_, child) => child!,
      ),
    );
  }
}
