import 'package:supabase_flutter/supabase_flutter.dart';

class DataProvider {
  final SupabaseClient _client;

  DataProvider(this._client);

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

      return householdId;
    } catch (e) {
      throw Exception('Fehler beim Erstellen des Haushalts: $e');
    }
  }

  Future<List<dynamic>> fetchUserHouseholds(String userId) async {
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
  }

  Future<Map<String, dynamic>> getCurrentHousehold(String householdId) async {
    final response = await _client
        .from('households')
        .select()
        .eq('id', householdId)
        .single();

    if (response == null) {
      throw Exception('Haushalt nicht gefunden.');
    }

    return response as Map<String, dynamic>;
  }

  Future<void> updateHousehold(String householdId,
      {String? name, String? color}) async {
    final updateData = <String, dynamic>{};

    if (name != null) {
      updateData['name'] = name;
    }
    if (color != null) {
      updateData['color'] = color;
    }

    try {
      await _client.from('households').update(updateData).eq('id', householdId);
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren des Haushalts: $e');
    }
  }

  Future<void> deleteHousehold(String householdId) async {
    try {
      await _client
          .from('household_member')
          .delete()
          .eq('household_id', householdId);
      await _client.from('households').delete().eq('id', householdId);
    } catch (e) {
      throw Exception('Fehler beim Löschen des Haushalts: $e');
    }
  }
}
