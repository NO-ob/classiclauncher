// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uninstall_button_theme.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UninstallButtonThemeCWProxy {
  UninstallButtonTheme uninstallButtonColour(Color uninstallButtonColour);

  UninstallButtonTheme uninstallButtonBorderColour(
    Color uninstallButtonBorderColour,
  );

  UninstallButtonTheme uninstallButtonIconColour(
    Color uninstallButtonIconColour,
  );

  UninstallButtonTheme uninstallButtonSize(double uninstallButtonSize);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `UninstallButtonTheme(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UninstallButtonTheme(...).copyWith(id: 12, name: "My name")
  /// ```
  UninstallButtonTheme call({
    Color uninstallButtonColour,
    Color uninstallButtonBorderColour,
    Color uninstallButtonIconColour,
    double uninstallButtonSize,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfUninstallButtonTheme.copyWith(...)` or call `instanceOfUninstallButtonTheme.copyWith.fieldName(value)` for a single field.
class _$UninstallButtonThemeCWProxyImpl
    implements _$UninstallButtonThemeCWProxy {
  const _$UninstallButtonThemeCWProxyImpl(this._value);

  final UninstallButtonTheme _value;

  @override
  UninstallButtonTheme uninstallButtonColour(Color uninstallButtonColour) =>
      call(uninstallButtonColour: uninstallButtonColour);

  @override
  UninstallButtonTheme uninstallButtonBorderColour(
    Color uninstallButtonBorderColour,
  ) => call(uninstallButtonBorderColour: uninstallButtonBorderColour);

  @override
  UninstallButtonTheme uninstallButtonIconColour(
    Color uninstallButtonIconColour,
  ) => call(uninstallButtonIconColour: uninstallButtonIconColour);

  @override
  UninstallButtonTheme uninstallButtonSize(double uninstallButtonSize) =>
      call(uninstallButtonSize: uninstallButtonSize);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `UninstallButtonTheme(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UninstallButtonTheme(...).copyWith(id: 12, name: "My name")
  /// ```
  UninstallButtonTheme call({
    Object? uninstallButtonColour = const $CopyWithPlaceholder(),
    Object? uninstallButtonBorderColour = const $CopyWithPlaceholder(),
    Object? uninstallButtonIconColour = const $CopyWithPlaceholder(),
    Object? uninstallButtonSize = const $CopyWithPlaceholder(),
  }) {
    return UninstallButtonTheme(
      uninstallButtonColour:
          uninstallButtonColour == const $CopyWithPlaceholder() ||
              uninstallButtonColour == null
          ? _value.uninstallButtonColour
          // ignore: cast_nullable_to_non_nullable
          : uninstallButtonColour as Color,
      uninstallButtonBorderColour:
          uninstallButtonBorderColour == const $CopyWithPlaceholder() ||
              uninstallButtonBorderColour == null
          ? _value.uninstallButtonBorderColour
          // ignore: cast_nullable_to_non_nullable
          : uninstallButtonBorderColour as Color,
      uninstallButtonIconColour:
          uninstallButtonIconColour == const $CopyWithPlaceholder() ||
              uninstallButtonIconColour == null
          ? _value.uninstallButtonIconColour
          // ignore: cast_nullable_to_non_nullable
          : uninstallButtonIconColour as Color,
      uninstallButtonSize:
          uninstallButtonSize == const $CopyWithPlaceholder() ||
              uninstallButtonSize == null
          ? _value.uninstallButtonSize
          // ignore: cast_nullable_to_non_nullable
          : uninstallButtonSize as double,
    );
  }
}

extension $UninstallButtonThemeCopyWith on UninstallButtonTheme {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfUninstallButtonTheme.copyWith(...)` or `instanceOfUninstallButtonTheme.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UninstallButtonThemeCWProxy get copyWith =>
      _$UninstallButtonThemeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UninstallButtonTheme _$UninstallButtonThemeFromJson(
  Map<String, dynamic> json,
) => UninstallButtonTheme(
  uninstallButtonColour: json['uninstallButtonColour'] == null
      ? Colors.black54
      : const ColourConverter().fromJson(
          json['uninstallButtonColour'] as String,
        ),
  uninstallButtonBorderColour: json['uninstallButtonBorderColour'] == null
      ? Colors.white54
      : const ColourConverter().fromJson(
          json['uninstallButtonBorderColour'] as String,
        ),
  uninstallButtonIconColour: json['uninstallButtonIconColour'] == null
      ? Colors.white
      : const ColourConverter().fromJson(
          json['uninstallButtonIconColour'] as String,
        ),
  uninstallButtonSize: (json['uninstallButtonSize'] as num?)?.toDouble() ?? 32,
);

Map<String, dynamic> _$UninstallButtonThemeToJson(
  UninstallButtonTheme instance,
) => <String, dynamic>{
  'uninstallButtonColour': const ColourConverter().toJson(
    instance.uninstallButtonColour,
  ),
  'uninstallButtonBorderColour': const ColourConverter().toJson(
    instance.uninstallButtonBorderColour,
  ),
  'uninstallButtonIconColour': const ColourConverter().toJson(
    instance.uninstallButtonIconColour,
  ),
  'uninstallButtonSize': instance.uninstallButtonSize,
};

const _$UninstallButtonThemeJsonSchema = {
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'type': 'object',
  'properties': {
    'uninstallButtonColour': {r'$ref': r'#/$defs/Color'},
    'uninstallButtonBorderColour': {r'$ref': r'#/$defs/Color'},
    'uninstallButtonIconColour': {r'$ref': r'#/$defs/Color'},
    'uninstallButtonSize': {'type': 'number', 'default': 32.0},
  },
  r'$defs': {
    'Color': {
      'type': 'object',
      'properties': {
        'value': {'type': 'integer'},
      },
      'required': ['value'],
    },
  },
};
