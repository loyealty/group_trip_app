import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trip_room.dart';

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
}
