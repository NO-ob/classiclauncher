import 'dart:async';

import 'package:classiclauncher/handlers/theme_handler.dart';
import 'package:classiclauncher/models/key_press.dart';
import 'package:classiclauncher/models/theme/selector_theme.dart';
import 'package:classiclauncher/utils/logger.dart';
import 'package:classiclauncher/widgets/selectable/selectable.dart';
import 'package:classiclauncher/widgets/selectable/selectable_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectableContainer extends StatefulWidget {
  final String selectableKey;
  final Widget child;
  final bool Function()? canLongPress;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final void Function(TapDownDetails)? onTapDown;
  final void Function(TapUpDetails)? onTapUp;
  final HitTestBehavior? behavior;
  final Function(DragStartDetails)? onHorizontalDragStart;
  final Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final Function(DragEndDetails)? onHorizontalDragEnd;
  final Function(bool selected)? selectedCallback;
  final SelectorTheme selectorTheme;

  const SelectableContainer({
    super.key,
    required this.selectableKey,
    required this.child,
    this.canLongPress,
    this.onTap,
    this.onLongPress,
    this.onTapUp,
    this.onTapDown,
    this.behavior,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.selectedCallback,
    required this.selectorTheme,
  });

  @override
  State<SelectableContainer> createState() => _SelectableContainerState();
}

class _SelectableContainerState extends State<SelectableContainer> {
  final ThemeHandler themeHandler = Get.find<ThemeHandler>();
  bool selected = false;
  bool buttonPressed = false;
  SelectableController? controller;

  void onSelected() {
    if (!mounted) {
      return;
    }
    String? newKey = controller?.selectedItemNotifier.value;
    bool newSelected = newKey == widget.selectableKey;

    if (newSelected != selected) {
      if (newSelected) {
        Logger().log(location: "SelectableContainer.onSelected", message: "${widget.selectableKey} selected");
      } else {
        Logger().log(location: "SelectableContainer.onSelected", message: "${widget.selectableKey} deselected");
      }
      widget.selectedCallback?.call(newSelected);
      setState(() {
        selected = newSelected;
      });
    }
  }

  void onLongPress() {
    bool canLongPress = widget.canLongPress?.call() ?? true;

    if (!canLongPress) {
      Logger().log(location: "SelectableContainer.onLongPress", message: "long press test failed returning");
      return;
    }
    if (!mounted || !selected) {
      return;
    }

    KeyPress? keyPress = controller!.longPressNotifier.value;
    if (keyPress?.input != Input.select) {
      return;
    }

    if (widget.onLongPress == null) {
      return;
    }

    widget.onLongPress?.call();
    Logger().log(location: "SelectableContainer.onLongPress", message: "${widget.selectableKey} long pressed/released");
    setState(() {
      buttonPressed = false;
    });
  }

  void onInput() {
    if (!mounted || !selected) {
      return;
    }

    KeyPress? keyPress = controller!.inputNotifier.value;

    if (keyPress?.state == KeyState.keyDown && keyPress?.input == Input.select && buttonPressed) {
      Logger().log(location: "SelectableContainer.onInput", message: "${widget.selectableKey} returning because pressed and down");
      return;
    }

    if (keyPress?.state == KeyState.keyDown && keyPress?.input == Input.select) {
      Logger().log(location: "SelectableContainer.onInput", message: "${widget.selectableKey} pressed");
      setState(() {
        buttonPressed = true;
      });
      return;
    }

    if (keyPress == null || keyPress.input != Input.select) {
      return;
    }

    if (keyPress.state == KeyState.keyUp) {
      widget.onTap?.call();
    }

    setState(() {
      buttonPressed = false;
      Logger().log(location: "SelectableContainer.onInput", message: "${widget.selectableKey} released");
    });
  }

  void initListener() {
    selected = controller?.selectedItemNotifier.value == widget.selectableKey;
    controller?.selectedItemNotifier.addListener(onSelected);
    controller?.longPressNotifier.addListener(onLongPress);
    controller?.inputNotifier.addListener(onInput);
  }

  @override
  void initState() {
    selected = controller?.selectedItemNotifier.value == widget.selectableKey;
    Logger().log(location: "SelectableContainer.initState", message: "${widget.selectableKey} init");
    super.initState();
  }

  Color getHoldColour(Color colour) {
    Color whiter = Color.lerp(colour, Colors.white, 0.1)!;
    return whiter.withValues(alpha: (colour.a * 0.8));
  }

  @override
  void dispose() {
    controller?.selectedItemNotifier.removeListener(onSelected);
    controller?.longPressNotifier.removeListener(onLongPress);
    controller?.inputNotifier.removeListener(onInput);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController = Selectable.of(context).controller;

    if (controller == newController) return;

    if (controller != null) {
      controller!.selectedItemNotifier.removeListener(onSelected);
      controller!.inputNotifier.removeListener(onInput);
      controller!.longPressNotifier.removeListener(onLongPress);
    }

    controller = newController;
    initListener();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: widget.onTapDown,
      onHorizontalDragStart: widget.onHorizontalDragStart,
      onTapUp: widget.onTapUp,
      behavior: widget.behavior,
      onHorizontalDragUpdate: widget.onHorizontalDragUpdate,
      onHorizontalDragEnd: widget.onHorizontalDragEnd,
      child: Container(
        decoration: selected
            ? buttonPressed
                  ? widget.selectorTheme.decoration.copyWith(color: getHoldColour(widget.selectorTheme.decoration.color!))
                  : widget.selectorTheme.decoration
            : null,
        child: Stack(
          children: [
            Align(alignment: Alignment.center, child: widget.child),

            // Text(widget.selectorKey.split("_")[1], style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
