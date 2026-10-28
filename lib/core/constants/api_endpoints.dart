class ApiEndpoints {
  // Main Backend Server
  static const String _host = 'http://194.238.19.189:2200';
  static const String baseUrl = '$_host/api';

  // Carpool Endpoints
  static const String carpoolRides = '$baseUrl/carpool/rides';
  static const String carpoolSearch = '$baseUrl/carpool/search';
  static const String carpoolPublish = '$baseUrl/carpool/publish';
  static const String carpoolBookings = '$baseUrl/carpool/bookings';
  static const String carpoolAdminRides = '$baseUrl/admin/carpool/rides';
  static const String carpoolAdminStats = '$baseUrl/admin/carpool/stats';

  static String carpoolRideDetail(String rideId) => '$carpoolRides/$rideId';
  static String carpoolBookRide(String rideId) => '$carpoolRides/$rideId/book';
  static String carpoolCancelBooking(String bookingId) => '$carpoolBookings/$bookingId/cancel';
  static String carpoolUpdateStatus(String rideId) => '$carpoolRides/$rideId/status';

  // Common Endpoints
  static const String serverBaseUrl = _host;
  static const String profile = '$baseUrl/user/profile';

  /// Helper to convert relative server paths (like /uploads/xyz.jpg) to full URLs
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$serverBaseUrl$cleanPath';
  }
}
