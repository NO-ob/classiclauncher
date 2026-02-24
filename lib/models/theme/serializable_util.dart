import 'package:classiclauncher/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

class EdgeInsetsConverter implements JsonConverter<EdgeInsets, Map<String, dynamic>> {
  const EdgeInsetsConverter();

  @override
  EdgeInsets fromJson(Map<String, dynamic> json) {
    return EdgeInsets.fromLTRB(
      (json['left'] ?? 0).toDouble(),
      (json['top'] ?? 0).toDouble(),
      (json['right'] ?? 0).toDouble(),
      (json['bottom'] ?? 0).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(EdgeInsets object) {
    return {'left': object.left, 'top': object.top, 'right': object.right, 'bottom': object.bottom};
  }
}

class ColourConverter implements JsonConverter<Color, String> {
  const ColourConverter();

  @override
  Color fromJson(String json) {
    if (!json.startsWith('RGBA#') || json.length != 13) {
      throw FormatException('Invalid color format: $json');
    }

    final red = int.parse(json.substring(5, 7), radix: 16);
    final green = int.parse(json.substring(7, 9), radix: 16);
    final blue = int.parse(json.substring(9, 11), radix: 16);
    final alpha = int.parse(json.substring(11, 13), radix: 16);

    Color colour = Color.fromARGB(alpha, red, green, blue);

    Logger().log(location: "ColourConverter.fromJson", message: "Converted $json to $colour");

    return colour;
  }

  String toHex(int val) {
    return val.toRadixString(16).padLeft(2, '0');
  }

  @override
  String toJson(Color object) {
    int red = (object.r * 255).round();
    int green = (object.g * 255).round();
    int blue = (object.b * 255).round();
    int alpha = (object.a * 255).round();

    String rgbaString = "RGBA#${toHex(red)}${toHex(green)}${toHex(blue)}${toHex(alpha)}";

    Logger().log(location: "ColourConverter.toJson", message: "Converting $object to $rgbaString");

    return rgbaString;
  }
}

class GradientConverter implements JsonConverter<Gradient, Map<String, dynamic>> {
  const GradientConverter();

  List<Color> _coloursFromJson(List<dynamic> json) => json.map((c) => const ColourConverter().fromJson(c as String)).toList();

  List<String> _coloursToJson(List<Color> colours) => colours.map((c) => const ColourConverter().toJson(c)).toList();

  // ── Alignment ──────────────────────────────────────────────────────────────

  Alignment _alignmentFromJson(Map<String, dynamic> json) => Alignment((json['x'] as num).toDouble(), (json['y'] as num).toDouble());

  Map<String, dynamic> _alignmentToJson(AlignmentGeometry a) {
    // Resolve to a plain Alignment so we can access x/y.
    final resolved = a is Alignment ? a : const Alignment(0, 0);
    return {'x': resolved.x, 'y': resolved.y};
  }

  // ── Main ───────────────────────────────────────────────────────────────────

  @override
  Gradient fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final colours = _coloursFromJson(json['colours'] as List<dynamic>);
    final stops = (json['stops'] as List<dynamic>?)?.map((s) => (s as num).toDouble()).toList();

    switch (type) {
      case 'linear':
        return LinearGradient(
          begin: _alignmentFromJson(json['begin'] as Map<String, dynamic>),
          end: _alignmentFromJson(json['end'] as Map<String, dynamic>),
          colors: colours,
          stops: stops,
          tileMode: _tileModeFromJson(json['tileMode'] as String? ?? 'clamp'),
        );

      case 'radial':
        return RadialGradient(
          center: _alignmentFromJson(json['center'] as Map<String, dynamic>),
          radius: (json['radius'] as num).toDouble(),
          colors: colours,
          stops: stops,
          tileMode: _tileModeFromJson(json['tileMode'] as String? ?? 'clamp'),
          focal: json['focal'] != null ? _alignmentFromJson(json['focal'] as Map<String, dynamic>) : null,
          focalRadius: (json['focalRadius'] as num? ?? 0).toDouble(),
        );

      case 'sweep':
        return SweepGradient(
          center: _alignmentFromJson(json['center'] as Map<String, dynamic>),
          startAngle: (json['startAngle'] as num? ?? 0).toDouble(),
          endAngle: (json['endAngle'] as num? ?? 6.2832).toDouble(),
          colors: colours,
          stops: stops,
          tileMode: _tileModeFromJson(json['tileMode'] as String? ?? 'clamp'),
        );

      default:
        throw ArgumentError('Unknown gradient type: $type');
    }
  }

  @override
  Map<String, dynamic> toJson(Gradient object) {
    if (object is LinearGradient) {
      return {
        'type': 'linear',
        'begin': _alignmentToJson(object.begin),
        'end': _alignmentToJson(object.end),
        'colours': _coloursToJson(object.colors),
        if (object.stops != null) 'stops': object.stops,
        'tileMode': _tileModeToJson(object.tileMode),
      };
    }

    if (object is RadialGradient) {
      return {
        'type': 'radial',
        'center': _alignmentToJson(object.center),
        'radius': object.radius,
        'colours': _coloursToJson(object.colors),
        if (object.stops != null) 'stops': object.stops,
        'tileMode': _tileModeToJson(object.tileMode),
        if (object.focal != null) 'focal': _alignmentToJson(object.focal!),
        'focalRadius': object.focalRadius,
      };
    }

    if (object is SweepGradient) {
      return {
        'type': 'sweep',
        'center': _alignmentToJson(object.center),
        'startAngle': object.startAngle,
        'endAngle': object.endAngle,
        'colours': _coloursToJson(object.colors),
        if (object.stops != null) 'stops': object.stops,
        'tileMode': _tileModeToJson(object.tileMode),
      };
    }

    throw ArgumentError('Unsupported gradient type: ${object.runtimeType}');
  }

  // ── TileMode helpers ───────────────────────────────────────────────────────

  TileMode _tileModeFromJson(String value) => switch (value) {
    'clamp' => TileMode.clamp,
    'mirror' => TileMode.mirror,
    'repeated' => TileMode.repeated,
    'decal' => TileMode.decal,
    _ => throw ArgumentError('Unknown TileMode: $value'),
  };

  String _tileModeToJson(TileMode mode) => switch (mode) {
    TileMode.clamp => 'clamp',
    TileMode.mirror => 'mirror',
    TileMode.repeated => 'repeated',
    TileMode.decal => 'decal',
    _ => throw ArgumentError('Unknown TileMode: $mode'),
  };
}
