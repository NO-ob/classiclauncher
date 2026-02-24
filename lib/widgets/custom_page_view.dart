import 'package:classiclauncher/models/key_press.dart';
import 'package:classiclauncher/screens/select_gesture_detector.dart';
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
  final ValueNotifier<int> pageNotifier;

  const CustomPageView({super.key, required this.constraints, required this.children, required this.pageNotifier});

  @override
  State<CustomPageView> createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final ValueNotifier<Direction?> direction = ValueNotifier(null);
  late List<Widget> children;

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    currentPage = widget.pageNotifier.value;
    children = widget.children.map((c) => RepaintBoundary(child: c)).toList();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300), lowerBound: 0, upperBound: 1.0);

    controller.addListener(() {
      if (controller.isCompleted && controller.value == 1) {
        if (direction.value == Direction.left && currentPage < children.length - 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setPage(currentPage + 1);
            controller.reset();
          });
        } else if (direction.value == Direction.right && currentPage > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setPage(currentPage - 1);
            controller.reset();
          });
        }
      }
    });

    widget.pageNotifier.addListener(() {
      int newPage = widget.pageNotifier.value;

      if (newPage == currentPage) {
        return;
      }

      if (newPage > widget.children.length - 1) {
        widget.pageNotifier.value = widget.children.length - 1;
        return;
      }

      if (newPage < 0) {
        widget.pageNotifier.value = 0;

        return;
      }

      if (newPage > currentPage) {
        direction.value = Direction.left;
      }
      if (newPage < currentPage) {
        direction.value = Direction.right;
      }

      controller.animateTo(1, duration: Duration(milliseconds: 150));
    });
  }

  void setPage(int page) {
    widget.pageNotifier.value = page;
    setState(() => currentPage = page);
  }

  @override
  void didUpdateWidget(CustomPageView old) {
    super.didUpdateWidget(old);
    if (widget.children != old.children) {
      children = widget.children.map((c) => RepaintBoundary(child: c)).toList();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = widget.constraints.maxWidth;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => direction.value = null,
      onHorizontalDragUpdate: (details) {
        if (direction.value == null) {
          direction.value = details.delta.dx < 0 ? Direction.left : Direction.right;
        }
        if (direction.value == Direction.right) {
          controller.value += details.delta.dx / maxWidth;
        } else {
          controller.value -= details.delta.dx / maxWidth;
        }
      },
      onHorizontalDragEnd: (_) {
        if (currentPage == 0 && direction.value == Direction.right) {
          controller.animateTo(0, duration: Duration(milliseconds: 300));
          return;
        }
        if (currentPage == children.length - 1 && direction.value == Direction.left) {
          controller.animateTo(0, duration: Duration(milliseconds: 300));
          return;
        }
        int timeLeft = 300 - (300 * controller.value).toInt();
        if (controller.value > 0.3) {
          controller.animateTo(1, duration: Duration(milliseconds: timeLeft));
        } else {
          controller.animateTo(0, duration: Duration(milliseconds: timeLeft));
        }
      },
      child: AnimatedBuilder(
        animation: controller,
        child: CustomPage(
          width: widget.constraints.maxWidth,
          height: widget.constraints.maxHeight,
          directionNotifier: direction,
          controller: controller,
          currentPage: currentPage,
          children: children,
        ),
        builder: (_, child) => child!,
      ),
    );
  }
}
