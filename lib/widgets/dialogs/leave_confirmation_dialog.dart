import 'package:auto_route/auto_route.dart';
import 'package:eva_app/widgets/dialogs/show_error_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';
import '../../routes/app_router.gr.dart';
import '../buttons/custom_text_button.dart';

/// {@category Widgets}
/// Dialog zum Bestätigen des Verlassens eines Haushalts
Future<void> leaveConfirmationDialog(
    BuildContext context, String householdId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Haushalt verlassen'),
        content: const Text(
            'Sind Sie sicher, dass Sie diesen Haushalt verlassen möchten?'),
        actions: <Widget>[
          CustomTextButton(
            buttonType: ButtonType.abort,
          ),
          CustomTextButton(
            buttonText: 'Verlassen',
            onPressed: () async {
              final dataProvider =
                  Provider.of<DataProvider>(context, listen: false);
              try {
                await dataProvider.leaveHousehold(householdId);
                AutoRouter.of(context).maybePop();
                AutoRouter.of(context).replace(const HomeRoute());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Haushalt erfolgreich verlassen.')),
                );
              } catch (e) {
                AutoRouter.of(context).maybePop();
                showErrorSnackBar(
                    context, 'Fehler beim Verlassen des Haushalts: $e');
              }
            },
          ),
        ],
      );
    },
  );
}
