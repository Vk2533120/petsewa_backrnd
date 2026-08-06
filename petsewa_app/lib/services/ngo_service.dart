import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for all NGO-related API calls to the NestJS backend.
/// Base URL uses 10.0.2.2 for Android emulator (maps to host machine localhost).
class NgoService {
  // Change to your actual backend URL when deploying on a real device/server
  static const String baseUrl = 'http://10.0.2.2:3000';

  final _headers = {'Content-Type': 'application/json'};

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  String get _currentUserEmail =>
      Supabase.instance.client.auth.currentUser?.email ?? '';

  // ─── NGO REGISTRATION & AUTH ────────────────────────────────────────────

  /// Register a new NGO — status will be 'pending' after submission
  Future<Map<String, dynamic>> registerNgo({
    required String name,
    required String email,
    required String password,
    required String registrationNumber,
    String? contactPhone,
    String? location,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ngo/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'registrationNumber': registrationNumber,
        if (contactPhone != null) 'contactPhone': contactPhone,
        if (location != null) 'location': location,
        if (description != null) 'description': description,
      }),
    );
    return _handleResponse(response);
  }

  /// NGO login — returns NGO data on success
  Future<Map<String, dynamic>> ngoLogin({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ngo/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  // ─── NGO BROWSE ─────────────────────────────────────────────────────────

  /// Get all approved NGOs for user browse
  Future<List<dynamic>> getAllApprovedNgos() async {
    final response = await http.get(Uri.parse('$baseUrl/ngo/all'));
    final result = _handleResponse(response);
    return result is List ? result : [];
  }

  /// Get NGO details by ID
  Future<Map<String, dynamic>> getNgoById(int ngoId) async {
    final response = await http.get(Uri.parse('$baseUrl/ngo/$ngoId'));
    return _handleResponse(response);
  }

  /// Update NGO profile
  Future<Map<String, dynamic>> updateNgoProfile(
    int ngoId, {
    String? name,
    String? contactPhone,
    String? location,
    String? description,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/ngo/$ngoId/profile'),
      headers: _headers,
      body: jsonEncode({
        if (name != null) 'name': name,
        if (contactPhone != null) 'contactPhone': contactPhone,
        if (location != null) 'location': location,
        if (description != null) 'description': description,
      }),
    );
    return _handleResponse(response);
  }

  // ─── ADMIN ENDPOINTS ────────────────────────────────────────────────────

  Future<List<dynamic>> getPendingNgos() async {
    final response = await http.get(Uri.parse('$baseUrl/ngo/admin/pending'));
    final result = _handleResponse(response);
    return result is List ? result : [];
  }

  Future<Map<String, dynamic>> approveNgo(int ngoId) async {
    final response = await http.patch(Uri.parse('$baseUrl/ngo/$ngoId/approve'));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> rejectNgo(int ngoId, {String? reason}) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/ngo/$ngoId/reject'),
      headers: _headers,
      body: jsonEncode({if (reason != null) 'reason': reason}),
    );
    return _handleResponse(response);
  }

  // ─── PET MANAGEMENT ─────────────────────────────────────────────────────

  /// Get all available pets across all NGOs
  Future<List<dynamic>> getAllAvailablePets() async {
    final response = await http.get(Uri.parse('$baseUrl/ngo/pets/all'));
    final result = _handleResponse(response);
    return result is List ? result : [];
  }

  /// Get pets for a specific NGO
  Future<List<dynamic>> getNgoPets(int ngoId) async {
    final response = await http.get(Uri.parse('$baseUrl/ngo/$ngoId/pets'));
    final result = _handleResponse(response);
    return result is List ? result : [];
  }

  /// Add a pet listing (NGO only)
  Future<Map<String, dynamic>> addPet(
    int ngoId, {
    required String petName,
    String? breed,
    String? age,
    String? gender,
    String? description,
    bool isVaccinated = false,
    String? healthNotes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ngo/$ngoId/pets'),
      headers: _headers,
      body: jsonEncode({
        'petName': petName,
        if (breed != null) 'breed': breed,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (description != null) 'description': description,
        'isVaccinated': isVaccinated,
        if (healthNotes != null) 'healthNotes': healthNotes,
      }),
    );
    return _handleResponse(response);
  }

  /// Delete a pet listing
  Future<Map<String, dynamic>> deletePet(int petId, int ngoId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ngo/pets/$petId'),
      headers: _headers,
      body: jsonEncode({'ngoId': ngoId}),
    );
    return _handleResponse(response);
  }

  // ─── ADOPTION REQUESTS ──────────────────────────────────────────────────

  /// User sends an adoption request for a pet
  Future<Map<String, dynamic>> sendAdoptionRequest({
    required int petId,
    required int ngoId,
    required String userName,
    required String userPhone,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ngo/adoption-request'),
      headers: _headers,
      body: jsonEncode({
        'petId': petId,
        'ngoId': ngoId,
        'userId': _currentUserId,
        'userName': userName,
        'userEmail': _currentUserEmail,
        'userPhone': userPhone,
        if (message != null) 'message': message,
      }),
    );
    return _handleResponse(response);
  }

  /// NGO views incoming requests
  Future<List<dynamic>> getNgoRequests(int ngoId) async {
    final response = await http.get(Uri.parse('$baseUrl/ngo/$ngoId/requests'));
    final result = _handleResponse(response);
    return result is List ? result : [];
  }

  /// User views their own adoption requests
  Future<List<dynamic>> getUserRequests() async {
    final userId = _currentUserId;
    if (userId.isEmpty) return [];
    final response = await http.get(Uri.parse('$baseUrl/ngo/user-requests/$userId'));
    final result = _handleResponse(response);
    return result is List ? result : [];
  }

  /// NGO accepts a request
  Future<Map<String, dynamic>> acceptRequest(int requestId) async {
    final response = await http.patch(Uri.parse('$baseUrl/ngo/requests/$requestId/accept'));
    return _handleResponse(response);
  }

  /// NGO rejects a request
  Future<Map<String, dynamic>> rejectRequest(int requestId, {String? reason}) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/ngo/requests/$requestId/reject'),
      headers: _headers,
      body: jsonEncode({if (reason != null) 'reason': reason}),
    );
    return _handleResponse(response);
  }

  /// NGO schedules a meet
  Future<Map<String, dynamic>> scheduleMeet(int requestId, String meetDateTime) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/ngo/requests/$requestId/meet'),
      headers: _headers,
      body: jsonEncode({'meetDateTime': meetDateTime}),
    );
    return _handleResponse(response);
  }

  /// NGO marks pet as adopted — final workflow step
  Future<Map<String, dynamic>> markAdopted(int requestId) async {
    final response = await http.patch(Uri.parse('$baseUrl/ngo/requests/$requestId/adopted'));
    return _handleResponse(response);
  }

  // ─── CAMPAIGNS ──────────────────────────────────────────────────────────

  Future<List<dynamic>> getActiveCampaigns() async {
    final response = await http.get(Uri.parse('$baseUrl/ngo/campaigns/active'));
    final result = _handleResponse(response);
    return result is List ? result : [];
  }

  Future<Map<String, dynamic>> donate(int campaignId, double amount) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/ngo/campaigns/$campaignId/donate'),
      headers: _headers,
      body: jsonEncode({'amount': amount}),
    );
    return _handleResponse(response);
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body['message'] ?? 'Something went wrong. Please try again.';
    throw Exception(message);
  }
}
