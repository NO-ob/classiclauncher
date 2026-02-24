import 'package:classiclauncher/models/theme/selector_theme.dart';
import 'package:classiclauncher/models/theme/serializable_util.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_grid_theme.g.dart';

@CopyWith()
@JsonSerializable(createJsonSchema: true)
class AppGridTheme extends Equatable {
  final int columns;
  final int rows;
  final double iconSize;
  final double appCardFontSize;
  @ColourConverter()
  final Color appCardTextOutlineColour;
  @EdgeInsetsConverter()
  final EdgeInsets appGridOutterPadding;
  @EdgeInsetsConverter()
  final EdgeInsets appCardIconPadding;
  final double columnSpacing;
  final double rowSpacing;
  final double appGridEdgeHoverZoneWidth;
  final Duration appGridEdgeHoverDuration;
  @ColourConverter()
  final Color? appCardBackgroundColour;
  final double cornerRadius;
  final SelectorTheme selectorTheme;
  @GradientConverter()
  final Gradient? appCardGradient;
  @ColourConverter()
  final Color? appCardTextColour;

  const AppGridTheme({
    this.appCardFontSize = 18,
    this.appCardTextColour = const Color(0xFFe6e6e6),
    this.appCardTextOutlineColour = Colors.black,
    this.columns = 5,
    this.rows = 3,
    this.iconSize = 68,
    this.rowSpacing = 10,
    this.columnSpacing = 10,
    this.appGridEdgeHoverZoneWidth = 70,
    this.appGridEdgeHoverDuration = const Duration(milliseconds: 2500),
    this.appGridOutterPadding = const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 12),
    this.appCardIconPadding = const EdgeInsets.only(bottom: 20, left: 8, right: 8, top: 8),
    this.appCardBackgroundColour,
    this.appCardGradient,
    this.cornerRadius = 0,
    this.selectorTheme = const SelectorTheme(),
  });

  double get gridOutterSideSize => appGridOutterPadding.left + appGridOutterPadding.right;
  double get gridOutterTopsSize => appGridOutterPadding.top + appGridOutterPadding.bottom;
  int get appsPerPage => rows * columns;

  Decoration get appCardDecoration =>
      BoxDecoration(color: appCardBackgroundColour, gradient: appCardGradient, borderRadius: BorderRadius.circular(cornerRadius));

  TextStyle get appCardTextStyle => TextStyle(
    fontSize: appCardFontSize,
    fontWeight: FontWeight.w500,
    fontFamily: "SlatePro",
    height: 1,
    color: appCardTextColour,
    shadows: [
      Shadow(offset: Offset(-0.5, -0.5), color: appCardTextOutlineColour),
      Shadow(offset: Offset(0.5, -0.5), color: appCardTextOutlineColour),
      Shadow(offset: Offset(0.5, 0.5), color: appCardTextOutlineColour),
      Shadow(offset: Offset(-0.5, 0.5), color: appCardTextOutlineColour),
      Shadow(blurRadius: 3, color: Colors.black, offset: Offset(0, 1.5)),
    ],
    overflow: TextOverflow.clip,
  );

  @override
  List<Object?> get props => [
    columns,
    rows,
    iconSize,
    appCardFontSize,
    appCardTextOutlineColour,
    appCardTextColour,
    appGridOutterPadding,
    appCardIconPadding,
    columnSpacing,
    rowSpacing,
    appGridEdgeHoverZoneWidth,
    appGridEdgeHoverDuration,
    appCardBackgroundColour,
    appCardGradient,
    selectorTheme,
  ];

  /// Connect the generated [_$AppGridThemeFromJson] function to the `fromJson`
  /// factory.
  factory AppGridTheme.fromJson(Map<String, dynamic> json) => _$AppGridThemeFromJson(json);

  /// Connect the generated [_$AppGridThemeToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$AppGridThemeToJson(this);

  /// The JSON Schema for this class.
  static const jsonSchema = _$AppGridThemeJsonSchema;
}
