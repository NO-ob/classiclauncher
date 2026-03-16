import 'package:classiclauncher/models/theme/selector_theme.dart';
import 'package:classiclauncher/models/theme/serializable_util.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'text_field_theme.g.dart';

@CopyWith()
@JsonSerializable(createJsonSchema: true)
class TextFieldTheme extends Equatable {
  final double fontSize;
  @ColourConverter()
  final Color? textColour;
  @EdgeInsetsConverter()
  final EdgeInsets textPadding;
  @EdgeInsetsConverter()
  final EdgeInsets letterPadding;

  @EdgeInsetsConverter()
  final EdgeInsets textFieldPadding;
  final double textFieldHeight;
  @ColourConverter()
  final Color backgroundColour;
  @EdgeInsetsConverter()
  final EdgeInsets iconPadding;
  final double iconSize;
  @ColourConverter()
  final Color iconColour;
  @ColourConverter()
  final Color cursorColour;
  final double cursorWidth;
  final double cursorHeight;
  final SelectorTheme selectorTheme;

  const TextFieldTheme({
    this.textFieldHeight = 44,
    this.textFieldPadding = const EdgeInsets.only(left: 8, right: 8),
    this.textPadding = const EdgeInsets.only(left: 8, right: 8),
    this.letterPadding = const EdgeInsets.only(top: 6),
    this.textColour = Colors.white,

    this.fontSize = 20,
    this.backgroundColour = const Color(0xFF202020),
    this.iconPadding = const EdgeInsets.all(8),
    this.iconSize = 28,
    this.iconColour = Colors.white,
    this.cursorColour = const Color(0xFF0581b2),
    this.selectorTheme = const SelectorTheme(selectorBorderRadius: 0),
    this.cursorWidth = 3,
    this.cursorHeight = 30,
  });

  double get totalIconWidth => iconSize + iconPadding.left + iconPadding.right;

  TextStyle get textStyle => TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500, fontFamily: "SlatePro", height: 1, color: textColour);

  @override
  List<Object?> get props => [textFieldHeight, textFieldPadding, textColour, fontSize, backgroundColour, iconPadding, iconSize, cursorColour, selectorTheme];

  /// Connect the generated [_$TextFieldThemeFromJson] function to the `fromJson`
  /// factory.
  factory TextFieldTheme.fromJson(Map<String, dynamic> json) => _$TextFieldThemeFromJson(json);

  /// Connect the generated [_$TextFieldThemeToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$TextFieldThemeToJson(this);

  /// The JSON Schema for this class.
  static const jsonSchema = _$TextFieldThemeJsonSchema;
}
