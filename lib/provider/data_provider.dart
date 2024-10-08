import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// {@category Provider}
/// DataProvider ist eine Klasse, die die Kommunikation mit der Supabase-API
class DataProvider with ChangeNotifier {
  final SupabaseClient _client;

  // Updated edge function URLs
  final String _recipeEdgeFunctionUrl =
      'https://saxeplastjnaakcyifnn.supabase.co/functions/v1/recipe-management';
  final String _householdEdgeFunctionUrl =
      'https://saxeplastjnaakcyifnn.supabase.co/functions/v1/household-management';
  final String _profileEdgeFunctionUrl =
      'https://saxeplastjnaakcyifnn.supabase.co/functions/v1/profile-management';
  final String _plannerEdgeFunctionUrl =
      'https://saxeplastjnaakcyifnn.supabase.co/functions/v1/planner-management';
  final String _shoppingListEdgeFunctionUrl =
      'https://saxeplastjnaakcyifnn.supabase.co/functions/v1/shopping-management';
  final String _ratingEdgeFunctionUrl =
      'https://saxeplastjnaakcyifnn.supabase.co/functions/v1/bewertung-management';

  DataProvider(this._client);

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<Session?> getCurrentSession() async {
    return _client.auth.currentSession;
  }

  /// Funktion zum Abrufen des Authentifizierungstokens
  Future<String?> _getAuthToken() async {
    final session = _client.auth.currentSession;
    if (session != null) {
      if (session.expiresAt != null) {
        final expirationDate =
            DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
        if (expirationDate
            .isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
          final response = await _client.auth.refreshSession();
          return response.session?.accessToken;
        }
      }
      return session.accessToken;
    }
    return null;
  }

