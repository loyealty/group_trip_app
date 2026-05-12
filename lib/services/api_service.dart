import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trip_room.dart';
import '../models/schedule.dart';
import '../models/destination_candidate.dart';
import '../models/expense.dart';
import '../models/trip_member.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Map<String, String> headers = {'Content-Type': 'application/json'};

  static Future<List<TripRoom>> getTripRooms() async {
    final response = await http.get(Uri.parse('$baseUrl/api/trip-rooms'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TripRoom.fromJson(e)).toList();
    } else {
      throw Exception('여행방 데이터를 불러오지 못했습니다.');
    }
  }

  static Future<void> createTripRoom({
    required String title,
    required String description,
    required String destination,
    required String startDate,
    required String endDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/trip-rooms'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'ownerId': 1,
        'startDate': startDate,
        'endDate': endDate,
        'destination': destination,
        'status': 'PLANNING',
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('여행방 생성에 실패했습니다.');
    }
  }

  static Future<List<TripMember>> getTripMembersByTripRoomId(
    int tripRoomId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/trip-members/trip-room/$tripRoomId'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TripMember.fromJson(e)).toList();
    } else {
      throw Exception('멤버 데이터를 불러오지 못했습니다.');
    }
  }

  static Future<void> createTripMember({
    required int tripRoomId,
    required String memberName,
    String role = 'MEMBER',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/trip-members'),
      headers: headers,
      body: jsonEncode({
        'tripRoomId': tripRoomId,
        'memberName': memberName,
        'role': role,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('멤버 추가에 실패했습니다.');
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

  static Future<void> createSchedule({
    required int tripRoomId,
    required String title,
    required String location,
    required String description,
    required String scheduleDate,
    required String scheduleTime,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/schedules'),
      headers: headers,
      body: jsonEncode({
        'tripRoomId': tripRoomId,
        'title': title,
        'location': location,
        'description': description,
        'scheduleDate': scheduleDate,
        'scheduleTime': scheduleTime,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('일정 추가에 실패했습니다.');
    }
  }

  static Future<void> updateSchedule({
    required int id,
    required int tripRoomId,
    required String title,
    required String location,
    required String description,
    required String scheduleDate,
    required String scheduleTime,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/schedules/$id'),
      headers: headers,
      body: jsonEncode({
        'tripRoomId': tripRoomId,
        'title': title,
        'location': location,
        'description': description,
        'scheduleDate': scheduleDate,
        'scheduleTime': scheduleTime,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('일정 수정에 실패했습니다.');
    }
  }

  static Future<void> deleteSchedule(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/schedules/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('일정 삭제에 실패했습니다.');
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

  static Future<void> createDestinationCandidate({
    required int tripRoomId,
    required String name,
    required String region,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/destination-candidates'),
      headers: headers,
      body: jsonEncode({
        'tripRoomId': tripRoomId,
        'name': name,
        'region': region,
        'description': description,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('여행지 후보 추가에 실패했습니다.');
    }
  }

  static Future<void> voteDestinationCandidate(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/destination-candidates/$id/vote'),
    );

    if (response.statusCode != 200) {
      throw Exception('여행지 투표에 실패했습니다.');
    }
  }

  static Future<void> updateDestinationCandidate({
    required int id,
    required int tripRoomId,
    required String name,
    required String region,
    required String description,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/destination-candidates/$id'),
      headers: headers,
      body: jsonEncode({
        'tripRoomId': tripRoomId,
        'name': name,
        'region': region,
        'description': description,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('여행지 후보 수정에 실패했습니다.');
    }
  }

  static Future<void> deleteDestinationCandidate(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/destination-candidates/$id'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('여행지 후보 삭제에 실패했습니다.');
    }
  }

  static Future<List<Expense>> getExpensesByTripRoomId(int tripRoomId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/expenses/trip-room/$tripRoomId'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    } else {
      throw Exception('정산 데이터를 불러오지 못했습니다.');
    }
  }

  static Future<void> createExpense({
    required int tripRoomId,
    required String category,
    required String title,
    required String payer,
    required int amount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/expenses'),
      headers: headers,
      body: jsonEncode({
        'tripRoomId': tripRoomId,
        'category': category,
        'title': title,
        'payer': payer,
        'amount': amount,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('정산 내역 추가에 실패했습니다.');
    }
  }

  static Future<void> updateExpense({
    required int id,
    required int tripRoomId,
    required String category,
    required String title,
    required String payer,
    required int amount,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/expenses/$id'),
      headers: headers,
      body: jsonEncode({
        'tripRoomId': tripRoomId,
        'category': category,
        'title': title,
        'payer': payer,
        'amount': amount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('정산 내역 수정에 실패했습니다.');
    }
  }

  static Future<void> deleteExpense(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/expenses/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('정산 내역 삭제에 실패했습니다.');
    }
  }
}
