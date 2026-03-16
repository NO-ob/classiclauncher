import 'package:classiclauncher/models/theme/serializable_util.dart';
import 'package:classiclauncher/widgets/page_indicator.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'page_indicator_theme.g.dart';

@CopyWith()
@JsonSerializable(createJsonSchema: true)
class PageIndicatorTheme extends Equatable {
  final double pageIndicatorInactiveSize;
  final double pageIndicatorActiveSize;
  final double pageIndicatorSpacing;
  final double pageIndicatorFontSize;
  @ColourConverter()
  final Color pageIndicatorTextColour;
  final IndicatorShape indicatorShape;
  @ColourConverter()
  final Color pageIndicatorColour;

  @ColourConverter()
  final Color pageIndicatorSwipeDotColour;
  @ColourConverter()
  final Color pageIndicatorSwipeDotTextColour;
  final double pageIndicatorSwipeDotTextTopPadding;
  @ColourConverter()
  final Color pageIndicatorSwipeBackgroundColour;
  final double pageIndicatorSwipeDotFontSize;

  final double pageIndicatorSwipeDotSize;
  final double pageIndicatorSwipeDotXOffset;

  const PageIndicatorTheme({
    this.pageIndicatorInactiveSize = 12,
    this.pageIndicatorActiveSize = 22,
    this.pageIndicatorSpacing = 28,
    this.pageIndicatorFontSize = 14,
    this.pageIndicatorTextColour = Colors.black,
    this.indicatorShape = IndicatorShape.circle,
    this.pageIndicatorColour = const Color(0xFFe6e6e6),
    this.pageIndicatorSwipeDotColour = const Color(0xBF000000),
    this.pageIndicatorSwipeDotXOffset = 28,
    this.pageIndicatorSwipeDotFontSize = 32,
    this.pageIndicatorSwipeDotTextColour = Colors.white,
    this.pageIndicatorSwipeBackgroundColour = Colors.black,
    this.pageIndicatorSwipeDotSize = 48,
    this.pageIndicatorSwipeDotTextTopPadding = 5,
  });

  TextStyle get pageIndicatorTextStyle =>
      TextStyle(fontSize: pageIndicatorFontSize, fontWeight: FontWeight.w700, fontFamily: "SlatePro", height: 1, color: pageIndicatorTextColour);

  TextStyle get pageIndicatorSwipeDotTextSTyle =>
      TextStyle(fontSize: pageIndicatorSwipeDotFontSize, fontWeight: FontWeight.w400, fontFamily: "SlatePro", color: pageIndicatorSwipeDotTextColour);

  @override
  List<Object?> get props => [
    pageIndicatorInactiveSize,
    pageIndicatorActiveSize,
    pageIndicatorSpacing,
    pageIndicatorFontSize,
    pageIndicatorTextColour,
    indicatorShape,
    pageIndicatorColour,
    pageIndicatorSwipeDotColour,
    pageIndicatorSwipeDotXOffset,
    pageIndicatorSwipeDotFontSize,
    pageIndicatorSwipeDotTextColour,
    pageIndicatorSwipeBackgroundColour,
    pageIndicatorSwipeDotSize,
    pageIndicatorSwipeDotTextTopPadding,
  ];

  /// Connect the generated [_$PageIndicatorThemeFromJson] function to the `fromJson`
  /// factory.
  factory PageIndicatorTheme.fromJson(Map<String, dynamic> json) => _$PageIndicatorThemeFromJson(json);

  /// Connect the generated [_$PageIndicatorThemeToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$PageIndicatorThemeToJson(this);

  /// The JSON Schema for this class.
  static const jsonSchema = _$PageIndicatorThemeJsonSchema;
}
