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
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<Session?> getCurrentSession() async {
    return _client.auth.currentSession;
  }

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
      throw Exception('Fehler beim Erstellen des Haushalts: $e');
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
      throw Exception('Fehler beim Laden des Haushalts: $e');
    }
  }

  Future<void> updateHousehold(int householdId, {String? name, String? color}) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (color != null) updateData['color'] = color;

      await _client.from('households').update(updateData).eq('id', householdId);
      notifyListeners();
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren des Haushalts: $e');
    }
  }

  Future<void> deleteHousehold(int householdId) async {
    try {
      await _client.from('household_member').delete().eq('household_id', householdId);
      await _client.from('households').delete().eq('id', householdId);

      notifyListeners();
    } catch (e) {
      throw Exception('Fehler beim Löschen des Haushalts: $e');
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
      throw Exception('Fehler beim Beitreten des Haushalts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getHouseholdMembers(int householdId) async {
    try {
      final memberResponse = await _client
          .from('household_member')
          .select('member_uid')
          .eq('household_id', householdId);

      final List<dynamic> memberIds = memberResponse;

      final profilesResponse = await _client
          .from('profiles')
          .select('user_id, username, email');

      final List<dynamic> profiles = profilesResponse;

      final members = profiles.where((profile) {
        return memberIds.any((member) => member['member_uid'] == profile['user_id']);
      }).map((profile) => {
        'username': profile['username'],
        'email': profile['email'],
      }).toList();

      return members;
    } catch (e) {
      throw Exception('Fehler beim Laden der Haushaltsmitglieder: $e');
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
      throw Exception('Fehler beim Abrufen der Benutzerrolle: $e');
    }
  }

  Future<void> leaveHousehold(int householdId, String userId) async {
    try {
      await _client.from('household_member').delete().eq('household_id', householdId).eq('member_uid', userId);
      notifyListeners();
    } catch (e) {
      throw Exception('Fehler beim Verlassen des Haushalts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserRecipes(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_edgeFunctionUrl?user_id=$userId'),
        headers: {
          'Authorization': 'Bearer ${_client.auth.currentSession?.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }

  Future<void> addNewRecipe(Map<String, dynamic> recipe) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.post(
      Uri.parse(_edgeFunctionUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_client.auth.currentSession?.accessToken}',
      },
      body: json.encode({'user_id': userId, ...recipe}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add recipe');
    }
    notifyListeners();
  }

  Future<void> updateRecipe(String recipeId, Map<String, dynamic> recipe) async {
    final response = await http.put(
      Uri.parse('$_edgeFunctionUrl?id=$recipeId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_client.auth.currentSession?.accessToken}',
      },
      body: json.encode(recipe),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update recipe');
    }
    notifyListeners();
  }

  Future<void> deleteRecipe(String recipeId) async {
    final response = await http.delete(
      Uri.parse('$_edgeFunctionUrl?id=$recipeId'),
      headers: {
        'Authorization': 'Bearer ${_client.auth.currentSession?.accessToken}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recipe');
    }
    notifyListeners();
  }
}