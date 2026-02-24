import 'package:classiclauncher/handlers/app_grid_handler.dart';
import 'package:classiclauncher/handlers/app_handler.dart';
import 'package:classiclauncher/handlers/theme_handler.dart';
import 'package:classiclauncher/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDragOverlay extends StatefulWidget {
  final double width;
  final double height;
  const AppDragOverlay({super.key, required this.width, required this.height});

  @override
  State<AppDragOverlay> createState() => _AppDragOverlayState();
}

class _AppDragOverlayState extends State<AppDragOverlay> {
  final AppHandler appHandler = Get.find<AppHandler>();
  final ThemeHandler themeHandler = Get.find<ThemeHandler>();
  final AppGridHandler appGridHandler = Get.find<AppGridHandler>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!appGridHandler.editing.value) {
        return SizedBox.shrink();
      }
      if (appGridHandler.fingerX.value == null && appGridHandler.fingerY.value == null) {
        return SizedBox.shrink();
      }

      // add one to colums as we want the number of spaces beteen
      int columns = themeHandler.theme.value.appGridTheme.columns + 1;
      int rows = themeHandler.theme.value.appGridTheme.rows;
      double columnSpace = themeHandler.theme.value.appGridTheme.columnSpacing;
      double rowSpace = themeHandler.theme.value.appGridTheme.rowSpacing;
      EdgeInsets appGridPadding = themeHandler.theme.value.appGridTheme.appGridOutterPadding;
      double boxWidth = themeHandler.getCardWidth(gridWidth: widget.width);
      double boxHeight = themeHandler.getCardHeight(gridHeight: widget.height);
      double columnStride = boxWidth + columnSpace;

      double x = appGridHandler.fingerX.value!;
      double y = appGridHandler.fingerY.value!;

      double rowStride = boxHeight + rowSpace;

      double cellStartX(int col) => appGridPadding.left + (col * (boxWidth + columnSpace));
      double cellEndX(int col) => cellStartX(col) + boxWidth;
      double rowStartY(int row) => row * (boxHeight + rowSpace);
      double rowEndY(int row) => rowStartY(row) + boxHeight;

      const double snapThreshold = 30;
      const double indicatorWidth = 10.0;

      int column = (x / columnStride).ceil();
      int row = (y / rowStride).floor();

      final double gapCenterX = column * columnStride - (columnSpace / 2);

      bool locked = false;

      if (x >= (gapCenterX - snapThreshold) && x <= (gapCenterX + snapThreshold)) {
        x = gapCenterX - indicatorWidth / 2;
        locked = true;
      }

      x += appGridPadding.left;

      // Logger().log(location: "AppDragOverlay..build", message: "finger is in column: $column ,  row: $row, locked $locked");
      appGridHandler.appMoveCol = locked ? column : null;
      appGridHandler.appMoveRow = locked ? row : null;

      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            /* for (int u = 0; u < rows; u++)
              for (int i = 0; i <= columns; i++)
                Positioned(
                  top: rowStartY(u),
                  height: boxHeight,
                  left: cellStartX(i) - (columnSpace / 2),
                  width: 5,
                  child: Container(color: Colors.black),
                ),*/
            Positioned(
              top: rowStartY(row),
              height: boxHeight,
              left: x + 3,
              width: 6,

              child: Container(decoration: themeHandler.theme.value.appGridTheme.selectorTheme.decoration),
            ),
          ],
        ),
      );
    });
  }
}
