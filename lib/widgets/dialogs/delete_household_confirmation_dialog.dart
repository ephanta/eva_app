import 'package:auto_route/auto_route.dart';
import 'package:eva_app/widgets/dialogs/show_error_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/data_provider.dart';
import '../../routes/app_router.gr.dart';
import '../buttons/custom_text_button.dart';

/// {@category Widgets}
/// Dialog um einen Haushalt zu löschen
Future<void> deleteHouseholdConfirmationDialog(
    BuildContext context, Map<String, dynamic> household) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Haushalt löschen'),
        content: const Text(
            'Sind Sie sicher, dass Sie diesen Haushalt löschen möchten?'),
        actions: <Widget>[
          CustomTextButton(
            buttonType: ButtonType.abort,
          ),
          TextButton(
            child: const Text('Löschen'),
            onPressed: () async {
              final dataProvider =
                  Provider.of<DataProvider>(context, listen: false);
              try {
                await dataProvider.deleteHousehold(household['id'].toString());
                AutoRouter.of(context).maybePop();
                AutoRouter.of(context).replace(const HomeRoute());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Haushalt erfolgreich gelöscht.')),
                );
              } catch (e) {
                AutoRouter.of(context).maybePop();
                showErrorSnackBar(
                    context, 'Fehler beim Löschen des Haushalts: $e');
              }
            },
          ),
        ],
      );
    },
  );
}
