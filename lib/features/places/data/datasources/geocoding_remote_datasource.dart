import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/google_places_constants.dart';

class GeocodedLocation {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String? localName;

  const GeocodedLocation({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    this.localName,
  });
}

/// Dynamic Geocoding Service:
/// Resolves real GPS coordinates for any city, address, or landmark dynamically.
/// Queries Google Geocoding API first, with fallback to OpenStreetMap Nominatim.
class DynamicGeocodingService {
  static final http.Client _client = http.Client();
  static final Map<String, GeocodedLocation> _cache = {};

  static Future<GeocodedLocation?> getCoordinates(String address) async {
    final clean = address.trim();
    if (clean.isEmpty) return null;

    final cacheKey = clean.toLowerCase();
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    // 1. Attempt Google Geocoding API with API key
    try {
      final googleUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(clean)}&key=${GooglePlacesConstants.apiKey}',
      );
      final response = await _client.get(googleUrl);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;
        final results = data['results'] as List<dynamic>? ?? [];

        if (status == 'OK' && results.isNotEmpty) {
          final first = results.first as Map<String, dynamic>;
          final geom = first['geometry'] as Map<String, dynamic>? ?? {};
          final loc = geom['location'] as Map<String, dynamic>? ?? {};
          final lat = (loc['lat'] as num?)?.toDouble();
          final lng = (loc['lng'] as num?)?.toDouble();
          final formatted = first['formatted_address'] as String? ?? clean;

          if (lat != null && lng != null) {
            final result = GeocodedLocation(
              latitude: lat,
              longitude: lng,
              formattedAddress: formatted,
            );
            _cache[cacheKey] = result;
            return result;
          }
        }
      }
    } catch (_) {}

    // 2. Dynamic Worldwide Geocoding via OpenStreetMap Nominatim (Free, no billing restrictions)
    try {
      final osmUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(clean)}&format=json&limit=1&addressdetails=1',
      );
      final response = await _client.get(
        osmUrl,
        headers: {'User-Agent': 'CarpoolApp/1.0 (contact@carpool.com)'},
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>? ?? [];
        if (list.isNotEmpty) {
          final item = list.first as Map<String, dynamic>;
          final lat = double.tryParse(item['lat']?.toString() ?? '');
          final lon = double.tryParse(item['lon']?.toString() ?? '');
          final displayName = item['display_name'] as String? ?? clean;
          final namedetails = item['namedetails'] as Map<String, dynamic>?;
          final localName = namedetails?['name:te'] ??
              namedetails?['name:kn'] ??
              namedetails?['name:hi'] ??
              namedetails?['name:ta'];

          if (lat != null && lon != null) {
            final result = GeocodedLocation(
              latitude: lat,
              longitude: lon,
              formattedAddress: displayName,
              localName: localName as String?,
            );
            _cache[cacheKey] = result;
            return result;
          }
        }
      }
    } catch (_) {}

    return null;
  }
}
