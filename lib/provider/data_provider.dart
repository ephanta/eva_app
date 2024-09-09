import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataProvider with ChangeNotifier {
  final SupabaseClient _client;
  final String _edgeFunctionUrl = 'https://rzuydrppeuyrdycvmpbm.supabase.co/functions/v1/recipe-management';

  DataProvider(this._client);

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('user_id', userId) // Make sure this is the correct column name
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<Session?> getCurrentSession() async {
    return _client.auth.currentSession;
  }

  Future<String?> _getAuthToken() async {
    final session = _client.auth.currentSession;

    if (session != null) {
      final accessToken = session.accessToken;

      // Check if the session needs refreshing
      if (session.expiresIn != null && session.expiresIn! < 60) {
        final response = await _client.auth.refreshSession();
        return response.session?.accessToken;
      }

      return accessToken;
    }
    return null;
  }

  // Recipe-related methods using edge function

  Future<List<Map<String, dynamic>>> fetchUserRecipes(String userId) async {
    try {
      final jwtToken = await _getAuthToken();
      if (jwtToken == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$_edgeFunctionUrl?user_id=$userId'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load recipes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }

  Future<void> addNewRecipe(Map<String, dynamic> recipe) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final jwtToken = await _getAuthToken();
      if (jwtToken == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode({'user_id': userId, ...recipe}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add recipe: ${response.body}');
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add recipe: $e');
    }
  }

  Future<void> updateRecipe(String recipeId, Map<String, dynamic> recipe) async {
    try {
      final jwtToken = await _getAuthToken();
      if (jwtToken == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.put(
        Uri.parse('$_edgeFunctionUrl?id=$recipeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode(recipe),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update recipe: ${response.body}');
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      final jwtToken = await _getAuthToken();
      if (jwtToken == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$_edgeFunctionUrl?id=$recipeId'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete recipe: ${response.body}');
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  // Household-related methods

  Future<List<Map<String, dynamic>>> fetchUserHouseholds(String userId) async {
    try {
      final response = await _client
          .from('household_member')
          .select('household_id')
          .eq('member_uid', userId);

      final List householdIds = response;

      final households = await _client.from('households').select();
      final List<Map<String, dynamic>> userHouseholds = households.where((household) {
        return householdIds.any((householdMember) => householdMember['household_id'] == household['id']);
      }).toList();

      return userHouseholds;
    } catch (e) {
      throw Exception('Fehler beim Laden der Haushalte: $e');
    }
  }

  Future<int> createHousehold(String householdName, String userId, String color) async {
    try {
      final inviteCode = DateTime.now().millisecondsSinceEpoch.toString();

      final response = await _client.from('households').insert({
        'name': householdName,
        'color': color,
        'invite_code': inviteCode,
      }).select();

      final List data = response;
      final householdId = data[0]['id'] as int;

      await _client.from('household_member').insert({
        'household_id': householdId,
        'member_uid': userId,
        'role': 'admin',
      });

      notifyListeners();
      return householdId;
    } catch (e) {
      throw Exception('Failed to create household: $e');
    }
  }

  Future<int> joinHousehold(String inviteCode, String userId) async {
    try {
      final response = await _client
          .from('households')
          .select()
          .eq('invite_code', inviteCode)
          .single();

      final householdId = response['id'] as int;

      final memberResponse = await _client
          .from('household_member')
          .select()
          .eq('household_id', householdId)
          .eq('member_uid', userId)
          .maybeSingle();

      if (memberResponse == null) {
        await _client.from('household_member').insert({
          'household_id': householdId,
          'member_uid': userId,
          'role': 'member',
        });
      }

      notifyListeners();
      return householdId;
    } catch (e) {
      throw Exception('Failed to join household: $e');
    }
  }

  Future<String> getUserRoleInHousehold(int householdId, String userId) async {
    try {
      final response = await _client
          .from('household_member')
          .select('role')
          .eq('household_id', householdId)
          .eq('member_uid', userId)
          .single();

      return response['role'];
    } catch (e) {
      throw Exception('Failed to retrieve user role in household: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentHousehold(int householdId) async {
    try {
      final response = await _client
          .from('households')
          .select()
          .eq('id', householdId)
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to load household: $e');
    }
  }

  Future<void> updateHousehold(int householdId, {required String name, required String color}) async {
    try {
      await _client.from('households').update({
        'name': name,
        'color': color,
      }).eq('id', householdId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update household: $e');
    }
  }

  Future<void> deleteHousehold(int householdId) async {
    try {
      await _client.from('households').delete().eq('id', householdId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete household: $e');
    }
  }

  Future<void> leaveHousehold(int householdId, String userId) async {
    try {
      await _client
          .from('household_member')
          .delete()
          .eq('household_id', householdId)
          .eq('member_uid', userId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to leave household: $e');
    }
  }

  // Fetch household members
  Future<List<Map<String, dynamic>>> getHouseholdMembers(int householdId) async {
    try {
      final response = await _client
          .from('household_member')
          .select('username') // Assuming 'username' or another relevant field in the household_member table
          .eq('household_id', householdId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Fehler beim Laden der Haushaltsmitglieder: $e');
    }
  }
}
