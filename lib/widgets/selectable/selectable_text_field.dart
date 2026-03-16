import 'dart:async';
import 'dart:math' as math;

import 'package:classiclauncher/handlers/theme_handler.dart';
import 'package:classiclauncher/models/enums.dart';
import 'package:classiclauncher/models/key_press.dart';
import 'package:classiclauncher/models/theme/selector_theme.dart';
import 'package:classiclauncher/screens/selectable_container.dart';
import 'package:classiclauncher/widgets/selectable/selectable.dart';
import 'package:classiclauncher/widgets/selectable/selectable_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectableTextController extends ChangeNotifier {
  final List<String> _chars = [];
  int cursorIndex = 0;

  List<String> get chars => List.unmodifiable(_chars);

  void insert(String char) {
    _chars.insert(cursorIndex, char);
    cursorIndex++;
    notifyListeners();
  }

  void backSpace() {
    if (cursorIndex == 0 || _chars.isEmpty) {
      return;
    }

    _chars.removeAt(cursorIndex - 1);
    cursorIndex--;
    notifyListeners();
  }

  void moveCursor(Direction direction) {
    if (_chars.isEmpty || direction == Direction.up || direction == Direction.down) {
      return;
    }
    if (direction == Direction.left && cursorIndex > 0) {
      cursorIndex--;
    }

    if (direction == Direction.right && cursorIndex < chars.length) {
      cursorIndex++;
    }

    notifyListeners();
  }

  void setCursor(int index) {
    cursorIndex = index;
    if (index > _chars.length) {
      cursorIndex = _chars.length + 1;
    }

    if (index < 0) {
      cursorIndex = 0;
    }

    notifyListeners();
  }

  void clear() {
    if (_chars.isEmpty) {
      return;
    }
    _chars.clear();
    cursorIndex = 0;
    notifyListeners();
  }

  String get text => _chars.join();
}

class SelectableTextField extends StatefulWidget {
  final String zoneKey;
  final int? zoneIndex;
  final SelectableTextController textController;
  const SelectableTextField({super.key, required this.zoneKey, this.zoneIndex, required this.textController});

  @override
  State<StatefulWidget> createState() => _SelectableTextFieldState();
}

class _SelectableTextFieldState extends State<SelectableTextField> implements SelectableZone {
  SelectableController? controller;
  ThemeHandler themeHandler = Get.find<ThemeHandler>();
  bool selected = false;

  @override
  late String zoneKey;
  @override
  int currentIndex = 0;

  @override
  void initState() {
    zoneKey = widget.zoneKey;
    controller?.inputNotifier.addListener(inputListener);

    super.initState();
  }

  void inputListener() {
    KeyPress? keyPress = controller?.inputNotifier.value;

    if (keyPress == null || keyPress.state == KeyState.keyUp) {
      return;
    }

    Input? input = keyPress.input;

    if (input == Input.backSpace) {
      widget.textController.backSpace();
      return;
    }

    if (keyPress.char == null || input != null || keyPress.direction != null) {
      return;
    }

    widget.textController.insert(keyPress.char!);
  }

  @override
  int handleMove(Direction direction, MoveType moveType) {
    if ((direction == Direction.up || direction == Direction.down) && moveType == MoveType.hard) {
      return -1;
    }

    widget.textController.moveCursor(direction);

    return currentIndex;
  }

  @override
  void dispose() {
    controller?.unregisterZone(this);
    controller?.inputNotifier.removeListener(inputListener);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController = Selectable.of(context).controller;

    if (controller != newController) {
      controller?.unregisterZone(this);
      controller = newController;
      controller?.inputNotifier.addListener(inputListener);
      controller!.registerZone(this, currentIndex, preferredZoneIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      double selectorPadding = (themeHandler.theme.value.navBarTheme.navBarHeight - themeHandler.theme.value.appGridSearchBarTheme.textFieldHeight) / 2;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: themeHandler.theme.value.appGridSearchBarTheme.textFieldHeight + 20,
            child: SelectableContainer(
              selectableKey: "${widget.zoneKey}_0",
              selectorTheme: themeHandler.theme.value.appGridSearchBarTheme.selectorTheme,
              selectedCallback: (newSelected) {
                setState(() {
                  selected = newSelected;
                });
              },
              onTap: () {
                //  controller.zones.
              },
              child: SelectableTextFieldRow(textController: widget.textController, selected: selected),
            ),
          ),
        ],
      );
    });
  }

  @override
  late int? preferredZoneIndex = widget.zoneIndex;
}

class SelectableTextFieldRow extends StatefulWidget {
  final SelectableTextController textController;
  final bool selected;
  const SelectableTextFieldRow({super.key, required this.textController, required this.selected});
  @override
  State<SelectableTextFieldRow> createState() => _SelectableTextFieldRowState();
}

