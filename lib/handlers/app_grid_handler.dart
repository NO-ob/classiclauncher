import 'dart:async';

import 'package:classiclauncher/models/app_info.dart';
import 'package:classiclauncher/models/key_press.dart';
import 'package:classiclauncher/selection/key_input_handler.dart';
import 'package:classiclauncher/utils/custom_page_controller.dart';
import 'package:classiclauncher/utils/logger.dart';
import 'package:classiclauncher/widgets/selectable/selectable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppGridHandler extends GetxController {
  final RxBool editing = RxBool(false);
  final Rx<AppInfo?> moving = Rx(null);
  final RxBool dragging = RxBool(false);
  final RxInt selectedGridIndex = 0.obs;
  int? appMoveCol;
  int? appMoveRow;
  Rx<Timer?> pageChangeEdgeTimer = Rx(null);
  late StreamSubscription inputSub;
  Rx<double?> fingerX = Rx(null);
  Rx<double?> fingerY = Rx(null);
  late AnimationController editingAnimationController;
  late Animation<double> editingScaleAnimation;
  AnimationController? swipableFadeController;
  SelectableTextController textController = SelectableTextController();

  Rx<CustomPageController?> customPageController = Rx(null);

  @override
  void onInit() {
    super.onInit();

    ever(editing, (_) {
      if (editing.value) {
        Logger().log(location: "AppGridHandler.onInit", message: "editng started", level: LogLevel.debug);

        return;
      }
      Logger().log(location: "AppGridHandler.onInit", message: "editng ended", level: LogLevel.debug);
    });

    inputSub = Get.find<KeyInputHandler>().keyStream.listen((keyPress) {
      if (keyPress.input == Input.back && editing.value) {
        stopEdit();
      }
    });
  }

  void initAnimation(TickerProvider vsync) {
    editingAnimationController = AnimationController(vsync: vsync, duration: Duration(milliseconds: 800));
    editingScaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(CurvedAnimation(parent: editingAnimationController, curve: Curves.easeInOut));
    ever(editing, (bool isEditing) {
      if (isEditing) {
        editingAnimationController.repeat(reverse: true);
      } else {
        editingAnimationController.stop();
        editingAnimationController.reset();
      }
    });
  }

  void clearMove() {
    moving.value = null;
    fingerX.value = null;
    fingerY.value = null;
  }

  void stopEdit() {
    editing.value = false;
  }

  void clearTimer() {
    pageChangeEdgeTimer.value?.cancel();
    pageChangeEdgeTimer.value = null;
  }
}
