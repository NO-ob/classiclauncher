import 'dart:async';
import 'dart:ui';

import 'package:classiclauncher/handlers/app_grid_handler.dart';
import 'package:classiclauncher/handlers/app_handler.dart';
import 'package:classiclauncher/models/app_info.dart';
import 'package:classiclauncher/handlers/theme_handler.dart';
import 'package:classiclauncher/screens/select_gesture_detector.dart';
import 'package:classiclauncher/screens/selectable_container.dart';
import 'package:classiclauncher/utils/launcher_utils.dart';
import 'package:classiclauncher/utils/logger.dart';
import 'package:classiclauncher/widgets/shadowed_image.dart';
import 'package:classiclauncher/widgets/uninstall_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppCard extends StatefulWidget {
  final AppInfo appInfo;
  final double width;
  final double height;
  final String selectableKey;
  const AppCard({super.key, required this.appInfo, required this.width, required this.height, required this.selectableKey});

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  ThemeHandler themeHandler = Get.find<ThemeHandler>();
  AppHandler appHandler = Get.find<AppHandler>();
  AppGridHandler appGridHandler = Get.find<AppGridHandler>();

  bool isFingerDown = false;

  @override
  void dispose() {
    super.dispose();
  }

  void startEdit(bool dragging) {
    appGridHandler.dragging.value = dragging;
    appGridHandler.editing.value = true;
    LauncherUtils.doFeedback();
    appGridHandler.moving.value = widget.appInfo;

    print("appGridHandler.moving.value");
  }

  void onDropApp() async {
    appGridHandler.clearMove();

    if (appGridHandler.appMoveCol == null && appGridHandler.appMoveRow == null) {
      return;
    }

    int appsPerPage = themeHandler.theme.value.appGridTheme.appsPerPage;

    int pageStart = 0 + (appsPerPage * appGridHandler.pageNotifier.value);

    int offset = (appGridHandler.appMoveRow! * themeHandler.theme.value.appGridTheme.columns) + appGridHandler.appMoveCol!;

    int appPosition = pageStart + offset;

    await appHandler.moveApp(appPosition: appPosition, app: widget.appInfo);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appGridHandler.dragging.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      hitTestBehavior: HitTestBehavior.translucent,
      hapticFeedbackOnStart: false,
      maxSimultaneousDrags: 11,
      onDragStarted: () {
        Logger().log(location: "AppCard.build", message: "drag started");
        startEdit(true);
      },
      onDraggableCanceled: (velocity, offset) {
        Logger().log(location: "AppCard.build", message: "cancelled");
        onDropApp();
      },
      onDragEnd: (details) {
        Logger().log(location: "AppCard.build", message: "dragend");
        onDropApp();
      },
      onDragCompleted: () {
        Logger().log(location: "AppCard.build", message: "ondropapp");
        onDropApp();
      },
      delay: Duration(milliseconds: 300),

      feedback: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: themeHandler.theme.value.appGridTheme.appCardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: themeHandler.theme.value.appGridTheme.appCardIconPadding,
                  child: Obx(
                    () => ShadowedImage(
                      width: themeHandler.theme.value.appGridTheme.iconSize,
                      height: themeHandler.theme.value.appGridTheme.iconSize,
                      imageBytes: appHandler.appIcons[widget.appInfo.packageName],
                    ),
                  ),
                ),
                Text(widget.appInfo.title, textAlign: TextAlign.center, style: themeHandler.theme.value.appGridTheme.appCardTextStyle),
              ],
            ),
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: appGridHandler.editingAnimationController,
        builder: (_, __) {
          return Transform.scale(
            scale: appGridHandler.editingScaleAnimation.value,
            child: Stack(
              children: [
                Container(
                  key: ValueKey("AppCard::${widget.appInfo.packageName}::${widget.width}::${widget.height}${appHandler.installedApps.indexOf(widget.appInfo)}"),
                  width: widget.width,
                  height: widget.height,
                  decoration: (appGridHandler.moving.value == widget.appInfo && appGridHandler.editing.value && appGridHandler.dragging.value)
                      ? null
                      : themeHandler.theme.value.appGridTheme.appCardDecoration,
                  child: SelectableContainer(
                    selectableKey: "${widget.selectableKey}_${appHandler.installedApps.indexOf(widget.appInfo)}",
                    selectorTheme: themeHandler.theme.value.appGridTheme.selectorTheme,
                    canLongPress: () {
                      return !appGridHandler.editing.value;
                    },

                    onTapDown: (details) {
                      setState(() {
                        isFingerDown = true;
                      });
                    },
                    onTapUp: (details) {
                      setState(() {
                        isFingerDown = false;
                      });
                    },
                    onTap: () {
                      if (appGridHandler.editing.value) {
                        appGridHandler.stopEdit();
                        appGridHandler.clearMove();
                        return;
                      }
                      appHandler.launchApp(widget.appInfo);
                    },
                    onLongPress: () {
                      startEdit(false);
                    },
                    child: Obx(() {
                      if (appGridHandler.moving.value == widget.appInfo && appGridHandler.editing.value && appGridHandler.dragging.value) {
                        return SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: themeHandler.theme.value.appGridTheme.appCardIconPadding,
                            child: Obx(
                              () => ShadowedImage(
                                width: themeHandler.theme.value.appGridTheme.iconSize,
                                height: themeHandler.theme.value.appGridTheme.iconSize,
                                imageBytes: appHandler.appIcons[widget.appInfo.packageName],
                              ),
                            ),
                          ),
                          Text(widget.appInfo.title, textAlign: TextAlign.center, style: themeHandler.theme.value.appGridTheme.appCardTextStyle),
                        ],
                      );
                    }),
                  ),
                ),
                if (appGridHandler.editing.value)
                  Obx(() {
                    if (appGridHandler.moving.value == widget.appInfo && appGridHandler.editing.value && appGridHandler.dragging.value) {
                      return SizedBox.shrink();
                    }

                    return Positioned(right: 0, top: 0, child: UninstallButton(appInfo: widget.appInfo));
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
