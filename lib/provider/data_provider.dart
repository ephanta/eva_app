import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataProvider with ChangeNotifier {
  final SupabaseClient _client;

  final String _recipeEdgeFunctionUrl = 'https://saxeplastjnaakcyifnn.supabase.co/functions/v1/recipe-management';
  final String _householdEdgeFunctionUrl = 'https://saxeplastjnaakcyifnn.supabase.co/functions/v1/household-management';

  DataProvider(this._client);

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<Session?> getCurrentSession() async {
    return _client.auth.currentSession;
  }

  Future<String?> _getAuthToken() async {
    final session = _client.auth.currentSession;
    if (session != null) {
      if (session.expiresAt != null) {
        final expirationDate = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
        if (expirationDate.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
          final response = await _client.auth.refreshSession();
          return response.session?.accessToken;
        }
      }
      return session.accessToken;
    }
    return null;
  }

  Future<T> _makeRequest<T>(String url, String method, {Map<String, dynamic>? body, Map<String, String>? queryParams}) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: json.encode(body));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: json.encode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        if (responseData is T) {
          return responseData;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Request failed with status: ${response.statusCode}. ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to perform request: $e');
    }
  }

  // Recipe-related methods

  Future<List<Map<String, dynamic>>> fetchUserRecipes() async {
    final response = await _makeRequest<Map<String, dynamic>>(_recipeEdgeFunctionUrl, 'GET');
    if (response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    } else {
      throw Exception('Unexpected response format for recipes');
    }
  }

  Future<void> addNewRecipe(Map<String, dynamic> recipe) async {
    await _makeRequest<Map<String, dynamic>>(_recipeEdgeFunctionUrl, 'POST', body: recipe);
    notifyListeners();
  }

  Future<void> updateRecipe(String recipeId, Map<String, dynamic> recipe) async {
    await _makeRequest<Map<String, dynamic>>(_recipeEdgeFunctionUrl, 'PUT',
        queryParams: {'id': recipeId}, body: recipe);
    notifyListeners();
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _makeRequest<Map<String, dynamic>>(_recipeEdgeFunctionUrl, 'DELETE',
        queryParams: {'id': recipeId});
    notifyListeners();
  }

  // Household-related methods

  Future<List<Map<String, dynamic>>> fetchUserHouseholds() async {
    final response = await _makeRequest<Map<String, dynamic>>(_householdEdgeFunctionUrl, 'GET');
    if (response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data'].map((household) {
        return {
          'id': household['id'],
          'name': household['name'],
          'color': household['color']
        };
      }));
    } else {
      throw Exception('Unexpected response format for households');
    }
  }

  Future<String> createHousehold(String householdName, String color) async {
    final response = await _makeRequest<Map<String, dynamic>>(_householdEdgeFunctionUrl, 'POST',
        body: {'name': householdName, 'color': color});
    if (response['data'] is List) {
      return response['data'][0]['id'];
    } else {
      throw Exception('Unexpected response format while creating household');
    }
  }

  Future<String> joinHousehold(String inviteCode) async {
    final response = await _makeRequest<Map<String, dynamic>>(_householdEdgeFunctionUrl, 'POST',
        queryParams: {'action': 'join'}, body: {'invite_code': inviteCode});
    if (response.containsKey('household_id')) {
      return response['household_id'];
    } else {
      throw Exception('Unexpected response format while joining household');
    }
  }

  Future<String> getUserRoleInHousehold(String householdId) async {
    final response = await _makeRequest<Map<String, dynamic>>(_householdEdgeFunctionUrl, 'GET',
        queryParams: {'household_id': householdId, 'action': 'get_role'});
    if (response.containsKey('role')) {
      return response['role'];
    } else {
      throw Exception('Unexpected response format for user role');
    }
  }

  Future<void> updateHousehold(String householdId, {required String name, required String color}) async {
    await _makeRequest<Map<String, dynamic>>(_householdEdgeFunctionUrl, 'PUT',
        queryParams: {'household_id': householdId}, body: {'name': name, 'color': color});
    notifyListeners();
  }

  Future<void> deleteHousehold(String householdId) async {
    await _makeRequest<Map<String, dynamic>>(_householdEdgeFunctionUrl, 'DELETE',
        queryParams: {'household_id': householdId});
    notifyListeners();
  }

  Future<void> leaveHousehold(String householdId) async {
    await _makeRequest<Map<String, dynamic>>(_householdEdgeFunctionUrl, 'DELETE',
        queryParams: {'household_id': householdId, 'action': 'leave'});
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getHouseholdMembers(String householdId) async {
    final response = await _makeRequest<Map<String, dynamic>>(_householdEdgeFunctionUrl, 'GET',
        queryParams: {'household_id': householdId, 'action': 'get_members'});
    if (response['members'] is List) {
      return List<Map<String, dynamic>>.from(response['members']);
    } else {
      throw Exception('Unexpected response format for household members');
    }
  }

  Future<Map<String, dynamic>> getCurrentHousehold(String householdId) async {
    final response = await _makeRequest<Map<String, dynamic>>(_householdEdgeFunctionUrl, 'GET',
        queryParams: {'household_id': householdId, 'action': 'get_details'});
    if (response['data'] is List && response['data'].isNotEmpty) {
      return response['data'][0];
    } else {
      throw Exception('Unexpected response format for current household');
    }
  }
}
