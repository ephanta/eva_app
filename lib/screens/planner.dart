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
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Daten: $e')),
      );
    }
  }

  Future<void> _removeRecipeFromPlan(String mealType) async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kein Tag ausgewählt")),
      );
      return;
    }

    final selectedDate = _selectedDay!.toIso8601String().split('T')[0];

    try {
      final currentPlan = _wochenplan[selectedDate] ?? {};
      final updatedMeals = {
        'fruehstueck_rezept_id': mealType == 'fruehstueck' ? null : currentPlan['fruehstueck_rezept_id'],
        'mittagessen_rezept_id': mealType == 'mittagessen' ? null : currentPlan['mittagessen_rezept_id'],
        'abendessen_rezept_id': mealType == 'abendessen' ? null : currentPlan['abendessen_rezept_id'],
      };

      await _dataProvider.updateMealPlan(
        widget.householdId,
        selectedDate,
        updatedMeals['fruehstueck_rezept_id'],
        updatedMeals['mittagessen_rezept_id'],
        updatedMeals['abendessen_rezept_id'],
      );

      setState(() {
        _wochenplan[selectedDate] = updatedMeals;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezept erfolgreich entfernt')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Entfernen des Rezepts: $e')),
      );
    }
  }

  void _showAddRecipeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Rezept hinzufügen",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3A0B01)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _showRecipeSelectionDialog(context),
                child: const Text("Vorhandenes Rezept auswählen"),
                style: _elevatedButtonStyle(),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _navigateToRecipeCreation(context),
                child: const Text("Neues Rezept erstellen"),
                style: _elevatedButtonStyle(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Abbrechen"),
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
          Map<String, dynamic>? selectedRecipe;

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Rezept auswählen", style: TextStyle(color: Color(0xFF3A0B01))),
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
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Abbrechen"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedDay != null && selectedRecipe != null) {
                        try {
                          final currentPlan = _wochenplan[_selectedDay!.toIso8601String().split('T')[0]] ?? {};
                          final updatedMeals = {
                            'fruehstueck_rezept_id': selectedMealType == 'fruehstueck' ? selectedRecipe!['id'] : currentPlan['fruehstueck_rezept_id'],
                            'mittagessen_rezept_id': selectedMealType == 'mittagessen' ? selectedRecipe!['id'] : currentPlan['mittagessen_rezept_id'],
                            'abendessen_rezept_id': selectedMealType == 'abendessen' ? selectedRecipe!['id'] : currentPlan['abendessen_rezept_id'],
                          };

                          if (currentPlan.isEmpty) {
                            await _dataProvider.addMealPlan(
                              widget.householdId,
                              _selectedDay!.toIso8601String().split('T')[0],
                              updatedMeals['fruehstueck_rezept_id'],
                              updatedMeals['mittagessen_rezept_id'],
                              updatedMeals['abendessen_rezept_id'],
                            );
                          } else {
                            await _dataProvider.updateMealPlan(
                              widget.householdId,
                              _selectedDay!.toIso8601String().split('T')[0],
                              updatedMeals['fruehstueck_rezept_id'],
                              updatedMeals['mittagessen_rezept_id'],
                              updatedMeals['abendessen_rezept_id'],
                            );
                          }
                          await _loadData(); // Refresh the planner with the updated recipe
                          Navigator.of(context).pop(); // Close the dialog
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Fehler beim Hinzufügen des Rezepts: $e')),
                          );
                        }
                      }
                    },
                    child: const Text("Bestätigen"),
                    style: _elevatedButtonStyle(),
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

  void _showRatingDialog(Map<String, dynamic> recipe) {
    int rating = 0; // Initial rating value
    String comment = ''; // Initial comment value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Bewerte ${recipe['name']}',
                style: const TextStyle(color: Color(0xFF3A0B01), fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Kommentar'),
                    onChanged: (value) => comment = value,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Abbrechen'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Bewertung abgeben'),
                  style: _elevatedButtonStyle(),
                  onPressed: () async {
                    try {
                      await _dataProvider.addRating(recipe['id'], rating, comment);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bewertung erfolgreich abgegeben')),
                      );
                    } catch (e) {
                      print('Error adding rating: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fehler beim Abgeben der Bewertung: $e')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToRecipeCreation(BuildContext context) {
    context.router.push(RecipeManagementRoute()).then((_) {
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
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: <Widget>[
          // Title Styling
          Container(
            color: const Color(0xFFFDF6F4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: Text(
                'Wochenplaner',
                style: TextStyle(
                  fontSize: 22, // Consistent title size
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A0B01), // Consistent title color
                ),
              ),
            ),
          ),
          TableCalendar(
            locale: 'de_DE',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
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
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFFFDB49F),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFFFDD9CF),
                shape: BoxShape.circle,
              ),
            ),
            availableCalendarFormats: const {
              CalendarFormat.week: 'Woche',
              CalendarFormat.month: 'Monat',
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _selectedDay != null
                ? _wochenplan.containsKey(_selectedDay!.toIso8601String().split('T')[0])
                ? _zeigeTagesplan(_wochenplan[_selectedDay!.toIso8601String().split('T')[0]]!)
                : const Center(child: Text("Keine Rezepte für diesen Tag."))
                : const Center(child: Text("Bitte wählen Sie einen Tag aus.")),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addRecipe',
        onPressed: () => _showAddRecipeDialog(context),
        backgroundColor: const Color(0xFFFDD9CF),
        child: const Icon(Icons.add, color: Color(0xFF3A0B01)),
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
        return _zeigeRezept(
            mealType, recipeId != null ? _getRecipeById(recipeId) : null);
      },
    );
  }

  Map<String, dynamic>? _getRecipeById(String recipeId) {
    return _recipes.firstWhere(
          (recipe) => recipe['id'] == recipeId,
      orElse: () => {
        'id': '',
        'name': 'Unbekanntes Rezept',
        'beschreibung': '',
        'zutaten': []
      },
    );
  }

  Widget _zeigeRezept(String mealType, Map<String, dynamic>? recipe) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFFDD9CF),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _mealTypeLabels[mealType]!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3A0B01)),
            ),
            const SizedBox(height: 10),
            if (recipe != null) ...[
              Text(
                recipe['name'] ?? 'Unbekanntes Rezept',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3A0B01)),
              ),
              const SizedBox(height: 5),
              Text(recipe['beschreibung'] ?? ''),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _removeRecipeFromPlan(mealType); // Call this to handle removal
                    },
                    child: const Text("Rezept entfernen"),
                    style: _elevatedButtonStyle(),
                  ),
                  ElevatedButton(
                    onPressed: () => _showRatingDialog(recipe),
                    child: const Text("Bewerten"),
                    style: _elevatedButtonStyle(),
                  ),
                ],
              ),
            ] else
              const Text("Kein Rezept ausgewählt"),
          ],
        ),
      ),
    );
  }

  ButtonStyle _elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFECE7),
      foregroundColor: const Color(0xFF3A0B01),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      minimumSize: const Size(120, 40),
    );
  }
}
