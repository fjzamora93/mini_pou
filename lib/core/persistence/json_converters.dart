import 'package:json_annotation/json_annotation.dart';

/// Serialises [DateTime] as UTC epoch milliseconds: compact, sortable and
/// free of timezone ambiguity (ISO strings without offset are not).
class UtcEpochMillisConverter implements JsonConverter<DateTime, int> {
  const UtcEpochMillisConverter();

  @override
  DateTime fromJson(int json) =>
      DateTime.fromMillisecondsSinceEpoch(json, isUtc: true);

  @override
  int toJson(DateTime object) => object.toUtc().millisecondsSinceEpoch;
}
