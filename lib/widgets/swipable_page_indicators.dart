import 'dart:async';
import 'package:classiclauncher/handlers/app_grid_handler.dart';
import 'package:classiclauncher/handlers/app_handler.dart';
import 'package:classiclauncher/handlers/theme_handler.dart';
import 'package:classiclauncher/widgets/page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwipablePageIndicators extends StatefulWidget {
  const SwipablePageIndicators({super.key});

  @override
  State<SwipablePageIndicators> createState() => SwipablePageIndicatorsState();
}

class SwipablePageIndicatorsState extends State<SwipablePageIndicators> with SingleTickerProviderStateMixin {
  final OverlayPortalController overlayController = OverlayPortalController();
  final GlobalKey pageIndicatorsKey = GlobalKey();

  final AppHandler appHandler = Get.find<AppHandler>();
  final ThemeHandler themeHandler = Get.find<ThemeHandler>();
  final AppGridHandler appGridHandler = Get.find<AppGridHandler>();
  int? hoveredPage;

  Timer? holdTimer;

  static const Duration holdDelay = Duration(milliseconds: 250);

  bool longPressActivated = false;
  Offset? fingerPosition;

  @override
  void initState() {
    appGridHandler.swipableFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    super.initState();
  }

  @override
  void dispose() {
    holdTimer?.cancel();
    super.dispose();
  }

  void _endGesture() {
    holdTimer?.cancel();

    if (longPressActivated) {
      longPressActivated = false;
      fingerPosition = null;

      appGridHandler.swipableFadeController?.reverse().then((_) {
        if (mounted) {
          overlayController.hide();
        }
      });

      setState(() {});
    }
  }

  int? _pageIndexFromFinger(Offset globalPosition, int pageCount) {
    final context = pageIndicatorsKey.currentContext;
    if (context == null) return null;

    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalPosition);

    final width = box.size.width;
    if (local.dx < 0 || local.dx > width) return null;

    final itemWidth = width / pageCount;
    final index = (local.dx / itemWidth).floor();

    return index.clamp(0, pageCount - 1);
  }

  @override
  Widget build(BuildContext context) {
    final navBarHeight = themeHandler.theme.value.navBarTheme.navBarHeight;

    return OverlayPortal(
      controller: overlayController,
      overlayChildBuilder: (context) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Obx(() {
                    final pageCount =
                        (appHandler.installedApps.length / (themeHandler.theme.value.appGridTheme.rows * themeHandler.theme.value.appGridTheme.columns)).ceil();
                    if (appGridHandler.swipableFadeController == null || appGridHandler.customPageController.value == null) {
                      return SizedBox.shrink();
                    }
                    return FadeTransition(
                      opacity: appGridHandler.swipableFadeController!,
                      child: Container(
                        height: navBarHeight,
                        width: Get.width,
                        color: themeHandler.theme.value.pageIndicatorTheme.pageIndicatorSwipeBackgroundColour,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [PageIndicators(selected: appGridHandler.customPageController.value!.currentPage, pageCount: pageCount)],
                        ),
                      ),
                    );
                  }),
                ),

                if (longPressActivated && fingerPosition != null)
                  Positioned(
                    left: fingerPosition!.dx - 20,
                    bottom: navBarHeight + themeHandler.theme.value.pageIndicatorTheme.pageIndicatorSwipeDotXOffset,
                    width: themeHandler.theme.value.pageIndicatorTheme.pageIndicatorSwipeDotSize,
                    height: themeHandler.theme.value.pageIndicatorTheme.pageIndicatorSwipeDotSize,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Obx(() {
                            if (appGridHandler.swipableFadeController == null) {
                              return SizedBox.shrink();
                            }
                            return FadeTransition(
                              opacity: appGridHandler.swipableFadeController!,
                              child: Container(
                                width: themeHandler.theme.value.pageIndicatorTheme.pageIndicatorSwipeDotSize,
                                height: themeHandler.theme.value.pageIndicatorTheme.pageIndicatorSwipeDotSize,
                                decoration: BoxDecoration(
                                  color: themeHandler.theme.value.pageIndicatorTheme.pageIndicatorSwipeDotColour,
                                  shape: BoxShape.circle,
                                  boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                                ),
                              ),
                            );
                          }),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsetsGeometry.only(top: themeHandler.theme.value.pageIndicatorTheme.pageIndicatorSwipeDotTextTopPadding),
                            child: Text(
                              "${hoveredPage == null ? appGridHandler.customPageController.value?.currentPage.value : hoveredPage! + 1}",
                              style: themeHandler.theme.value.pageIndicatorTheme.pageIndicatorSwipeDotTextSTyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,

        onPanDown: (details) {
          fingerPosition = details.globalPosition;

          holdTimer?.cancel();
          holdTimer = Timer(holdDelay, () {
            longPressActivated = true;

            overlayController.show();
            appGridHandler.swipableFadeController?.forward();

            setState(() {});
          });
        },

        onPanUpdate: (details) {
          if (!longPressActivated) return;

          fingerPosition = details.globalPosition;

          final pageCount = (appHandler.installedApps.length / (themeHandler.theme.value.appGridTheme.rows * themeHandler.theme.value.appGridTheme.columns))
              .ceil();

          final hoveredIndex = _pageIndexFromFinger(details.globalPosition, pageCount);

          if (hoveredIndex != null) {
            setState(() {
              hoveredPage = hoveredIndex;
              appGridHandler.customPageController.value?.jumpTo(hoveredIndex);
            });
          }

          setState(() {});
        },

        onPanEnd: (_) => _endGesture(),
        onPanCancel: _endGesture,

        child: SizedBox(
          height: navBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() {
                if (appGridHandler.customPageController.value == null) {
                  return SizedBox.shrink();
                }
                final pageCount =
                    (appHandler.installedApps.length / (themeHandler.theme.value.appGridTheme.rows * themeHandler.theme.value.appGridTheme.columns)).ceil();

                return PageIndicators(key: pageIndicatorsKey, selected: appGridHandler.customPageController.value!.currentPage, pageCount: pageCount);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
