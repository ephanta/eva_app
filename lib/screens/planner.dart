import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:eva_app/provider/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/navigation/app_bar_custom.dart';

/// {@category Screens}
/// Ansicht für den Wochenplaner
@RoutePage()
class PlannerScreen extends StatefulWidget {
  final int householdId;
  const PlannerScreen({Key? key, required this.householdId})
      : super(key: key);


  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

/// Der Zustand für die Wochenplan-Seite
class _PlannerScreenState extends State<PlannerScreen> {

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
          showArrow: true, showHome: true, showProfile: true),
      body: Consumer<DataProvider>(builder: (context, dataProvider, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future:
          dataProvider.getCurrentHousehold(widget.householdId.toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const Text('Keine Daten gefunden.');
            } else {
              final household = snapshot.data!;
              Color householdColor = Color(
                  int.parse(household['color'].substring(1, 7), radix: 16) +
                      0xFF000000);
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Wochenplaner',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: CalendarFormat.week,  // Setzt das Kalenderformat auf Woche
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      availableCalendarFormats: const {
                        CalendarFormat.week: 'Woche',  // Nur Wochenansicht zulassen
                      },
                    ),
                    SizedBox(height: 20),
                    if (_selectedDay != null)
                      Text("Gewählter Tag: ${_selectedDay!.toLocal()}"),
                  ],
                ),
              );
            }
          },
        );
      }),
    );
  }
}

