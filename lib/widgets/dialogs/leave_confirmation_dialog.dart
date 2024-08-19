import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../../provider/data_provider.dart';
import '../../routes/app_router.gr.dart';

Future<void> showLeaveConfirmationDialog(
    BuildContext context, int householdId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Haushalt verlassen'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'Sind Sie sicher, dass Sie diesen Haushalt verlassen möchten?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () {
              AutoRouter.of(context).maybePop();
            },
          ),
          TextButton(
            child: const Text('Verlassen'),
            onPressed: () async {
              final dataProvider =
                  Provider.of<DataProvider>(context, listen: false);
              final userId = Supabase.instance.client.auth.currentUser!.id;
              try {
                await dataProvider.leaveHousehold(
                    householdId.toString(), userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Haushalt verlassen')),
                );
                AutoRouter.of(context).maybePop();
                AutoRouter.of(context).push(const HomeRoute());
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Fehler beim Verlassen des Haushalts: $e')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
