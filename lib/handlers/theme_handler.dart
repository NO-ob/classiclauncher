import 'dart:convert';
import 'dart:typed_data';

import 'package:classiclauncher/handlers/app_handler.dart';
import 'package:classiclauncher/handlers/config_handler.dart';
import 'package:classiclauncher/models/theme/launcher_theme.dart';
import 'package:classiclauncher/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeHandler extends GetxController {
  Rx<LauncherTheme> theme = Rx(LauncherTheme());

  @override
  void onInit() {
    super.onInit();
    //q10 theme
    /* theme.value = LauncherTheme().copyWith(
      pageIndicatorTheme: launcherTheme.pageIndicatorTheme.copyWith(
        indicatorShape: IndicatorShape.squircle,
        pageIndicatorActiveSize: 22,
        pageIndicatorInactiveSize: 14,
      ),
      appGridTheme: launcherTheme.appGridTheme.copyWith(
        columns: 4,
        columnSpacing: 28,
        rowSpacing: 8,
        iconSize: 78,
        appCardIconPadding: EdgeInsets.only(bottom: 14, left: 4, right: 4, top: 4),
        selectorTheme: launcherTheme.appGridTheme.selectorTheme.copyWith(selectorBorderRadius: 12),
        appCardGradient: LinearGradient(colors: [Colors.black12, Colors.black54], begin: AlignmentGeometry.topCenter, end: AlignmentGeometry.bottomCenter),
        cornerRadius: 12,
      ),
    );*/
    loadThemeFromStorage();
  }

  void loadThemeFromStorage() async {
    String themeString = await Get.find<ConfigHandler>().loadConfig(configType: ConfigType.theme);

    try {
      LauncherTheme newTheme = LauncherTheme.fromJson(jsonDecode(themeString));
      theme.value = newTheme;
    } catch (e, stackTrace) {
      Logger().log(location: "ThemeHandler.loadThemeFromStorage", message: "Failed to load stored theme $e, $stackTrace", level: LogLevel.exception);
    }
  }

  double getCardHeight({required double gridHeight}) {
    return (gridHeight - theme.value.appGridTheme.gridOutterTopsSize - (theme.value.appGridTheme.rowSpacing * (theme.value.appGridTheme.rows - 1))) /
        theme.value.appGridTheme.rows;
  }

  double getCardWidth({required double gridWidth}) {
    return (gridWidth - theme.value.appGridTheme.gridOutterSideSize - (theme.value.appGridTheme.columnSpacing * (theme.value.appGridTheme.columns - 1))) /
        theme.value.appGridTheme.columns;
  }

  Future<void> exportTheme() async {
    AppHandler appHandler = Get.find<AppHandler>();

    try {
      final String? path = await appHandler.getSAFDirectoryAccess();

      if (path == null) {
        return;
      }

      String fileName = 'theme_${DateTime.now()}';

      await appHandler.writeFile(utf8.encode(jsonEncode(theme.value)), fileName, 'text/json', 'json', path);

      Get.snackbar("Theme exported ( Ո‿Ո)", "saved to $fileName.json ...", backgroundColor: Colors.black54, colorText: Colors.white);
    } catch (e, stackTrace) {
      Logger().log(location: "ThemeHandler.exportTheme", message: "Failed to export theme $e, $stackTrace", level: LogLevel.exception);
      Get.snackbar("Failed to export theme ૮(˶ㅠ︿ㅠ)ა", "$e", backgroundColor: Colors.black54, colorText: Colors.white);
    }
  }

  Future<void> importTheme() async {
    AppHandler appHandler = Get.find<AppHandler>();

    try {
      final String path = await appHandler.getSAFUri();

      Uint8List? bytes = await appHandler.getSAFFile(path);

      if (bytes == null) {
        throw Exception("null bytes returning");
      }

      LauncherTheme newTheme = LauncherTheme.fromJson(jsonDecode(utf8.decode(bytes)));

      theme.value = newTheme;

      Get.find<ConfigHandler>().saveConfig(config: jsonEncode(newTheme), configType: ConfigType.theme);

      Get.snackbar("Theme imported ( Ո‿Ո)", "theme has been imported and stored", backgroundColor: Colors.black54, colorText: Colors.white);
    } catch (e, stackTrace) {
      Logger().log(location: "ThemeHandler.importTheme", message: "Failed to import theme $e, $stackTrace", level: LogLevel.exception);
      Get.snackbar("Failed to import theme ૮(˶ㅠ︿ㅠ)ა", "$e", backgroundColor: Colors.black54, colorText: Colors.white);
    }
  }

  Future<void> resetTheme() async {
    try {
      theme.value = LauncherTheme();

      Get.find<ConfigHandler>().deleteConfig(configType: ConfigType.theme);

      Get.snackbar("Theme cleared ( Ո‿Ո)", "theme has been reset to default", backgroundColor: Colors.black54, colorText: Colors.white);
    } catch (e, stackTrace) {
      Logger().log(location: "ThemeHandler.resetTheme", message: "Failed to reset theme $e, $stackTrace", level: LogLevel.exception);
      Get.snackbar("Failed to reset theme ૮(˶ㅠ︿ㅠ)ა", "$e", backgroundColor: Colors.black54, colorText: Colors.white);
    }
  }
}
