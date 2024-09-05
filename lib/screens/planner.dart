import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../model/recipe.dart';

/// {@category Screens}
/// Ansicht für den Wochenplaner
@RoutePage()
class PlannerScreen extends StatefulWidget {
  final int householdId;
  const PlannerScreen({Key? key, required this.householdId}) : super(key: key);

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

/// Der Zustand für die Wochenplan-Seite
class _PlannerScreenState extends State<PlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, Rezept> wochenplan = {};

  @override
  void initState() {
    super.initState();

    DateTime heute = DateTime.now();

    // Beispiel-Rezepte hinzufügen
    wochenplan[heute] = Rezept(
      name: 'Spaghetti Carbonara',
      beschreibung: 'Ein klassisches italienisches Gericht mit Speck und Ei.',
      zutaten: ['Spaghetti', 'Speck', 'Eier', 'Parmesan', 'Pfeffer'],
    );

    wochenplan[heute.add(Duration(days: 1))] = Rezept(
      name: 'Hähnchensalat',
      beschreibung: 'Ein leichter Salat mit Hähnchenbrust und Gemüse.',
      zutaten: ['Hähnchenbrust', 'Salat', 'Tomaten', 'Gurken', 'Dressing'],
    );
  }

  void _addRecipeDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _ingredientsController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rezept hinzufügen"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Rezeptname'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Beschreibung'),
                ),
                TextField(
                  controller: _ingredientsController,
                  decoration: InputDecoration(labelText: 'Zutaten (kommagetrennt)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Abbrechen"),
            ),
            TextButton(
              onPressed: () {
                if (_selectedDay != null) {
                  setState(() {
                    wochenplan[_selectedDay!] = Rezept(
                      name: _nameController.text,
                      beschreibung: _descriptionController.text,
                      zutaten: _ingredientsController.text.split(','),
                    );
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text("Hinzufügen"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        showArrow: true,
        showHome: true,
        showProfile: true,
      ),
      body: Center(
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
              calendarFormat: CalendarFormat.week,
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
                CalendarFormat.week: 'Woche',
              },
            ),
            SizedBox(height: 20),
            if (_selectedDay != null && wochenplan[_selectedDay!] != null)
              _zeigeRezept(wochenplan[_selectedDay!]!),
            if (_selectedDay != null && wochenplan[_selectedDay!] == null)
              Text("Kein Rezept für diesen Tag."),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addRecipe',
        onPressed: () => _addRecipeDialog(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Verlagerung nach unten rechts
    );
  }

  Widget _zeigeRezept(Rezept rezept) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rezept.name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(rezept.beschreibung),
        SizedBox(height: 10),
        Text(
          "Zutaten:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        for (String zutat in rezept.zutaten) Text("- $zutat"),
      ],
    );
  }
}
