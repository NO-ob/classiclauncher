import 'dart:async';

import 'package:classiclauncher/handlers/theme_handler.dart';
import 'package:classiclauncher/models/enums.dart';
import 'package:classiclauncher/selection/key_input_handler.dart';
import 'package:classiclauncher/utils/launcher_utils.dart';
import 'package:classiclauncher/utils/logger.dart';
import 'package:classiclauncher/widgets/selectable/selectable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/key_press.dart';

class SelectableController {
  final List<SelectableZone> zones = [];
  int zoneIndex = 0;
  late StreamSubscription inputSub;
  ValueNotifier<String?> selectedItemNotifier = ValueNotifier(null);
  ValueNotifier<KeyPress?> inputNotifier = ValueNotifier(null);
  ValueNotifier<KeyPress?> longPressNotifier = ValueNotifier(null);
  SelectableZone? get currentZone => zones.isNotEmpty ? zones[zoneIndex] : null;
  ThemeHandler themeHandler = Get.find<ThemeHandler>();

  Duration frameTime = Duration(milliseconds: 45);
  DateTime? lastMove;
  List<KeyPress> inputsSinceLastFrame = [];
  bool animatingPage = false;
  RxMap<int, Timer> heldInputs = RxMap();
  List<int> cancelRelease = [];
  String route;
  void Function(KeyPress keyPress)? textInputCallback;

  SelectableController({required this.route, this.textInputCallback}) {
    inputSub = Get.find<KeyInputHandler>().keyStream.listen((keyPress) {
      if (Get.currentRoute != route) {
        return;
      }

      if (route == "/SettingsScreen" && keyPress.input == Input.back && keyPress.state == KeyState.keyUp) {
        Get.back();
        return;
      }

      Direction? direction = keyPress.direction;

      if (selectedItemNotifier.value == null) {
        setSelected(0);
      }

      if (direction != null) {
        handleDirection(keyPress, direction);
        return;
      }

      if (keyPress.state == KeyState.keyUp && heldInputs[keyPress.keyCode] != null) {
        heldInputs[keyPress.keyCode]?.cancel();
        heldInputs.remove(keyPress.keyCode);
        Logger().log(location: "SelectableController", message: "long press cancelled $keyPress");
      }

      if (keyPress.state == KeyState.keyDown && !heldInputs.containsKey(keyPress.keyCode)) {
        Logger().log(location: "SelectableController", message: "long press queued $keyPress");
        queueLongPress(keyPress);
      }

      if (keyPress.state == KeyState.keyUp && cancelRelease.contains(keyPress.keyCode)) {
        cancelRelease.remove(keyPress.keyCode);
        Logger().log(location: "SelectableController", message: "Cancelling release for $keyPress");
        return;
      }

      // text input callback
      // fucntion called, setstate in aprents, hide navbar, show textfield

      // Call fucnrtion + notify

      inputNotifier.value = keyPress;

      Logger().log(location: "SelectableController", message: "input announced $keyPress");

      if (keyPress.input != Input.select) {
        textInputCallback?.call(keyPress);
      }
      return;
    });
  }

  void queueLongPress(KeyPress keyPress) {
    heldInputs.putIfAbsent(
      keyPress.keyCode,
      () => Timer(themeHandler.theme.value.longPressActionDuration, () {
        Logger().log(location: "SelectableController.queueLongPress", message: "long press detected $keyPress");
        cancelRelease.add(keyPress.keyCode);
        heldInputs[keyPress.keyCode]!.cancel();
        heldInputs.remove(keyPress.keyCode);
        longPressNotifier.value = keyPress;
        inputNotifier.value = null;
      }),
    );
  }

  void handleDirection(KeyPress keyPress, Direction direction) {
    DateTime now = DateTime.now();

    if (lastMove != null && now.difference(lastMove!) < frameTime) {
      inputsSinceLastFrame.add(keyPress);
      return;
    }

    Logger().log(
      location: "SelectableController.handleDirection",
      message: "Doing move $direction, ${inputsSinceLastFrame.isNotEmpty ? MoveType.hard : MoveType.soft}",
    );

    handleMove(direction, inputsSinceLastFrame.isNotEmpty ? MoveType.hard : MoveType.soft);

    lastMove = now;
    inputsSinceLastFrame = [];
  }

  Input? getInput(KeyPress keyPress) {
    switch (keyPress.keyCode) {
      case 66:
        return Input.select;
    }
    return null;
  }

  void registerZone(SelectableZone zone, int zoneChildIndex, int? zoneIndex) {
    if (zoneIndex == null) {
      zones.add(zone);
    } else {
      zones.insert(zoneIndex, zone);
    }
  }

  void setSelected(int index) {
    String newKey = '${currentZone?.zoneKey}_$index';

    if (newKey == selectedItemNotifier.value) {
      return;
    }
    selectedItemNotifier.value = '${currentZone?.zoneKey}_$index';
    Logger().log(location: "SelectableController.setSelected", message: "${selectedItemNotifier.value}");
    LauncherUtils.doFeedback();
  }

  void unregisterZone(SelectableZone zone) {
    zones.remove(zone);
    zoneIndex = 0;
  }

  void handleMove(Direction direction, MoveType moveType) {
    SelectableZone? current = currentZone;

    if (currentZone == null) {
      return;
    }

    int index = current!.handleMove(direction, moveType);

    if (index != -1) {
      setSelected(index);
      return;
    }

    moveBetweenZones(direction, moveType);
  }

  void moveBetweenZones(Direction direction, MoveType moveType) {
    if (moveType == MoveType.soft) {
      return;
    }

    if (direction == Direction.down && zoneIndex < zones.length - 1) {
      zoneIndex++;
    }

    if (direction == Direction.up && zoneIndex > 0) {
      zoneIndex--;
    }

    setSelected(currentZone!.currentIndex);
  }

  void setSelectedFromKeyString(String key) {
    int itemIndex = int.parse(key.split("_")[1]);

    String zoneString = key.split("_")[0];

    int zoneIndex = zones.indexWhere((zone) => zone.runtimeType.toString() == zoneString);

    if (zoneIndex == -1) {
      return;
    }

    this.zoneIndex = zoneIndex;

    setSelected(itemIndex);
  }
}
