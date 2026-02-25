import 'package:classiclauncher/models/enums.dart';
import 'package:classiclauncher/models/key_press.dart';
import 'package:classiclauncher/models/theme/selector_theme.dart';
import 'package:classiclauncher/screens/selectable_container.dart';
import 'package:classiclauncher/widgets/selectable/selectable.dart';
import 'package:classiclauncher/widgets/selectable/selectable_controller.dart';
import 'package:flutter/material.dart';

class SelectableList extends StatefulWidget {
  final Axis axis;
  final String zoneKey;
  final List<Widget> children;
  final int? zoneIndex;
  final void Function()? onStart;
  final void Function()? onEnd;

  const SelectableList._internal({super.key, required this.axis, required this.zoneKey, required this.children, this.zoneIndex, this.onStart, this.onEnd});

  factory SelectableList({
    Key? key,
    required Axis axis,
    required String zoneKey,
    required List<Widget> children,
    int? zoneIndex,
    required SelectorTheme selectorTheme,
    void Function()? onStart,
    void Function()? onEnd,
  }) {
    List<Widget> selectableChildren = List<Widget>.generate(
      children.length,
      (i) => SelectableContainer(selectableKey: '${zoneKey}_$i', selectorTheme: selectorTheme, child: children[i]),
    );

    return SelectableList._internal(key: key, axis: axis, zoneKey: zoneKey, zoneIndex: zoneIndex, onEnd: onEnd, onStart: onStart, children: selectableChildren);
  }

  factory SelectableList.builder({
    Key? key,
    required Axis axis,
    required String zoneKey,
    required int childCount,
    required Widget Function(int index, String key) childBuilder,
    int? zoneIndex,
    void Function()? onStart,
    void Function()? onEnd,
  }) {
    final children = List<Widget>.generate(childCount, (i) => childBuilder(i, zoneKey));

    return SelectableList._internal(key: key, axis: axis, zoneKey: zoneKey, onEnd: onEnd, onStart: onStart, children: children);
  }

  @override
  State<SelectableList> createState() => _SelectableListState();
}

class _SelectableListState extends State<SelectableList> implements SelectableZone {
  SelectableController? controller;
  late Direction nextDirection;
  late Direction prevDirection;

  @override
  late String zoneKey;
  @override
  int currentIndex = 0;

  @override
  void initState() {
    zoneKey = widget.zoneKey;
    prevDirection = widget.axis == Axis.horizontal ? Direction.left : Direction.up;
    nextDirection = widget.axis == Axis.horizontal ? Direction.right : Direction.down;

    super.initState();
  }

  @override
  int handleMove(Direction direction, MoveType moveType) {
    if (direction != nextDirection && direction != prevDirection) {
      return -1;
    }

    if (direction == prevDirection && currentIndex == 0) {
      if (moveType == MoveType.hard) {
        widget.onStart?.call();
      }
      return -1;
    }

    if (direction == nextDirection && currentIndex >= widget.children.length - 1) {
      if (moveType == MoveType.hard) {
        widget.onEnd?.call();
      }
      return -1;
    }

    currentIndex += direction == nextDirection ? 1 : -1;

    return currentIndex;
  }

  @override
  void dispose() {
    controller?.unregisterZone(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController = Selectable.of(context).controller;

    if (controller != newController) {
      controller?.unregisterZone(this);
      controller = newController;
      controller!.registerZone(this, currentIndex, preferredZoneIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.axis == Axis.vertical ? Column(children: widget.children) : Row(children: widget.children);
  }

  @override
  late int? preferredZoneIndex = widget.zoneIndex;
}
