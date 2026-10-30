import '../../domain/entities/route_option.dart';
import '../../domain/entities/stopover.dart';

abstract class StopoversRemoteDataSource {
  Future<List<Stopover>> fetchSuggestedStopovers({
    required String origin,
    required String destination,
    RouteOption? selectedRoute,
  });
}

class StopoversRemoteDataSourceImpl implements StopoversRemoteDataSource {
  @override
  Future<List<Stopover>> fetchSuggestedStopovers({
    required String origin,
    required String destination,
    RouteOption? selectedRoute,
  }) async {
    final oLower = origin.toLowerCase().trim();
    final dLower = destination.toLowerCase().trim();

    // Hyderabad <-> Rajamahendravaram corridor matching the user's screenshot
    final isHydRaj = (oLower.contains('hyd') &&
            (dLower.contains('raja') ||
                dLower.contains('rajahmundry') ||
                dLower.contains('rajamahendravaram'))) ||
        (dLower.contains('hyd') &&
            (oLower.contains('raja') ||
                oLower.contains('rajahmundry') ||
                oLower.contains('rajamahendravaram')));

    if (isHydRaj) {
      return [
        const Stopover(
          id: 'stop-1',
          name: 'Yadadri Bhuvanagiri',
          isSelected: false,
          distanceFromOriginKm: 50,
        ),
        const Stopover(
          id: 'stop-2',
          name: 'Suryapet',
          isSelected: true, // Selected by default matching screenshot
          distanceFromOriginKm: 135,
        ),
        const Stopover(
          id: 'stop-3',
          name: 'Khammam',
          isSelected: false,
          distanceFromOriginKm: 195,
        ),
      ];
    }

    // Hyderabad <-> Vijayawada corridor
    final isHydVij = (oLower.contains('hyd') && dLower.contains('vijayawada')) ||
        (dLower.contains('hyd') && oLower.contains('vijayawada'));
    if (isHydVij) {
      return [
        const Stopover(
          id: 'stop-1',
          name: 'Choutuppal',
          isSelected: false,
          distanceFromOriginKm: 55,
        ),
        const Stopover(
          id: 'stop-2',
          name: 'Suryapet',
          isSelected: true,
          distanceFromOriginKm: 135,
        ),
        const Stopover(
          id: 'stop-3',
          name: 'Kodad',
          isSelected: false,
          distanceFromOriginKm: 180,
        ),
        const Stopover(
          id: 'stop-4',
          name: 'Nandigama',
          isSelected: false,
          distanceFromOriginKm: 225,
        ),
      ];
    }

    // Bangalore <-> Chennai corridor
    final isBlrChn = (oLower.contains('bangalore') && dLower.contains('chennai')) ||
        (dLower.contains('bangalore') && oLower.contains('chennai'));
    if (isBlrChn) {
      return [
        const Stopover(
          id: 'stop-1',
          name: 'Hosur',
          isSelected: false,
          distanceFromOriginKm: 40,
        ),
        const Stopover(
          id: 'stop-2',
          name: 'Krishnagiri',
          isSelected: true,
          distanceFromOriginKm: 90,
        ),
        const Stopover(
          id: 'stop-3',
          name: 'Vellore',
          isSelected: false,
          distanceFromOriginKm: 210,
        ),
      ];
    }

    // Generic dynamic stopovers based on highway or intermediate towns
    final highway = selectedRoute?.highwayName ?? '';
    final primaryName = highway.isNotEmpty && highway.contains('/')
        ? highway.split('/').last.split('-').first.trim()
        : 'Midway Junction';

    return [
      Stopover(
        id: 'stop-generic-1',
        name: primaryName.isNotEmpty ? primaryName : 'Toll Plaza Halt',
        isSelected: true,
      ),
      const Stopover(
        id: 'stop-generic-2',
        name: 'Bypass Food Plaza',
        isSelected: false,
      ),
      const Stopover(
        id: 'stop-generic-3',
        name: 'Expressway Flyover',
        isSelected: false,
      ),
    ];
  }
}
