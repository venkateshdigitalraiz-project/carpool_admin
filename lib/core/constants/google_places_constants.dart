class GooglePlacesConstants {
  GooglePlacesConstants._();

  static const String apiKey = 'AIzaSyBpCA99uGvcf267xPpDxv1dWsFkOqB3RYU';

  /// Google Places API (New) Autocomplete endpoint
  static const String newPlacesAutocompleteUrl =
      'https://places.googleapis.com/v1/places:autocomplete';

  /// Legacy Google Places Autocomplete endpoint (for fallback)
  static const String legacyPlacesAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
}
