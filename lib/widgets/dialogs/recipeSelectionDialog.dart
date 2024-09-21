import 'package:auto_route/auto_route.dart';
import 'package:eva_app/provider/data_provider.dart';
import 'package:flutter/material.dart';

import '../../data/constants.dart';
import '../buttons/custom_text_button.dart';

/// {@category Widgets}
/// Dialog um eine Farbe auszuwählen
Future<void> recipeSelectionDialog(
    BuildContext context,
    DataProvider dataProvider,
    List<String> mealTypes,
    Map<String, String> mealTypeLabels,
    DateTime? selectedDay,
    Map<String, Map<String, String?>> wochenplan,
    String householdId) async {
  try {
    final recipes = await dataProvider.fetchUserRecipes();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedMealType = mealTypes[0];
        Map<String, dynamic>? selectedRecipe;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Rezept auswählen",
                  style: TextStyle(color: Constants.primaryTextColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedMealType,
                    items: mealTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(mealTypeLabels[value]!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMealType = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: recipes.map((recipe) {
                          return ListTile(
                            title: Text(recipe['name'] ?? 'Unbekanntes Rezept'),
                            subtitle: Text(recipe['beschreibung'] ?? ''),
                            onTap: () {
                              setState(() {
                                selectedRecipe = recipe;
                              });
                            },
                            selected: selectedRecipe != null &&
                                selectedRecipe!['id'] == recipe['id'],
                            selectedTileColor: Colors.grey[200],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                CustomTextButton(
                  buttonType: ButtonType.abort,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDay != null && selectedRecipe != null) {
                      try {
                        final currentPlan = wochenplan[
                                selectedDay!.toIso8601String().split('T')[0]] ??
                            {};
                        final updatedMeals = {
                          'fruehstueck_rezept_id':
                              selectedMealType == 'fruehstueck'
                                  ? selectedRecipe!['id']
                                  : currentPlan['fruehstueck_rezept_id'],
                          'mittagessen_rezept_id':
                              selectedMealType == 'mittagessen'
                                  ? selectedRecipe!['id']
                                  : currentPlan['mittagessen_rezept_id'],
                          'abendessen_rezept_id':
                              selectedMealType == 'abendessen'
                                  ? selectedRecipe!['id']
                                  : currentPlan['abendessen_rezept_id'],
                        };

                        if (currentPlan.isEmpty) {
                          await dataProvider.addMealPlan(
                            householdId,
                            selectedDay!.toIso8601String().split('T')[0],
                            updatedMeals['fruehstueck_rezept_id'],
                            updatedMeals['mittagessen_rezept_id'],
                            updatedMeals['abendessen_rezept_id'],
                          );
                        } else {
                          await dataProvider.updateMealPlan(
                            householdId,
                            selectedDay!.toIso8601String().split('T')[0],
                            updatedMeals['fruehstueck_rezept_id'],
                            updatedMeals['mittagessen_rezept_id'],
                            updatedMeals['abendessen_rezept_id'],
                          );
                        } // Refresh the planner with the updated recipe
                        AutoRouter.of(context).maybePop(); // Close the dialog
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Fehler beim Hinzufügen des Rezepts: $e')),
                        );
                      }
                    }
                  },
                  style: Constants.elevatedButtonStyle(),
                  child: const Text("Bestätigen"),
                ),
              ],
            );
          },
        );
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fehler beim Laden der Rezepte: $e')),
    );
  }
}
