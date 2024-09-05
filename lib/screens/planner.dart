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
  List<Rezept> rezepte = [];

  @override
  void initState() {
    super.initState();

    DateTime heute = DateTime.now();

    // Beispiel-Rezepte hinzufügen
    rezepte = [
      Rezept(
        rezeptID: '1',
        name: 'Spaghetti Carbonara',
        beschreibung: 'Ein klassisches italienisches Gericht mit Speck und Ei.',
        zutaten: ['Spaghetti', 'Speck', 'Eier', 'Parmesan', 'Pfeffer'],
      ),
      Rezept(
        rezeptID: '2',
        name: 'Hähnchensalat',
        beschreibung: 'Ein leichter Salat mit Hähnchenbrust und Gemüse.',
        zutaten: ['Hähnchenbrust', 'Salat', 'Tomaten', 'Gurken', 'Dressing'],
      ),
      Rezept(
        rezeptID: '3',
        name: 'Lasagne',
        beschreibung: 'Ein reichhaltiges Gericht mit Fleisch, Käse und Pasta.',
        zutaten: ['Hackfleisch', 'Tomaten', 'Lasagneblätter', 'Käse', 'Béchamelsoße'],
      ),
      Rezept(
        rezeptID: '4',
        name: 'Gemüsepfanne',
        beschreibung: 'Eine bunte Gemüsepfanne mit verschiedenen Gewürzen.',
        zutaten: ['Paprika', 'Zucchini', 'Aubergine', 'Zwiebeln', 'Knoblauch'],
      ),
      Rezept(
        rezeptID: '5',
        name: 'Pizza Margherita',
        beschreibung: 'Eine klassische Pizza mit Tomaten, Basilikum und Mozzarella.',
        zutaten: ['Pizzateig', 'Tomaten', 'Mozzarella', 'Basilikum', 'Olivenöl'],
      ),
    ];

    // Beispiel-Rezepte für den Wochenplan
    wochenplan[heute] = rezepte[0];
    wochenplan[heute.add(Duration(days: 1))] = rezepte[1];
  }

  void _addRecipeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rezept auswählen"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: rezepte.map((rezept) {
                return ListTile(
                  title: Text(rezept.name),
                  subtitle: Text(rezept.beschreibung),
                  onTap: () {
                    if (_selectedDay != null) {
                      setState(() {
                        wochenplan[_selectedDay!] = rezept;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Abbrechen"),
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
            SizedBox(height: 30),
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
