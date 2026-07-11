/// Defensive helpers for parsing loosely-typed API payloads.
///
/// Some On The Way endpoints return a bare JSON list, others wrap it in an
/// object (e.g. `{ "items": [...] }` or `{ "results": [...] }`). These helpers
/// normalize both shapes so feed/history screens never silently show an empty
/// list because of an envelope change.
library;

/// Extracts a list of JSON maps from a `dynamic` API payload.
List<Map<String, dynamic>> extractJsonList(dynamic data) {
  final List<dynamic> raw;
  if (data is List) {
    raw = data;
  } else if (data is Map) {
    final candidate = data['items'] ??
        data['results'] ??
        data['data'] ??
        data['list'] ??
        data.values.firstWhere((v) => v is List, orElse: () => null);
    raw = candidate is List ? candidate : const <dynamic>[];
  } else {
    raw = const <dynamic>[];
  }
  return raw
      .whereType<Map<dynamic, dynamic>>()
      .map((m) => m.cast<String, dynamic>())
      .toList(growable: false);
}
