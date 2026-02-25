import 'package:flutter/material.dart';

extension TabControllerExtensions on TabController {
  void jumpTo(int index) {
    return animateTo(index, duration: Duration(seconds: 0));
  }
}
