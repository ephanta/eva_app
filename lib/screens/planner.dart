import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../data/constants.dart';
import '../provider/data_provider.dart';
import '../widgets/buttons/custom_text_button.dart';
import '../widgets/dialogs/add_recipe_dialog.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/text/custom_text.dart';

/// {@category Screens}
/// Ansicht für den Wochenplaner
@RoutePage()
class PlannerScreen extends StatefulWidget {
  final String householdId;

  const PlannerScreen({Key? key, required this.householdId}) : super(key: key);

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

/// Der Zustand für den Wochenplaner
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
                style: const TextStyle(
                    color: Constants.primaryTextColor,
                    fontWeight: FontWeight.bold),
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
                CustomTextButton(
                  buttonType: ButtonType.abort,
                ),
                ElevatedButton(
                  style: Constants.elevatedButtonStyle(),
                  onPressed: () async {
                    try {
                      await _dataProvider.addRating(
                          recipe['id'], rating, comment);
                      AutoRouter.of(context).maybePop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Bewertung erfolgreich abgegeben')),
                      );
                    } catch (e) {
                      if (kDebugMode) {
                        print('Error adding rating: $e');
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Fehler beim Abgeben der Bewertung: $e')),
                      );
                    }
                  },
                  child: const Text('Bewertung abgeben'),
                ),
              ],
            );
          },
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                // Title Styling
                Container(
                  color: Constants.secondaryBackgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Center(
                    child: CustomText(text: 'Wochenplaner'),
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
                      color: Constants.primaryBackgroundColor,
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
                      ? _wochenplan.containsKey(
                              _selectedDay!.toIso8601String().split('T')[0])
                          ? _zeigeTagesplan(_wochenplan[
                              _selectedDay!.toIso8601String().split('T')[0]]!)
                          : const Center(
                              child: Text("Keine Rezepte für diesen Tag."))
                      : const Center(
                          child: Text("Bitte wählen Sie einen Tag aus.")),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addRecipe',
        onPressed: () => addRecipeDialog(context, _dataProvider, _mealTypes,
            _mealTypeLabels, _selectedDay, _wochenplan, widget.householdId),
        backgroundColor: Constants.primaryBackgroundColor,
        child: const Icon(Icons.add, color: Constants.primaryTextColor),
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
      color: Constants.primaryBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: _mealTypeLabels[mealType]!,
              fontSize: 18,
            ),
            const SizedBox(height: 10),
            if (recipe != null) ...[
              CustomText(
                text: recipe['name'] ?? 'Unbekanntes Rezept',
                fontSize: 16,
              ),
              const SizedBox(height: 5),
              Text(recipe['beschreibung'] ?? ''),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _removeRecipe(mealType),
                    style: Constants.elevatedButtonStyle(),
                    child: const Text("Rezept entfernen"),
                  ),
                  ElevatedButton(
                    onPressed: () => _showRatingDialog(recipe),
                    style: Constants.elevatedButtonStyle(),
                    child: const Text("Bewerten"),
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

  void _removeRecipe(String mealType) async {
    if (_selectedDay == null) return;

    final date = _selectedDay!.toIso8601String().split('T')[0];
    final currentPlan = _wochenplan[date] ?? {};

    // Create a copy of the current plan and set the specific meal to null
    final updatedMeals = Map<String, String?>.from(currentPlan);
    updatedMeals['${mealType}_rezept_id'] = null;

    try {
      await _dataProvider.updateMealPlan(
        widget.householdId,
        date,
        updatedMeals['fruehstueck_rezept_id'],
        updatedMeals['mittagessen_rezept_id'],
        updatedMeals['abendessen_rezept_id'],
      );
      await _loadData(); // Refresh the planner
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezept erfolgreich entfernt')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Entfernen des Rezepts: $e')),
      );
    }
  }
}
