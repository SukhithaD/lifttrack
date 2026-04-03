import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://lifttrack-ujv0.onrender.com';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getSessions() async {
    final headers = await getHeaders();
    final res = await http.get(Uri.parse('$baseUrl/sessions'), headers: headers);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> saveSession(String splitDay, List<Map<String, dynamic>> exercises) async {
    final headers = await getHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/sessions'),
      headers: headers,
      body: jsonEncode({'splitDay': splitDay, 'exercises': exercises}),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getExerciseHistory(String name) async {
    final headers = await getHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/exercises/${Uri.encodeComponent(name)}'),
      headers: headers,
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getAllExercises() async {
    final headers = await getHeaders();
    final res = await http.get(Uri.parse('$baseUrl/exercises'), headers: headers);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getNotificationMessage() async {
    final headers = await getHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/notifications/message'),
      headers: headers,
    );
    return jsonDecode(res.body);
  }
}
