import 'dart:async';

import 'package:classiclauncher/handlers/app_grid_handler.dart';
import 'package:classiclauncher/handlers/app_handler.dart';
import 'package:classiclauncher/models/app_info.dart';
import 'package:classiclauncher/handlers/theme_handler.dart';
import 'package:classiclauncher/utils/logger.dart';
import 'package:classiclauncher/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppPage extends StatefulWidget {
  final double width;
  final double height;
  final int page;
  final String selectableKey;
  final List<AppInfo> apps;
  const AppPage({super.key, required this.apps, required this.width, required this.height, required this.page, required this.selectableKey});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final AppHandler appHandler = Get.find<AppHandler>();
  final ThemeHandler themeHandler = Get.find<ThemeHandler>();
  final AppGridHandler appGridHandler = Get.find<AppGridHandler>();

  late List<Widget> children;

  @override
  void initState() {
    Logger().log(location: "AppPage.initState", message: "app page #${widget.page} init ${widget.apps.length} building apps");
    setChildren();
    super.initState();
  }

  void setChildren() {
    children = [
      for (int index = 0; index < widget.apps.length; index++)
        PositionedAppCard(
          key: ValueKey("PosititonedAppCard::${widget.apps[index].packageName}"),
          index: index,
          app: widget.apps[index],
          selectableKey: widget.selectableKey,
          pageWidth: widget.width,
          pageHeight: widget.height,
        ),
    ];
  }

  @override
  void didUpdateWidget(AppPage old) {
    super.didUpdateWidget(old);
    if (widget.apps != old.apps) {
      Logger().log(location: "AppPage.didUpdateWidget", message: "app page #${widget.page} update ${widget.apps.length} building apps");
      setChildren();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      return Padding(
        padding: themeHandler.theme.value.appGridTheme.appGridOutterPadding,
        child: Stack(children: children),
      );
    });
  }
}

class PositionedAppCard extends StatefulWidget {
  final AppInfo app;
  final int index;
  final double pageWidth;
  final double pageHeight;
  final String selectableKey;
  const PositionedAppCard({super.key, required this.app, required this.index, required this.selectableKey, required this.pageWidth, required this.pageHeight});

  @override
  State<PositionedAppCard> createState() => _PositionedAppCardState();
}

class _PositionedAppCardState extends State<PositionedAppCard> {
  final AppHandler appHandler = Get.find<AppHandler>();
  final ThemeHandler themeHandler = Get.find<ThemeHandler>();
  final AppGridHandler appGridHandler = Get.find<AppGridHandler>();

  @override
  void initState() {
    Logger().log(location: "PositionedAppCard.initState", message: "positioned app init #${widget.index}, ${widget.app}");

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int columns = themeHandler.theme.value.appGridTheme.columns;

    double columnSpace = themeHandler.theme.value.appGridTheme.columnSpacing;
    double rowSpace = themeHandler.theme.value.appGridTheme.rowSpacing;
    double boxWidth = themeHandler.getCardWidth(gridWidth: widget.pageWidth);
    double boxHeight = themeHandler.getCardHeight(gridHeight: widget.pageHeight);

    int row = widget.index ~/ columns;
    int col = widget.index % columns;

    double top = row * (boxHeight + rowSpace);
    double left = col * (boxWidth + columnSpace);

    return Obx(() {
      bool dragging = appGridHandler.dragging.value;

      return AnimatedPositioned(
        key: ValueKey("AnimatedPositioned::$runtimeType::${widget.app.packageName}"),
        duration: dragging ? Duration(milliseconds: 250) : Duration(milliseconds: 50),
        top: top,
        left: left,
        child: AppCard(
          key: ValueKey("AppCard::${widget.app.packageName}"),
          appInfo: widget.app,
          width: boxWidth,
          height: boxHeight,
          selectableKey: widget.selectableKey,
        ),
      );
    });
  }
}
