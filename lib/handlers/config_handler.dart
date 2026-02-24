import 'dart:async';
import 'dart:io';
import 'package:classiclauncher/utils/logger.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

enum ConfigType { theme, appPositions }

class WriteQueue<T> {
  Future<void> last = Future.value();
  Future<T> queueAndWait(Future<T> Function() action) {
    Completer<T> completer = Completer<T>();
    last = last.then((_) => action()).then(completer.complete, onError: completer.completeError);
    return completer.future;
  }
}

class ConfigHandler extends GetxController {
  final Map<ConfigType, WriteQueue> writeQueues = {};

  Future<void> saveConfig({required String config, required ConfigType configType}) async {
    WriteQueue queue = writeQueues.putIfAbsent(configType, () => WriteQueue());
    return queue.queueAndWait(() async {
      await writeFile(config: config, configType: configType);
    });
  }

  Future<void> deleteConfig({required ConfigType configType}) async {
    WriteQueue queue = writeQueues.putIfAbsent(configType, () => WriteQueue());
    return queue.queueAndWait(() async {
      await deleteFile(configType: configType);
    });
  }

  Future<void> deleteFile({required ConfigType configType}) async {
    final Directory appDocumentsDir = await getApplicationSupportDirectory();
    File file = File('${appDocumentsDir.path}/${configType.name}.json');
    try {
      await file.delete();
    } catch (e, stackTrace) {
      Logger().log(location: "ConfigHandler.deleteFile", message: "Failed to delete file $configType, $e, $stackTrace", level: LogLevel.exception);
    }
  }

  Future<void> writeFile({required String config, required ConfigType configType}) async {
    final Directory appDocumentsDir = await getApplicationSupportDirectory();
    File file = File('${appDocumentsDir.path}/${configType.name}.json');
    try {
      await file.writeAsString(config);
    } catch (e, stackTrace) {
      Logger().log(location: "ConfigHandler.writeFile", message: "Failed to store file $configType, $e, $stackTrace", level: LogLevel.exception);
    }
  }

  Future<String> loadConfig({required ConfigType configType}) async {
    final Directory appDocumentsDir = await getApplicationSupportDirectory();
    File file = File('${appDocumentsDir.path}/${configType.name}.json');
    Logger().log(location: "ConfigHandler.loadConfig", message: "Looking for ${file.path}");
    Logger().log(location: "ConfigHandler.loadConfig", message: "${appDocumentsDir.listSync()}");
    try {
      bool exists = await file.exists();
      if (exists) {
        return file.readAsString();
      }
    } catch (e, stackTrace) {
      Logger().log(location: "ConfigHandler.loadConfig", message: "Failed to load file $configType, $e, $stackTrace", level: LogLevel.exception);
    }
    return "";
  }
}
