import '../models/reservation_models.dart';
import 'apiservice.dart';

class ReservationService {
  static final ReservationService _instance = ReservationService._internal();
  factory ReservationService() => _instance;
  ReservationService._internal();

  final ApiService _apiService = ApiService();

  /// Fetch all reservations for the current user
  Future<List<Reservation>> getMyReservations() async {
    try {
      final response = await _apiService.get('/accommodations', withAuth: true);
      
      if (response is List) {
        return response.map((json) => Reservation.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      throw Exception('Failed to fetch reservations: $e');
    }
  }

  /// Get a single reservation by ID
  Future<Reservation> getReservationById(int id) async {
    try {
      final response = await _apiService.get('/accommodations/$id', withAuth: true);
      return Reservation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch reservation: $e');
    }
  }

  /// Cancel a reservation
  Future<void> cancelReservation(int id) async {
    try {
      await _apiService.post('/accommodations/$id/cancel', withAuth: true);
    } catch (e) {
      throw Exception('Failed to cancel reservation: $e');
    }
  }

  /// Update reservation special requests
  Future<void> updateReservationRequests(int id, String specialRequests) async {
    try {
      await _apiService.post(
        '/accommodations/$id/update-requests',
        body: {'special_requests': specialRequests},
        withAuth: true,
      );
    } catch (e) {
      throw Exception('Failed to update reservation requests: $e');
    }
  }
}
