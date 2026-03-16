import 'dart:ui';

import 'package:classiclauncher/models/theme/app_grid_theme.dart';
import 'package:classiclauncher/models/theme/nav_bar_theme.dart';
import 'package:classiclauncher/models/theme/page_indicator_theme.dart';
import 'package:classiclauncher/models/theme/settings_theme.dart';
import 'package:classiclauncher/models/theme/text_field_theme.dart';
import 'package:classiclauncher/models/theme/uninstall_button_theme.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'launcher_theme.g.dart';

@CopyWith()
@JsonSerializable(createJsonSchema: true)
class LauncherTheme extends Equatable {
  final Duration longPressActionDuration;
  final AppGridTheme appGridTheme;
  final PageIndicatorTheme pageIndicatorTheme;
  final SettingsTheme settingsTheme;
  final NavBarTheme navBarTheme;
  final UninstallButtonTheme uninstallButtonTheme;
  final TextFieldTheme appGridSearchBarTheme;
  const LauncherTheme({
    this.longPressActionDuration = const Duration(milliseconds: 800),
    this.appGridTheme = const AppGridTheme(),
    this.pageIndicatorTheme = const PageIndicatorTheme(),
    this.settingsTheme = const SettingsTheme(),
    this.navBarTheme = const NavBarTheme(),
    this.uninstallButtonTheme = const UninstallButtonTheme(),
    this.appGridSearchBarTheme = const TextFieldTheme(),
  });

  /// Connect the generated [_$LauncherThemeFromJson] function to the `fromJson`
  /// factory.
  factory LauncherTheme.fromJson(Map<String, dynamic> json) => _$LauncherThemeFromJson(json);

  /// Connect the generated [_$LauncherThemeToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$LauncherThemeToJson(this);

  /// The JSON Schema for this class.
  static const jsonSchema = _$LauncherThemeJsonSchema;

  @override
  List<Object?> get props => [longPressActionDuration, appGridTheme, pageIndicatorTheme, settingsTheme];
}
