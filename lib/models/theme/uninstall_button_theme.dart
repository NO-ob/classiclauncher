import 'dart:ui';

import 'package:classiclauncher/models/theme/serializable_util.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'uninstall_button_theme.g.dart';

@CopyWith()
@JsonSerializable(createJsonSchema: true)
class UninstallButtonTheme extends Equatable {
  @ColourConverter()
  final Color uninstallButtonColour;
  @ColourConverter()
  final Color uninstallButtonBorderColour;
  @ColourConverter()
  final Color uninstallButtonIconColour;
  final double uninstallButtonSize;

  const UninstallButtonTheme({
    this.uninstallButtonColour = Colors.black54,
    this.uninstallButtonBorderColour = Colors.white54,
    this.uninstallButtonIconColour = Colors.white,
    this.uninstallButtonSize = 32,
  });

  @override
  List<Object?> get props => [uninstallButtonColour, uninstallButtonBorderColour, uninstallButtonIconColour, uninstallButtonSize];

  /// Connect the generated [_$UninstallButtonThemeFromJson] function to the `fromJson`
  /// factory.
  factory UninstallButtonTheme.fromJson(Map<String, dynamic> json) => _$UninstallButtonThemeFromJson(json);

  /// Connect the generated [_$UninstallButtonThemeToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UninstallButtonThemeToJson(this);

  /// The JSON Schema for this class.
  static const jsonSchema = _$UninstallButtonThemeJsonSchema;
}
