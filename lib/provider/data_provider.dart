import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataProvider with ChangeNotifier {
  final SupabaseClient _client;
  final String _edgeFunctionUrl = 'https://rzuydrppeuyrdycvmpbm.supabase.co/functions/v1/recipe-management';

  DataProvider(this._client);

  String get currentUserId => _client.auth.currentUser!.id;

  Future<Session?> getCurrentSession() async {
    return _client.auth.currentSession;
  }

  /// Erstelle einen neuen Haushalt
  Future createHousehold(
      String householdName, String userId, String color) async {
    try {
      /// Erstelle einen Einladungscode für den Haushalt
      final inviteCode = DateTime.now().millisecondsSinceEpoch.toString();

      /// Füge den Haushalt in die Datenbank ein
      final households = await _client.from('households').insert({
        'name': householdName,
        'color': color,
        'invite_code': inviteCode
      }).select();

      final data = households as List<dynamic>;
      final householdId = data[0]['id'];

      /// Füge den aktuellen User als Mitglied des Haushalts hinzu
      await _client.from('household_member').insert({
        'household_id': householdId,
        'member_uid': userId,
        'role': 'admin'
      }).select();

      notifyListeners();

      return householdId;
    } catch (e) {
      throw Exception('Fehler beim Erstellen des Haushalts: $e');
    }
  }

  /// Erhalte alle Haushalte, denen der aktuelle User angehört
  Future<List<dynamic>> fetchUserHouseholds(String userId) async {
    try {
      /// Erhalte alle Ids der Haushalte, dem der aktuellen User angehört
      final userHouseholdIds = await _client
          .from('household_member')
          .select('household_id')
          .eq('member_uid', userId) as List;

      /// Erhalte alle Haushalte
      final households = await _client.from('households').select() as List;

      /// Wähle die Haushalte aus, die dem aktuellen User gehören und konvertiere das Ergebnis in eine Liste
      final userHouseholds = households
          .where((household) => userHouseholdIds.any((userHousehold) =>
              userHousehold['household_id'] == household['id']))
          .toList();

      return userHouseholds;
    } catch (e) {
      throw Exception('Fehler beim Laden der Haushalte: $e');
    }
  }

  /// Erhalte den aktuellen Haushalt
  Future<Map<String, dynamic>> getCurrentHousehold(String householdId) async {
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

  /// Aktualisiere die Daten des Haushalts
  Future<void> updateHousehold(String householdId,
      {String? name, String? color}) async {
    try {
      /// Erstelle ein leeres Objekt, um die zu aktualisierenden Daten zu speichern
      final updateData = <String, dynamic>{};

      if (name != null) {
        updateData['name'] = name;
      }
      if (color != null) {
        updateData['color'] = color;
      }

      /// Aktualisiere die Daten des Haushalts
      try {
        await _client
            .from('households')
            .update(updateData)
            .eq('id', householdId);

        notifyListeners();
      } catch (e) {
        throw Exception('Fehler beim Aktualisieren des Haushalts: $e');
      }
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren des Haushalts: $e');
    }
  }

  /// Lösche den Haushalt und alle Mitglieder
  Future<void> deleteHousehold(String householdId) async {
    try {
      await _client
          .from('household_member')
          .delete()
          .eq('household_id', householdId);
      await _client.from('households').delete().eq('id', householdId);

      notifyListeners();
    } catch (e) {
      throw Exception('Fehler beim Löschen des Haushalts: $e');
    }
  }

  /// Trete einem Haushalt bei
  Future joinHousehold(String inviteCode, String userId) async {
    try {
      /// Finde den Haushalt basierend auf dem Einladungscode
      final response = await _client
          .from('households')
          .select()
          .eq('invite_code', inviteCode)
          .single();

      final householdId = response['id'];

      /// Prüfe ob der Benutzer bereits Mitglied des Haushalts ist
      final memberResponse = await _client
          .from('household_member')
          .select()
          .eq('household_id', householdId)
          .eq('member_uid', userId)
          .maybeSingle();

      if (memberResponse == null) {
        /// Füge den Benutzer als Mitglied des Haushalts hinzu
        await _client.from('household_member').insert({
          'household_id': householdId,
          'member_uid': userId,
          'role': 'member'
        }).select();
      }
      notifyListeners();

      return householdId;
    } catch (e) {
      throw Exception('Fehler beim Beitreten des Haushalts: $e');
    }
  }

  /// Erhalte alle Haushaltsmitglieder
  Future<List<Map<String, dynamic>>> getHouseholdMembers(
      String householdId) async {
    try {
      /// Erhalte alle Mitglieder des Haushalts
      final memberIdsResponse = await _client
          .from('household_member')
          .select('member_uid')
          .eq('household_id', householdId)
          .select();

      final List<dynamic> memberIds = memberIdsResponse;

      /// Erhalte alle Profile
      final profilesResponse = await _client
          .from('profiles')
          .select('user_id, username, email')
          .select();

      final List<dynamic> profiles = profilesResponse;

      /// Wähle die Profile aus, die Mitglieder des Haushalts sind
      final userHouseholds = profiles
          .where((profile) => memberIds
              .any((member) => member['member_uid'] == profile['user_id']))
          .map((profile) =>
              {'username': profile['username'], 'email': profile['email']})
          .toList();

      return userHouseholds;
    } catch (e) {
      throw Exception('Fehler beim Laden der Haushaltsmitglieder: $e');
    }
  }

  /// Erhalte die Benutzerrolle im Haushalt
  Future<String> getUserRoleInHousehold(
      String householdId, String userId) async {
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

  /// Verlasse den Haushalt
  Future<void> leaveHousehold(
    String householdId,
    String userId,
  ) async {
    try {
      /// Lösche den Benutzer aus dem Haushalt
      await _client
          .from('household_member')
          .delete()
          .eq('household_id', householdId)
          .eq('member_uid', userId);

      notifyListeners();
    } catch (e) {
      throw Exception('Fehler beim Löschen des Haushalts: $e');
    }
  }

  /// Erhalte Liste von Rezepten
  Future<List<Map<String, dynamic>>> fetchUserRecipes(String userId) async {
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
  }

  /// Füge ein neues Rezept hinzu
  Future<void> addNewRecipe(Map<String, dynamic> recipe) async {
    final userId = _client.auth.currentUser!.id;
    final response = await http.post(
      Uri.parse(_edgeFunctionUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_client.auth.currentSession?.accessToken}',
      },
      body: json.encode({
        'user_id': userId,
        ...recipe,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add recipe');
    }
    notifyListeners();
  }

  /// Aktualisiere ein bestehendes Rezept
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

  /// Lösche ein Rezept
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