class _SelectableTextFieldRowState extends State<SelectableTextFieldRow> {
  List<String> text = [];
  int cursorIndex = 0;
  ScrollController scrollController = ScrollController();
  List<GlobalKey> charKeys = [];
  ThemeHandler themeHandler = Get.find<ThemeHandler>();

  @override
  void initState() {
    text = widget.textController.chars;
    cursorIndex = widget.textController.cursorIndex;
    rebuildKeys();
    widget.textController.addListener(updateText);
    super.initState();
  }

  void rebuildKeys() {
    charKeys = List.generate(text.length + 1, (_) => GlobalKey());
  }

  void updateText() {
    if (!mounted) return;
    setState(() {
      text = widget.textController.chars;
      cursorIndex = widget.textController.cursorIndex;
      rebuildKeys();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToCursor());
  }

  void scrollToCursor() {
    if (!scrollController.hasClients) return;

    final index = cursorIndex.clamp(0, charKeys.length - 1);
    final key = charKeys[index];
    final context = key.currentContext;
    if (context == null) return;

    final RenderBox charBox = context.findRenderObject() as RenderBox;
    final RenderBox scrollBox = scrollController.position.context.storageContext.findRenderObject() as RenderBox;

    final charOffset = charBox.localToGlobal(Offset.zero, ancestor: scrollBox);
    final charLeft = charOffset.dx + scrollController.offset;
    final charRight = charLeft + charBox.size.width;

    final viewportWidth = scrollController.position.viewportDimension;
    final currentOffset = scrollController.offset;

    double? targetOffset;

    if (charLeft < currentOffset) {
      targetOffset = charLeft - 8;
    } else if (charRight > currentOffset + viewportWidth) {
      targetOffset = charRight - viewportWidth + 8;
    }

    if (targetOffset != null) {
      scrollController.animateTo(
        targetOffset.clamp(0, scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    widget.textController.removeListener(updateText);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          return Padding(
            padding: themeHandler.theme.value.appGridSearchBarTheme.textFieldPadding,
            child: Container(
              decoration: BoxDecoration(color: themeHandler.theme.value.appGridSearchBarTheme.backgroundColour),
              height: themeHandler.theme.value.appGridSearchBarTheme.textFieldHeight,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.only(right: themeHandler.theme.value.appGridSearchBarTheme.totalIconWidth),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: scrollController,
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth:
                              constraints.maxWidth -
                              themeHandler.theme.value.appGridSearchBarTheme.totalIconWidth -
                              themeHandler.theme.value.appGridSearchBarTheme.textFieldPadding.left -
                              themeHandler.theme.value.appGridSearchBarTheme.textFieldPadding.right,
                        ),
                        child: Padding(
                          padding: themeHandler.theme.value.appGridSearchBarTheme.textPadding,
                          child: Row(
                            children: [
                              for (int i = 0; i <= text.length; i++)
                                Row(
                                  key: charKeys[i],
                                  children: [
                                    if (i == cursorIndex)
                                      BlinkingCursor(
                                        width: themeHandler.theme.value.appGridSearchBarTheme.cursorWidth,
                                        height: themeHandler.theme.value.appGridSearchBarTheme.cursorHeight,
                                        color: themeHandler.theme.value.appGridSearchBarTheme.cursorColour,
                                      ),
                                    if (i == text.length)
                                      // tapapasble box after last char to set cursor to end
                                      GestureDetector(
                                        onTap: () {
                                          widget.textController.setCursor(i);
                                        },
                                        child: Container(width: 15, color: Colors.transparent),
                                      ),
                                    if (i < text.length)
                                      Padding(
                                        padding: themeHandler.theme.value.appGridSearchBarTheme.letterPadding,
                                        child: GestureDetector(
                                          onTap: () {
                                            widget.textController.setCursor(i);
                                          },
                                          child: Text(text[i], textAlign: TextAlign.left, style: themeHandler.theme.value.appGridSearchBarTheme.textStyle),
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => widget.textController.clear(),
                      child: Padding(
                        padding: themeHandler.theme.value.appGridSearchBarTheme.iconPadding,
                        child: Transform.rotate(
                          angle: -math.pi / 4,
                          child: Icon(
                            Icons.add_circle_outline,
                            size: themeHandler.theme.value.appGridSearchBarTheme.iconSize,
                            color: themeHandler.theme.value.appGridSearchBarTheme.iconColour,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class BlinkingCursor extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final Duration blinkDuration;

  const BlinkingCursor({super.key, required this.width, required this.height, required this.color, this.blinkDuration = const Duration(milliseconds: 700)});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor> {
  bool visible = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(widget.blinkDuration, (_) {
      if (!mounted) return;
      setState(() {
        visible = !visible;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 50),
      child: Container(width: widget.width, height: widget.height, color: widget.color),
    );
  }
}
