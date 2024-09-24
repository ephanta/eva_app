import 'package:auto_route/auto_route.dart';
import 'package:eva_app/provider/data_provider.dart';
import 'package:eva_app/routes/app_router.gr.dart';
import 'package:eva_app/widgets/dialogs/recipe_selection_dialog.dart';
import 'package:flutter/material.dart';

import '../../data/constants.dart';
import '../buttons/custom_text_button.dart';
import '../text/custom_text.dart';

/// {@category Widgets}
/// Dialog um ein Rezept hinzuzufügen
Future<void> addRecipeDialog(
    BuildContext context,
    DataProvider dataProvider,
    List<String> mealTypes,
    Map<String, String> mealTypeLabels,
    DateTime? selectedDay,
    Map<String, Map<String, String?>> wochenplan,
    String householdId) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const CustomText(
          text: "Rezept hinzufügen",
          fontSize: 18,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => recipeSelectionDialog(
                  context,
                  dataProvider,
                  mealTypes,
                  mealTypeLabels,
                  selectedDay,
                  wochenplan,
                  householdId),
              style: Constants.elevatedButtonStyle(),
              child: const Text("Vorhandenes Rezept auswählen"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () =>
                  AutoRouter.of(context).push(const RecipeManagementRoute()),
              style: Constants.elevatedButtonStyle(),
              child: const Text("Zur Rezeptverwaltung"),
            ),
          ],
        ),
        actions: [
          CustomTextButton(
            buttonType: ButtonType.abort,
          ),
        ],
      );
    },
  );
}
