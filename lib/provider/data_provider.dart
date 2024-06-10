import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataProvider with ChangeNotifier {
  final SupabaseClient _client;

  DataProvider(this._client);

  /// Erstelle einen neuen Haushalt
  Future createHousehold(String householdName, String userId) async {
    try {
      /// Füge den Haushalt in die Datenbank ein
      final households = await _client
          .from('households')
          .insert({'name': householdName, 'color': '#FF0000'}).select();

      final data = households as List<dynamic>;
      final householdId = data[0]['id'];

      /// Füge den aktuellen User als Mitglied des Haushalts hinzu
      await _client.from('household_member').insert({
        'household_id': householdId,
        'member_uid': userId,
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

  Future<Map<String, dynamic>> getCurrentHousehold(String householdId) async {
    try {
      final response = await _client
          .from('households')
          .select()
          .eq('id', householdId)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Fehler beim Laden des Haushalts: $e');
    }
  }

  Future<void> updateHousehold(String householdId,
      {String? name, String? color}) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) {
        updateData['name'] = name;
      }
      if (color != null) {
        updateData['color'] = color;
      }
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
}
