import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trip_room.dart';
import '../models/schedule.dart';
import '../models/destination_candidate.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<List<TripRoom>> getTripRooms() async {
    final response = await http.get(Uri.parse('$baseUrl/api/trip-rooms'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TripRoom.fromJson(e)).toList();
    } else {
      throw Exception('여행방 데이터를 불러오지 못했습니다.');
    }
  }

  static Future<List<Schedule>> getSchedulesByTripRoomId(int tripRoomId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/schedules/trip-room/$tripRoomId'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Schedule.fromJson(e)).toList();
    } else {
      throw Exception('일정 데이터를 불러오지 못했습니다.');
    }
  }

  static Future<List<DestinationCandidate>>
  getDestinationCandidatesByTripRoomId(int tripRoomId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/destination-candidates/trip-room/$tripRoomId'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DestinationCandidate.fromJson(e)).toList();
    } else {
      throw Exception('여행지 후보 데이터를 불러오지 못했습니다.');
    }
  }
}
