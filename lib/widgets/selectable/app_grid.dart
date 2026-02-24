import 'dart:async';
import 'dart:math' as math;

import 'package:classiclauncher/handlers/app_grid_handler.dart';
import 'package:classiclauncher/handlers/app_handler.dart';
import 'package:classiclauncher/handlers/theme_handler.dart';
import 'package:classiclauncher/models/app_info.dart';
import 'package:classiclauncher/models/enums.dart';
import 'package:classiclauncher/models/key_press.dart';
import 'package:classiclauncher/models/theme/app_grid_theme.dart';
import 'package:classiclauncher/models/theme/launcher_theme.dart';
import 'package:classiclauncher/widgets/app_drag_overlay.dart';
import 'package:classiclauncher/widgets/app_page.dart';
import 'package:classiclauncher/widgets/custom_page_view.dart';
import 'package:classiclauncher/widgets/selectable/selectable.dart';
import 'package:classiclauncher/widgets/selectable/selectable_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppGrid extends StatefulWidget {
  final BoxConstraints constraints;
  const AppGrid({super.key, required this.constraints});

  @override
  State<AppGrid> createState() => _AppGridState();
}

class _AppGridState extends State<AppGrid> with SingleTickerProviderStateMixin implements SelectableZone {
  SelectableController? controller;
  AppHandler appHandler = Get.find<AppHandler>();
  ThemeHandler themeHandler = Get.find<ThemeHandler>();
  AppGridHandler appGridHandler = Get.find<AppGridHandler>();
  List<AppInfo> installedApps = [];

  late Direction nextDirection;
  late Direction prevDirection;
  late int childrenPerPage;
  late LauncherTheme launcherTheme;
  int lastPageCount = -1;
  late StreamSubscription installedAppsSub;

  @override
  String zoneKey = "AppGrid";
  @override
  int currentIndex = 0;

