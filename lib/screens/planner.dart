import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../provider/data_provider.dart';
import '../routes/app_router.gr.dart';

@RoutePage()
class PlannerScreen extends StatefulWidget {
  final String householdId;
  const PlannerScreen({Key? key, required this.householdId}) : super(key: key);

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late DataProvider _dataProvider;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, Map<String, String?>> _wochenplan = {};
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = true;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  final List<String> _mealTypes = ['fruehstueck', 'mittagessen', 'abendessen'];
  final Map<String, String> _mealTypeLabels = {
    'fruehstueck': 'Frühstück',
    'mittagessen': 'Mittagessen',
    'abendessen': 'Abendessen',
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _dataProvider = Provider.of<DataProvider>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final wochenplan = await _dataProvider.getWeeklyPlan(widget.householdId);
      final recipes = await _dataProvider.fetchUserRecipes();
      setState(() {
        _wochenplan = wochenplan;
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Daten: $e')),
      );
    }
  }

  void _showAddRecipeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rezept hinzufügen"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _showRecipeSelectionDialog(context),
                child: Text("Vorhandenes Rezept auswählen"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _navigateToRecipeCreation(context),
                child: Text("Neues Rezept erstellen"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Abbrechen"),
            ),
          ],
        );
      },
    );
  }

  void _showRecipeSelectionDialog(BuildContext context) async {
    try {
      final recipes = await _dataProvider.fetchUserRecipes();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          String selectedMealType = _mealTypes[0];
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Rezept auswählen"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: selectedMealType,
                      items: _mealTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(_mealTypeLabels[value]!),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedMealType = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: recipes.map((recipe) {
                            return ListTile(
                              title: Text(recipe['name'] ?? 'Unbekanntes Rezept'),
                              subtitle: Text(recipe['beschreibung'] ?? ''),
                              onTap: () async {
                                if (_selectedDay != null) {
                                  try {
                                    await _dataProvider.addOrUpdateMealPlan(
                                      widget.householdId,
                                      _selectedDay!.toIso8601String(),
                                      selectedMealType == 'fruehstueck' ? recipe['id'] : null,
                                      selectedMealType == 'mittagessen' ? recipe['id'] : null,
                                      selectedMealType == 'abendessen' ? recipe['id'] : null,
                                    );
                                    await _loadData(); // Refresh after selecting recipe
                                    Navigator.of(context).pop(); // Close the dialog
                                  } catch (e) {
                                    print('Error adding recipe: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Fehler beim Hinzufügen des Rezepts: $e')),
                                    );
                                  }
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
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
        },
      );
    } catch (e) {
      print('Error fetching recipes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Rezepte: $e')),
      );
    }
  }

  void _navigateToRecipeCreation(BuildContext context) {
    AutoRouter.of(context).push(RecipeManagementRoute()).then((_) {
      _loadData();
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        showArrow: true,
        showHome: true,
        showProfile: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Wochenplaner',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          TableCalendar(
            locale: 'de_DE',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay,) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFFFDB49F),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFFFDD9CF),
                shape: BoxShape.circle,
              ),
            ),
            availableCalendarFormats: {
              CalendarFormat.week: 'Woche',
              CalendarFormat.month: 'Monat',
            },
          ),
          SizedBox(height: 20),
          Expanded(
            child: _selectedDay != null
                ? _wochenplan.containsKey(_selectedDay!.toIso8601String())
                ? _zeigeTagesplan(_wochenplan[_selectedDay!.toIso8601String()]!)
                : Center(child: Text("Keine Rezepte für diesen Tag."))
                : Center(child: Text("Bitte wählen Sie einen Tag aus.")),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addRecipe',
        onPressed: () => _showAddRecipeDialog(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _zeigeTagesplan(Map<String, String?> tagesplan) {
    return ListView.builder(
      itemCount: _mealTypes.length,
      itemBuilder: (context, index) {
        final mealType = _mealTypes[index];
        final recipeId = tagesplan['${mealType}_rezept_id'];
        return _zeigeRezept(mealType, recipeId != null ? _getRecipeById(recipeId) : null);
      },
    );
  }

  Map<String, dynamic>? _getRecipeById(String recipeId) {
    return _recipes.firstWhere(
          (recipe) => recipe['id'] == recipeId,
      orElse: () => {'id': '', 'name': 'Unbekanntes Rezept', 'beschreibung': '', 'zutaten': []},
    );
  }

  Widget _zeigeRezept(String mealType, Map<String, dynamic>? recipe) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _mealTypeLabels[mealType]!,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (recipe != null) ...[
              Text(
                recipe['name'] ?? 'Unbekanntes Rezept',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(recipe['beschreibung'] ?? ''),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedDay != null) {
                    try {
                      await _dataProvider.addOrUpdateMealPlan(
                        widget.householdId,
                        _selectedDay!.toIso8601String(),
                        mealType == 'fruehstueck' ? null : _wochenplan[_selectedDay!.toIso8601String()]!['fruehstueck_rezept_id'],
                        mealType == 'mittagessen' ? null : _wochenplan[_selectedDay!.toIso8601String()]!['mittagessen_rezept_id'],
                        mealType == 'abendessen' ? null : _wochenplan[_selectedDay!.toIso8601String()]!['abendessen_rezept_id'],
                      );
                      await _loadData();
                    } catch (e) {
                      print('Error removing recipe: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fehler beim Entfernen des Rezepts: $e')),
                      );
                    }
                  }
                },
                child: Text("Rezept entfernen"),
              ),
            ] else
              Text("Kein Rezept ausgewählt"),
          ],
        ),
      ),
    );
  }
}