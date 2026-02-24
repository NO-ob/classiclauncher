import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class AppInfo extends Equatable {
  final String packageName;
  final String title;

  const AppInfo({required this.packageName, required this.title});

  @override
  List<Object?> get props => [packageName, title];

  @override
  bool? get stringify => true;
}
