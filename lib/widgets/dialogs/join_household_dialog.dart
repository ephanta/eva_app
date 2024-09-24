import 'package:auto_route/auto_route.dart';
import 'package:eva_app/provider/data_provider.dart';
import 'package:flutter/material.dart';

import '../../data/constants.dart';
import '../../routes/app_router.gr.dart';
import '../buttons/custom_text_button.dart';

/// {@category Widgets}
/// Dialog um einem Haushalt beizutreten
Future<void> joinHouseholdDialog(
    BuildContext context, DataProvider dataProvider) async {
  final TextEditingController inviteCodeController = TextEditingController();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Haushalt beitreten'),
        content: TextField(
          controller: inviteCodeController,
          decoration: const InputDecoration(
            labelText: 'Einladungscode',
          ),
        ),
        actions: <Widget>[
          CustomTextButton(
            buttonType: ButtonType.abort,
          ),
          ElevatedButton(
            style: Constants.elevatedButtonStyle(),
            child: const Text('Beitreten'),
            onPressed: () async {
              final inviteCode = inviteCodeController.text;

              if (inviteCode.isNotEmpty) {
                try {
                  final result = await dataProvider.joinHousehold(inviteCode);
                  final householdId = result['household_id'];

                  // Fetch household data and user role
                  final householdData =
                      await dataProvider.getCurrentHousehold(householdId);
                  final userRole =
                      await dataProvider.getUserRoleInHousehold(householdId);

                  AutoRouter.of(context).maybePop();
                  AutoRouter.of(context).push(
                    HomeDetailRoute(
                      householdId: householdId,
                      preloadedHouseholdData: householdData,
                      preloadedUserRole: userRole,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Erfolgreich dem Haushalt beigetreten.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Fehler beim Beitreten des Haushalts: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Bitte geben Sie einen Einladungscode ein')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
