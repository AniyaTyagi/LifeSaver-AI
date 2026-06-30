import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use http://10.0.2.2:8000 for Android Emulator, or your hosted domain
  static const String baseUrl = 'http://localhost:8000/api'; 
  
  // Storage for authentication token
  String? _authToken;

  void updateToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ==========================================
  // Task Requests
  // ==========================================

  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch tasks: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: _headers,
      body: json.encode(taskData),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<Map<String, dynamic>> analyzeVoice(String transcript) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks/voice-analyze'),
      headers: _headers,
      body: json.encode({'text': transcript}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Voice analysis failed');
    }
  }

  // ==========================================
  // Agent Pipeline Triggers
  // ==========================================

  Future<Map<String, dynamic>> calculateRisk(String taskId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/agents/risk-predict/$taskId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Risk calculation failed');
    }
  }

  Future<Map<String, dynamic>> fetchPrioritizedTasks() async {
    final response = await http.post(
      Uri.parse('$baseUrl/agents/prioritize'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Prioritization ranking failed');
    }
  }

  Future<Map<String, dynamic>> autoScheduleCalendar() async {
    final response = await http.post(
      Uri.parse('$baseUrl/agents/schedule'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Auto scheduling failed');
    }
  }

  Future<Map<String, dynamic>> checkIntervention(String taskId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/agents/intervention/$taskId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Intervention calculation failed');
    }
  }

  Future<Map<String, dynamic>> triggerAccountabilityCoach(String taskId, int snoozeCount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/agents/coach-procrastinate/$taskId?snooze_count=$snoozeCount'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Coaching request failed');
    }
  }

  Future<Map<String, dynamic>> triggerRecoveryPlan(String taskId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/agents/recovery/$taskId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Recovery plan generation failed');
    }
  }
}
