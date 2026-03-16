enum KeyState { keyDown, keyUp }

enum Input { select, back, backSpace }

enum Direction { up, down, left, right }

class KeyPress {
  final int keyCode;
  final String? char;
  final KeyState state;

  KeyPress({required this.keyCode, required this.char, required this.state});

  factory KeyPress.fromMap(Map<dynamic, dynamic> map) {
    return KeyPress(keyCode: map['keyCode'], char: map['char'], state: map['state'] == 'keydown' ? KeyState.keyDown : KeyState.keyUp);
  }

  bool get hasChar => char != null && char!.isNotEmpty;

  bool get isTrackPadDirection => keyCode == 19 || keyCode == 20 || keyCode == 21 || keyCode == 22;

  Input? get input {
    switch (keyCode) {
      case 66:
        return Input.select;
      case 67:
        return Input.backSpace;
      case 4:
        return Input.back;
    }
    return null;
  }

  Direction? get direction {
    switch (keyCode) {
      case 19:
        return Direction.up;

      case 20:
        return Direction.down;

      case 21:
        return Direction.left;

      case 22:
        return Direction.right;
    }
    return null;
  }

  @override
  String toString() => '$runtimeType(keyCode: $keyCode, state: $state, char: $char,)';
}