  /// Funktion zum Senden von Anfragen an die Supabase-API
  Future<T> _makeRequest<T>(String url, String method,
      {Map<String, dynamic>? body, Map<String, String>? queryParams}) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    if (kDebugMode) {
      print('Making request to: $url');
    }
    if (kDebugMode) {
      print('Method: $method');
    }
    if (kDebugMode) {
      print('Token: ${token.substring(0, 10)}...');
    }

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
          response =
              await http.post(uri, headers: headers, body: json.encode(body));
          break;
        case 'PUT':
          response =
              await http.put(uri, headers: headers, body: json.encode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        if (kDebugMode) {
          print('Request Success: ${response.statusCode} - $responseData');
        }
        return responseData as T;
      } else {
        if (kDebugMode) {
          print('Request Failed: ${response.statusCode} - ${response.body}');
        }
        throw Exception(
            'Request failed with status: ${response.statusCode}. ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during request: $e');
      }
      throw Exception('Failed to perform request: $e');
    }
  }

  /// Funktion zum Abrufen des Benutzerprofils
  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      return await _makeRequest<Map<String, dynamic>>(
          _profileEdgeFunctionUrl, 'GET');
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Funktion zum Aktualisieren des Benutzerprofils
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      await _makeRequest<Map<String, dynamic>>(_profileEdgeFunctionUrl, 'PUT',
          body: profileData);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Funktion zum Abmelden des Benutzers
  Future<void> signOut() async {
    await _client.auth.signOut();
    notifyListeners();
  }

  /// Funktion zum Aktualisieren der Ernährungshinweise
  Future<void> updateDietaryNotes(String notes) async {
    final body = {
      'hinweise_zur_ernaehrung': notes,
    };

    try {
      if (kDebugMode) {
        print('Sending PUT request with body: $body');
      }
      await _makeRequest<Map<String, dynamic>>(_profileEdgeFunctionUrl, 'PUT',
          body: body);
      if (kDebugMode) {
        print('Dietary notes successfully updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update dietary notes: $e');
      }
      throw Exception('Error updating dietary notes');
    }

    notifyListeners();
  }

  /// Funktion zum Hochladen eines Benutzer-Avatars
  Future<String> uploadAvatar(String imagePath) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final fileName = basename(imagePath);

    final storageResponse = await _client.storage
        .from('avatars')
        .upload('$userId/$fileName', File(imagePath));

    if (storageResponse.error != null) {
      throw Exception(
          'Avatar upload failed: ${storageResponse.error!.message}');
    }

    final publicUrl =
        _client.storage.from('avatars').getPublicUrl('$userId/$fileName');
    if (publicUrl.isEmpty) {
      throw Exception('Failed to retrieve public URL for avatar');
    }

    return publicUrl;
  }

  /// Funktion zum Abrufen der Rezepte des Benutzers
  Future<List<Map<String, dynamic>>> fetchUserRecipes() async {
    final response =
        await _makeRequest<Map<String, dynamic>>(_recipeEdgeFunctionUrl, 'GET');
    if (response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    } else {
      throw Exception('Unexpected response format for recipes');
    }
  }

  /// Funktion zum Abrufen eines Rezepts
  Future<void> addNewRecipe(Map<String, dynamic> recipe) async {
    await _makeRequest<Map<String, dynamic>>(_recipeEdgeFunctionUrl, 'POST',
        body: recipe);
    notifyListeners();
  }

  /// Funktion zum Aktualisieren eines Rezepts
  Future<void> updateRecipe(
      String recipeId, Map<String, dynamic> updatedRecipe) async {
    final token = _client.auth.currentSession?.accessToken;

    if (token == null) throw Exception('User not authenticated');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final uri = Uri.parse('$_recipeEdgeFunctionUrl?id=$recipeId');

    final response = await http.put(
      uri,
      headers: headers,
      body: json.encode(updatedRecipe),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update recipe: ${response.body}');
    }

    notifyListeners();
  }

  /// Funktion zum Löschen eines Rezepts
  Future<void> deleteRecipe(String recipeId) async {
    await _makeRequest<Map<String, dynamic>>(_recipeEdgeFunctionUrl, 'DELETE',
        queryParams: {'id': recipeId});
    notifyListeners();
  }

  /// Funktion zum Abrufen des aktuellen Haushalts
  Future<Map<String, dynamic>> getCurrentHousehold(String householdId) async {
    try {
      final response = await _makeRequest<Map<String, dynamic>>(
        _householdEdgeFunctionUrl,
        'GET',
        queryParams: {
          'household_id': householdId,
          'action': 'get_details',
        },
      );

      if (response.containsKey('data') &&
          response['data'] is Map<String, dynamic>) {
        return response['data'];
      } else {
        if (kDebugMode) {
          print('Unexpected response format from household details');
        }
        return {};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching household details: $e');
      }
      return {};
    }
  }

  /// Funktion zum Abrufen aller Haushalte des Benutzers
  Future<List<Map<String, dynamic>>> fetchUserHouseholds() async {
    final response = await _makeRequest<Map<String, dynamic>>(
      _householdEdgeFunctionUrl,
      'GET',
      queryParams: {'action': 'get_households_by_user'},
    );

    if (response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    } else {
      throw Exception('Unexpected response format for households');
    }
  }

  /// Funktion zum Erstellen eines neuen Haushalts
  Future<Map<String, dynamic>> createHousehold(
      String householdName, String color,
      {String? inviteCode}) async {
    final response = await _makeRequest<Map<String, dynamic>>(
      _householdEdgeFunctionUrl,
      'POST',
      body: {
        'name': householdName,
        'color': color,
        'invite_code':
            inviteCode ?? DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
    notifyListeners();
    return response;
  }

  /// Funktion zum Beitreten eines Haushalts
  Future<Map<String, dynamic>> joinHousehold(String inviteCode) async {
    final response = await _makeRequest<Map<String, dynamic>>(
      _householdEdgeFunctionUrl,
      'POST',
      body: {'action': 'join', 'invite_code': inviteCode},
    );
    notifyListeners();
    return response['data'] ?? {};
  }

  /// Funktion zum Abrufen der Rolle des Benutzers im Haushalt
  Future<String> getUserRoleInHousehold(String householdId) async {
    final response = await _makeRequest<Map<String, dynamic>>(
        _householdEdgeFunctionUrl, 'GET',
        queryParams: {'household_id': householdId, 'action': 'get_role'});
    if (response.containsKey('role')) {
      return response['role'];
    } else {
      throw Exception('Unexpected response format for user role');
    }
  }

  /// Funktion zum Aktualisieren des Haushalts
  Future<Map<String, dynamic>> updateHousehold(String householdId,
      {required String name, required String color}) async {
    final response = await _makeRequest<Map<String, dynamic>>(
      _householdEdgeFunctionUrl,
      'PUT',
      queryParams: {'household_id': householdId},
      body: {'name': name, 'color': color},
    );
    notifyListeners();
    return response;
  }

  /// Funktion zum Löschen eines Haushalts
  Future<void> deleteHousehold(String householdId) async {
    await _makeRequest<Map<String, dynamic>>(
        _householdEdgeFunctionUrl, 'DELETE',
        queryParams: {'household_id': householdId});
    notifyListeners();
  }

  /// Funktion zum Verlassen eines Haushalts
  Future<void> leaveHousehold(String householdId) async {
    await _makeRequest<Map<String, dynamic>>(
      _householdEdgeFunctionUrl,
      'DELETE',
      queryParams: {'household_id': householdId, 'action': 'leave'},
    );
    notifyListeners();
  }

  /// Funktion zum Abrufen der Haushaltsmitglieder
  Future<List<Map<String, dynamic>>> getHouseholdMembers(
      String householdId) async {
    final response = await _makeRequest<Map<String, dynamic>>(
        _householdEdgeFunctionUrl, 'GET',
        queryParams: {'household_id': householdId, 'action': 'get_members'});
    if (response['members'] is List) {
      return List<Map<String, dynamic>>.from(response['members']);
    } else {
      throw Exception('Unexpected response format for household members');
    }
  }

  /// Funktion zum Hinzufügen eines Haushaltsmitglieds
  Future<Map<String, Map<String, String?>>> getWeeklyPlan(
      String householdId) async {
    final response = await _makeRequest<Map<String, dynamic>>(
        _plannerEdgeFunctionUrl, 'GET',
        queryParams: {'household_id': householdId});
    if (response['data'] is Map) {
      return Map<String, Map<String, String?>>.from(response['data'].map(
          (key, value) => MapEntry(key, Map<String, String?>.from(value))));
    } else {
      throw Exception('Unexpected response format for weekly plan');
    }
  }

  /// Funktion zum Löschen eines Speiseplans
  Future<void> deleteMealPlan(String householdId, String date) async {
    await _makeRequest<Map<String, dynamic>>(_plannerEdgeFunctionUrl, 'DELETE',
        queryParams: {'household_id': householdId, 'datum': date});
    notifyListeners();
  }

  /// Funktion zum Hinzufügen eines Speiseplans
  Future<void> addMealPlan(
      String householdId,
      String date,
      String? breakfastRecipeId,
      String? lunchRecipeId,
      String? dinnerRecipeId) async {
    await _makeRequest<Map<String, dynamic>>(
      _plannerEdgeFunctionUrl,
      'POST',
      body: {
        'household_id': householdId,
        'datum': date,
        'fruehstueck_rezept_id': breakfastRecipeId,
        'mittagessen_rezept_id': lunchRecipeId,
        'abendessen_rezept_id': dinnerRecipeId,
      },
    );
    notifyListeners();
  }

  /// Funktion zum Aktualisieren eines Speiseplans
  Future<void> updateMealPlan(
      String householdId,
      String date,
      String? breakfastRecipeId,
      String? lunchRecipeId,
      String? dinnerRecipeId) async {
    await _makeRequest<Map<String, dynamic>>(
      _plannerEdgeFunctionUrl,
      'PUT',
      queryParams: {'household_id': householdId, 'datum': date},
      body: {
        'fruehstueck_rezept_id': breakfastRecipeId,
        'mittagessen_rezept_id': lunchRecipeId,
        'abendessen_rezept_id': dinnerRecipeId,
      },
    );
    notifyListeners();
  }

  /// Funktion zum Abrufen der Einkaufsliste
  Future<List<Map<String, dynamic>>> getShoppingList(String householdId) async {
    final response = await _makeRequest<Map<String, dynamic>>(
        _shoppingListEdgeFunctionUrl, 'GET',
        queryParams: {'household_id': householdId});
    if (response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    } else {
      throw Exception('Unexpected response format for shopping list');
    }
  }

  /// Funktion zum Hinzufügen eines Artikels zur Einkaufsliste
  Future<void> addItemToShoppingList(
      String householdId, String itemName, String? amount) async {
    await _makeRequest<Map<String, dynamic>>(
        _shoppingListEdgeFunctionUrl, 'POST', body: {
      'household_id': householdId,
      'item_name': itemName,
      'amount': amount
    });
    notifyListeners();
  }

  /// Funktion zum Aktualisieren des Status eines Artikels in der Einkaufsliste
  Future<void> updateShoppingItemStatus(String itemId, bool isPurchased) async {
    await _makeRequest<Map<String, dynamic>>(
        _shoppingListEdgeFunctionUrl, 'PUT',
        body: {'id': itemId, 'status': isPurchased ? 'purchased' : 'pending'});
    notifyListeners();
  }

  /// Funktion zum Entfernen eines Artikels aus der Einkaufsliste
  Future<void> removeItemFromShoppingList(String itemId) async {
    await _makeRequest<Map<String, dynamic>>(
        _shoppingListEdgeFunctionUrl, 'DELETE',
        queryParams: {'id': itemId});
    notifyListeners();
  }

  /// Funktion zum Abrufen der Bewertungen eines Rezepts
  Future<List<Map<String, dynamic>>> getRatings(String recipeId) async {
    final response = await _makeRequest<Map<String, dynamic>>(
      _ratingEdgeFunctionUrl,
      'GET',
      queryParams: {'recipe_id': recipeId},
    );
    if (response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    } else {
      throw Exception('Unexpected response format for ratings');
    }
  }

  /// Funktion zum Hinzufügen einer Bewertung
  Future<void> addRating(String recipeId, int rating, String? comment) async {
    try {
      if (kDebugMode) {
        print('Attempting to add rating for recipe: $recipeId');
      }
      final response = await _makeRequest<Map<String, dynamic>>(
        _ratingEdgeFunctionUrl,
        'POST',
        body: {
          'recipe_id': recipeId,
          'rating': rating,
          'comment': comment,
        },
      );
      if (kDebugMode) {
        print('Rating added successfully: $response');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding rating: $e');
      }
      throw Exception('Failed to add rating: $e');
    }
  }

  /// Funktion zum Aktualisieren einer Bewertung
  Future<void> updateRating(
      String ratingId, int rating, String? comment) async {
    await _makeRequest<Map<String, dynamic>>(
      _ratingEdgeFunctionUrl,
      'PUT',
      body: {
        'id': ratingId,
        'rating': rating,
        'comment': comment,
      },
    );
    notifyListeners();
  }

  /// Funktion zum Löschen einer Bewertung
  Future<void> deleteRating(String ratingId) async {
    await _makeRequest<Map<String, dynamic>>(
      _ratingEdgeFunctionUrl,
      'DELETE',
      queryParams: {'id': ratingId},
    );
    notifyListeners();
  }

  /// Funktion zum Abrufen der Bewertungen des Benutzers
  Future<List<Map<String, dynamic>>> getUserRatings() async {
    try {
      final response = await _makeRequest<Map<String, dynamic>>(
        _ratingEdgeFunctionUrl,
        'GET',
        queryParams: {'action': 'get_user_ratings'},
      );
      if (response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        if (kDebugMode) {
          print('Unexpected response format for user ratings: $response');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user ratings: $e');
      }
      return [];
    }
  }
}

extension on String {
  get error => null;
}