  @override
  void initState() {
    launcherTheme = themeHandler.theme.value;
    installedApps = appHandler.installedApps.toList();
    appGridHandler.initAnimation(this);

    installedAppsSub = appHandler.installedApps.listen((newApps) {
      if (!mounted) {
        return;
      }

      if (listEquals(installedApps, newApps)) {
        return;
      }
      setState(() => installedApps = newApps.toList());
    });

    ever(themeHandler.theme, (LauncherTheme theme) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          launcherTheme = themeHandler.theme.value;
        }
      });
    });

    ever(appGridHandler.dragging, (bool dragging) {
      if (!dragging) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller?.selectedItemNotifier.value = null;
      });
    });

    super.initState();
  }

  @override
  int handleMove(Direction direction, MoveType moveType) {
    List<AppInfo> apps = appHandler.installedApps;

    int columns = themeHandler.theme.value.appGridTheme.columns;
    int rows = themeHandler.theme.value.appGridTheme.rows;
    int appCount = apps.length;
    int appsPerPage = themeHandler.theme.value.appGridTheme.appsPerPage;
    int maxPage = ((appCount / appsPerPage).ceil() - 1);
    int localIndex = currentIndex % appsPerPage;
    int currentRow = localIndex ~/ columns;
    int currentCol = localIndex % columns;
    int currentPage = appGridHandler.pageNotifier.value;
    int indexPage = currentIndex ~/ appsPerPage;

    bool isTopEdge = currentRow == 0;
    bool isBottomEdge = currentRow == rows - 1;
    bool isLeftEdge = currentCol == 0;
    bool isRightEdge = currentCol == columns - 1;

    bool editing = appHandler.editingApps.value;

    if (indexPage != currentPage) {
      int localIndex = currentIndex % appsPerPage;
      int pageStart = currentPage * appsPerPage;

      currentIndex = (pageStart + localIndex).clamp(0, appCount - 1);
    }

    switch (direction) {
      case Direction.up:

        // dont goto sibling while editing
        if (isTopEdge && editing) {
          return currentIndex;
        }
        // return to controller to handle if at top
        if (isTopEdge) {
          return -1;
        }

        currentIndex -= columns;

      case Direction.down:

        // dont goto sibling while editing
        if (isBottomEdge && editing) {
          return currentIndex;
        }

        // return to controller to handle if at bottom
        if (isBottomEdge) {
          return -1;
        }

        int next = currentIndex + columns;

        // return to controller to handle if last
        if (next >= appCount) {
          return -1;
        }
        currentIndex = next;

      case Direction.left:
        // return to controller to handle if at left side
        if (isLeftEdge && currentPage == 0) {
          return -1;
        }

        // dont change page if soft
        if (isLeftEdge && moveType == MoveType.soft) {
          return currentIndex;
        }

        // change page if hard, set index to touching row
        if (isLeftEdge && moveType == MoveType.hard) {
          final prevPageStart = (currentPage - 1) * appsPerPage;
          currentIndex = prevPageStart + (currentRow * columns) + (columns - 1);
          scrollToPage(currentPage - 1);
          break;
        }
        currentIndex--;

      case Direction.right:
        // return to controller to handle if at left side
        if (isRightEdge && currentPage == maxPage) {
          return -1;
        }

        // dont change page if soft
        if (isRightEdge && moveType == MoveType.soft) {
          return currentIndex;
        }

        // change page if hard, set index to touching row
        if (isRightEdge && moveType == MoveType.hard) {
          final nextPageStart = (currentPage + 1) * appsPerPage;
          final next = (nextPageStart + currentRow * columns).clamp(0, appCount - 1);
          currentIndex = next;
          scrollToPage(currentPage + 1);
          break;
        }

        if (currentIndex + 1 >= appCount) {
          return currentIndex;
        }
        currentIndex++;
    }

    currentIndex = currentIndex.clamp(0, appCount - 1);

    if (appGridHandler.editing.value && appGridHandler.moving.value != null) {
      appHandler.moveApp(appPosition: currentIndex, app: appGridHandler.moving.value!);
    }

    return currentIndex;
  }

  void scrollToPage(int index) async {
    appGridHandler.pageNotifier.value = index;
  }

  @override
  void dispose() {
    controller?.unregisterZone(this);
    appGridHandler.editingAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController = Selectable.of(context).controller;

    if (controller != newController) {
      controller?.unregisterZone(this);
      controller = newController;
      controller!.registerZone(this, currentIndex, preferredZoneIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    int columns = themeHandler.theme.value.appGridTheme.columns;
    int rows = themeHandler.theme.value.appGridTheme.rows;
    int appsPerPage = rows * columns;

    List<Widget> pages = [];

    for (int i = 0; i < (installedApps.length / appsPerPage).ceil(); i++) {
      int start = i * themeHandler.theme.value.appGridTheme.appsPerPage;
      int end = math.min(start + themeHandler.theme.value.appGridTheme.appsPerPage, appHandler.installedApps.length);

      List<AppInfo> pageApps = appHandler.installedApps.sublist(start, end);
      pages.add(
        AppPage(
          key: ValueKey("AppGrid::page_$i"),
          page: i,
          selectableKey: zoneKey,
          apps: pageApps,
          width: widget.constraints.maxWidth,
          height: widget.constraints.maxHeight,
        ),
      );
    }

    return Listener(
      behavior: HitTestBehavior.translucent,

      onPointerUp: (event) {
        appGridHandler.fingerX.value = null;
        appGridHandler.fingerY.value = null;
      },
      onPointerDown: (PointerDownEvent event) {
        appGridHandler.fingerX.value = event.localPosition.dx;
        appGridHandler.fingerY.value = event.localPosition.dy;
      },
      onPointerMove: (event) {
        double zoneWidth = themeHandler.theme.value.appGridTheme.appGridEdgeHoverZoneWidth;

        appGridHandler.fingerX.value = event.localPosition.dx;
        appGridHandler.fingerY.value = event.localPosition.dy;

        if (event.localPosition.dx < zoneWidth || event.localPosition.dx > (widget.constraints.maxWidth - zoneWidth)) {
          if (appGridHandler.pageChangeEdgeTimer.value != null) {
            return;
          }
          appGridHandler.pageChangeEdgeTimer.value = Timer(themeHandler.theme.value.appGridTheme.appGridEdgeHoverDuration, () {
            if (appGridHandler.fingerX.value == null) {
              appGridHandler.clearTimer();
              return;
            }

            if (appGridHandler.fingerX.value! < zoneWidth) {
              appGridHandler.pageNotifier.value--;
            }

            if (appGridHandler.fingerX.value! > (widget.constraints.maxWidth - zoneWidth)) {
              appGridHandler.pageNotifier.value++;
            }

            appGridHandler.pageChangeEdgeTimer.value = null;
          });
        } else if (appGridHandler.pageChangeEdgeTimer.value != null) {
          appGridHandler.clearTimer();
        }
      },
      child: Stack(
        children: [
          AppDragOverlay(width: widget.constraints.maxWidth, height: widget.constraints.maxHeight),
          CustomPageView(constraints: widget.constraints, pageNotifier: appGridHandler.pageNotifier, children: pages),
        ],
      ),
    );
  }

  @override
  int? preferredZoneIndex = 0;
}
