import '../../domain/entities/place_prediction.dart';

class PlacePredictionModel extends PlacePrediction {
  const PlacePredictionModel({
    required super.placeId,
    required super.fullText,
    required super.mainText,
    required super.secondaryText,
    super.types = const [],
  });

  /// Factory parser for Google Places API (New) response
  factory PlacePredictionModel.fromNewPlacesApi(Map<String, dynamic> json) {
    final prediction = json['placePrediction'] as Map<String, dynamic>? ?? json;
    final placeId =
        (prediction['placeId'] ?? prediction['place'] ?? '').toString();
    final textObj = prediction['text'] as Map<String, dynamic>?;
    final fullText =
        (textObj?['text'] ?? prediction['description'] ?? '').toString();

    final structured =
        prediction['structuredFormat'] as Map<String, dynamic>?;
    final mainTextObj = structured?['mainText'] as Map<String, dynamic>?;
    final mainText = (mainTextObj?['text'] ?? fullText).toString();

    final secondaryTextObj =
        structured?['secondaryText'] as Map<String, dynamic>?;
    final secondaryText = (secondaryTextObj?['text'] ?? '').toString();

    final typesList = (prediction['types'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return PlacePredictionModel(
      placeId: placeId,
      fullText: fullText,
      mainText: mainText,
      secondaryText: secondaryText,
      types: typesList,
    );
  }

  /// Factory parser for Legacy Google Places API response (fallback)
  factory PlacePredictionModel.fromLegacyPlacesApi(Map<String, dynamic> json) {
    final placeId = (json['place_id'] ?? '').toString();
    final description = (json['description'] ?? '').toString();
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    final mainText = (structured?['main_text'] ?? description).toString();
    final secondaryText = (structured?['secondary_text'] ?? '').toString();
    final typesList = (json['types'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return PlacePredictionModel(
      placeId: placeId,
      fullText: description,
      mainText: mainText,
      secondaryText: secondaryText,
      types: typesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'fullText': fullText,
      'mainText': mainText,
      'secondaryText': secondaryText,
      'types': types,
    };
  }
}
