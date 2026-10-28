import 'package:equatable/equatable.dart';

class PlacePrediction extends Equatable {
  final String placeId;
  final String fullText;
  final String mainText;
  final String secondaryText;
  final List<String> types;

  const PlacePrediction({
    required this.placeId,
    required this.fullText,
    required this.mainText,
    required this.secondaryText,
    this.types = const [],
  });

  /// Returns the full address (e.g. "Vijayawada, Andhra Pradesh, India")
  String get displayAddress {
    if (fullText.trim().isNotEmpty) {
      return fullText.trim();
    }
    if (mainText.trim().isNotEmpty && secondaryText.trim().isNotEmpty) {
      return '${mainText.trim()}, ${secondaryText.trim()}';
    }
    return mainText.trim().isNotEmpty ? mainText.trim() : secondaryText.trim();
  }

  @override
  List<Object?> get props => [
    placeId,
    fullText,
    mainText,
    secondaryText,
    types,
  ];
}
