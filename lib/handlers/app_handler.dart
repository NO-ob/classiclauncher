import 'dart:async';
import 'dart:convert';

import 'package:classiclauncher/handlers/config_handler.dart';
import 'package:classiclauncher/models/app_info.dart';
import 'package:classiclauncher/screens/settings_screen.dart';
import 'package:classiclauncher/utils/constants.dart';
import 'package:classiclauncher/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppHandler extends GetxController {
  static const MethodChannel methodChannel = MethodChannel('com.noaisu.classicLauncher/app');
  RxList<AppInfo> installedApps = RxList();
  Rx<List<AppInfo>?> filteredApps = Rx(null);
  RxMap<String, Uint8List> appIcons = RxMap();
  RxMap<String, Uint8List> customAppIcons = RxMap();
  RxList<String> appPositions = RxList();
  Rx<Uint8List?> wallpaper = Rx(null);
  Rx<AppInfo?> loliSnatcher = Rx(null);
  RxBool writingAppList = false.obs;
  RxBool editingApps = false.obs;
  ConfigHandler configHandler = Get.find<ConfigHandler>();

  static const EventChannel eventChannel = EventChannel('com.noaisu.classicLauncher/appChange');
  StreamSubscription? appChangeSubscription;

  @override
  void onInit() {
    super.onInit();
    getAppPositions();
    getAppList();

    appChangeSubscription = eventChannel.receiveBroadcastStream().listen((appChange) async {
      Logger().log(location: "AppHandler.onInit", message: "App changed $appChange");
      if (appChange is! Map) {
        return;
      }

      String? packageName = appChange["packageName"];
      String? title = appChange["title"];
      String? status = appChange["status"];

      if (packageName == null || title == null) {
        return;
      }

      switch (status) {
        case "removed":
          installedApps.removeWhere((app) => app.packageName == packageName);
          appIcons.remove(packageName);
          return;
        case "added":
          if (title == packageName) {
            return getAppList();
          }
          installedApps.add(AppInfo(packageName: packageName, title: title));
      }

      Uint8List? appIcon = await getAppIcon(packageName);

      if (appIcon == null) {
        Logger().log(location: "AppHandler.onInit", message: "Failed to get app icon for $packageName");
        return;
      }

      appIcons[packageName] = appIcon;
    });
  }

  @override
  void onClose() {
    appChangeSubscription?.cancel();
    super.onClose();
  }

  Future<Uint8List> loadAssetBytes(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  Future<void> getAppPositions() async {
    try {
      String positionsString = await configHandler.loadConfig(configType: ConfigType.appPositions);

      if (positionsString.isEmpty) {
        return;
      }

      List<String> packagePositions = [...jsonDecode(positionsString)];

      appPositions.value = packagePositions;
    } catch (e, stackTrace) {
      Logger().log(location: "AppHandler.getAppPositions", message: "Failed to load app positions $e, $stackTrace", level: LogLevel.exception);
    }
  }

  Future<void> getAppList() async {
    if (writingAppList.value) {
      return;
    }

    try {
      Map<String, AppInfo> apps = {};
      AppInfo? loliSnatcherInfo;
      List<dynamic>? results = await methodChannel.invokeMethod<List<dynamic>>('getApps') ?? [];

      apps["classiclauncher.internal.settings"] = AppInfo(packageName: "classiclauncher.internal.settings", title: "Launcher Settings");

      for (dynamic appInfo in results) {
        if (appInfo is! Map) {
          continue;
        }

        String? packageName = appInfo["packageName"];
        String? title = appInfo["title"];

        if (packageName == null || title == null) {
          continue;
        }

        AppInfo currentApp = AppInfo(packageName: packageName, title: title);

        apps[packageName] = currentApp;

        if (packageName.contains("loliSnatcher")) {
          loliSnatcherInfo = currentApp;
        }
      }

      List<String> positions = appPositions.value;
      List<AppInfo> newAppList = [];

      for (String package in positions) {
        if (!apps.containsKey(package)) {
          continue;
        }

        newAppList.add(apps.remove(package)!);
      }

      newAppList.addAll(apps.values);

      if (!listEquals(newAppList, installedApps)) {
        loliSnatcher.value = loliSnatcherInfo;
        installedApps.value = newAppList;
      }
    } on PlatformException catch (e, stackTrace) {
      Logger().log(location: "AppHandler.getAppList", message: "Failed to get apps $e, $stackTrace", level: LogLevel.exception);
    }

    getAppIcons();
  }

  Future<void> getAppIcons() async {
    for (AppInfo app in installedApps) {
      if (appIcons.containsKey(app.packageName)) {
        continue;
      }

      Uint8List? appIcon = await getAppIcon(app.packageName);

      if (appIcon == null) {
        Logger().log(location: "AppHandler.getAppIcons", message: "Failed to get app icon for $app");
        continue;
      }

      appIcons[app.packageName] = appIcon;
    }
  }

  Future<void> launchApp(AppInfo app) async {
    if (app.packageName == "classiclauncher.internal.settings") {
      Get.to(SettingsScreen());
      return;
    }

    try {
      bool? result = await methodChannel.invokeMethod<bool>('launchApp', {"packageName": app.packageName});
    } on PlatformException catch (e, stackTrace) {
      Logger().log(location: "AppHandler.launchApp", message: "Failed to launch app $e, $stackTrace", level: LogLevel.exception);
    }
  }

  Future<void> launchMail() async {
    if (loliSnatcher.value != null) {
      return launchApp(loliSnatcher.value!);
    }

    AppInfo? bbHub = installedApps.firstWhereOrNull((app) => app.packageName == "com.blackberry.hub");

    if (bbHub != null) {
      return launchApp(bbHub);
    }

    try {
      bool? result = await methodChannel.invokeMethod<bool>('launchMail');
    } on PlatformException catch (e, stackTrace) {
      Logger().log(location: "AppHandler.launchMail", message: "Failed to launch SMS $e, $stackTrace", level: LogLevel.exception);
    }
  }

  Future<void> launchCamera() async {
    try {
      bool? result = await methodChannel.invokeMethod<bool>('launchCamera');
    } on PlatformException catch (e, stackTrace) {
      Logger().log(location: "AppHandler.launchCamera", message: "Failed to launch Camera $e, $stackTrace", level: LogLevel.exception);
    }
  }

  Future<void> moveApp({required int appPosition, required AppInfo app}) async {
    writingAppList.value = true;
    List<AppInfo> newAppList = [...installedApps];

    int currentIndex = installedApps.indexOf(app);

    newAppList.remove(app);
    newAppList.insert(appPosition, app);
    Logger().log(location: "AppHandler.moveApp", message: "Move ${app.packageName} from $currentIndex to $appPosition");

    if (newAppList == installedApps) {
      return;
    }

    installedApps.value = newAppList;

    List<String> packageNames = newAppList.map((AppInfo current) => current.packageName).toList();

    appPositions.value = packageNames;

    await configHandler.saveConfig(config: jsonEncode(packageNames), configType: ConfigType.appPositions);

    writingAppList.value = false;
  }

  Future<String?> writeFile(dynamic fileData, String fileName, String mediaType, String fileExt, String? extPathOverride) async {
    String? result;
    try {
      result = await methodChannel.invokeMethod('writeFile', {
        'fileData': fileData,
        'fileName': fileName,
        'mediaType': mediaType,
        'fileExt': fileExt,
        'extPathOverride': extPathOverride,
      });
    } catch (e, stackTrace) {
      Logger().log(location: "AppHandler.writeFile", message: "Failed to write file $e, $stackTrace", level: LogLevel.exception);
    }
    return result;
  }

  Future<String?> getSAFDirectoryAccess() async {
    String? result;
    try {
      result = await methodChannel.invokeMethod('getTempDirAccess');
      Logger().log(location: "AppHandler.getSAFDirectoryAccess", message: "Got saf path back $result");
    } catch (e, stackTrace) {
      Logger().log(location: "AppHandler.getSAFDirectoryAccess", message: "Failed to get saf path $e, $stackTrace", level: LogLevel.exception);
    }
    return result;
  }

  Future<Uint8List?> getSAFFile(String contentUri) async {
    Uint8List? result;
    try {
      result = await methodChannel.invokeMethod('getFileBytes', {'uri': contentUri});
      Logger().log(location: "AppHandler.getSAFFile", message: "Got file back");
    } catch (e, stackTrace) {
      Logger().log(location: "AppHandler.getSAFFile", message: "Failed to get saf file $e, $stackTrace", level: LogLevel.exception);
    }
    return result;
  }

  Future<Uint8List?> getAppIcon(String packageName) async {
    Uint8List? result;

    try {
      result = packageName == "classiclauncher.internal.settings"
          ? await loadAssetBytes(iconSettingsApp)
          : await methodChannel.invokeMethod('getAppIcon', {'packageName': packageName});
    } catch (e, stackTrace) {
      Logger().log(location: "AppHandler.getAppIcon", message: "Failed to find icon for $packageName $e, $stackTrace", level: LogLevel.exception);
    }

    return result;
  }

  Future<String> getSAFUri() async {
    String result = '';
    try {
      result = await methodChannel.invokeMethod('getFileUri');
      Logger().log(location: "AppHandler.getSAFUri", message: "Got saf uri back: $result");
    } catch (e, stackTrace) {
      Logger().log(location: "AppHandler.getSAFUri", message: "Failed to get saf uri $e, $stackTrace", level: LogLevel.exception);
    }
    return result;
  }

  Future<void> openWallpaperPicker() async {
    try {
      await methodChannel.invokeMethod('openWallpaperPicker');
    } catch (e, stackTrace) {
      Logger().log(location: "AppHandler.openWallpaperPicker", message: "Failed to set wallpaper $e, $stackTrace", level: LogLevel.exception);
    }
  }

  Future<void> exportAppOrder() async {
    try {
      final String? path = await getSAFDirectoryAccess();

      if (path == null) {
        return;
      }

      String fileName = 'appOrder_${DateTime.now()}';

      await writeFile(utf8.encode(jsonEncode(appPositions)), fileName, 'text/json', 'json', path);

      Get.snackbar("App order exported ( Ո‿Ո)", "saved to $fileName.json ...", backgroundColor: Colors.black54, colorText: Colors.white);
    } catch (e, stackTrace) {
      Logger().log(location: "AppHandler.exportAppOrder", message: "Failed to export app order $e, $stackTrace", level: LogLevel.exception);
      Get.snackbar("Failed to export app order ૮(˶ㅠ︿ㅠ)ა", "$e", backgroundColor: Colors.black54, colorText: Colors.white);
    }
  }

  Future<void> uninstallApp(AppInfo app) async {
    try {
      await methodChannel.invokeMethod('uninstallApp', {"packageName": app.packageName});
    } catch (e, stackTrace) {
      Logger().log(location: "AppHandler.uninstallApp", message: "Failed to uninstall $app $e, $stackTrace", level: LogLevel.exception);
    }
  }

  Future<void> importAppOrder() async {
    try {
      final String path = await getSAFUri();
      Uint8List? bytes = await getSAFFile(path);
      if (bytes == null) {
        throw Exception("null bytes returning");
      }
      final List<String> newPositions = [...jsonDecode(utf8.decode(bytes))];

      appPositions.value = newPositions;
      Get.snackbar("App order imported ( Ո‿Ո)", "app order has been imported", backgroundColor: Colors.black54, colorText: Colors.white);
      getAppList();
    } catch (e, stackTrace) {
      Logger().log(location: "AppHandler.importAppOrder", message: "Failed to import app order $e, $stackTrace", level: LogLevel.exception);
      Get.snackbar("Failed to import app order ૮(˶ㅠ︿ㅠ)ა", "$e", backgroundColor: Colors.black54, colorText: Colors.white);
    }
  }
}
