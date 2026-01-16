import '../config/app_config.dart';

int jsonToInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double jsonToDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

String jsonToString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

DateTime jsonToDateTime(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
}

String? jsonToUrl(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  final uri = Uri.tryParse(raw);
  if (uri != null && uri.hasScheme) {
    return raw;
  }
  final base = Uri.parse(AppConfig.apiBaseUrl);
  return base.resolve(raw).toString();
}
