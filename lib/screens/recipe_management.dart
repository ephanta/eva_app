import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../provider/data_provider.dart';

@RoutePage()
class RecipeManagementScreen extends StatefulWidget {
  const RecipeManagementScreen({super.key});

  @override
  State<RecipeManagementScreen> createState() => _RecipeManagementScreenState();
}

class _RecipeManagementScreenState extends State<RecipeManagementScreen> {
  List<Map<String, dynamic>> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadUserRecipes();
  }

  Future<void> _loadUserRecipes() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final userId = dataProvider.currentUserId;
    try {
      final recipes = await dataProvider.fetchUserRecipes(userId);
      setState(() {
        _recipes = recipes;
      });
    } catch (e) {
      print('Error loading recipes: $e');
    }
  }

  void _addNewRecipe() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    Map<String, dynamic>? newRecipe = await _showRecipeForm(context, isEditing: false);
    if (newRecipe != null) {
      try {
        await dataProvider.addNewRecipe(newRecipe);
        _loadUserRecipes();  // Reload recipes after adding
      } catch (e) {
        print('Error adding recipe: $e');
      }
    }
  }

  void _editRecipe(int index) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    Map<String, dynamic>? updatedRecipe = await _showRecipeForm(context, recipe: _recipes[index], isEditing: true);
    if (updatedRecipe != null) {
      try {
        await dataProvider.updateRecipe(_recipes[index]['id'], updatedRecipe);
        _loadUserRecipes();  // Reload recipes after updating
      } catch (e) {
        print('Error updating recipe: $e');
      }
    }
  }

  void _deleteRecipe(int index) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.deleteRecipe(_recipes[index]['id']);
      _loadUserRecipes();  // Reload recipes after deleting
    } catch (e) {
      print('Error deleting recipe: $e');
    }
  }

  Future<Map<String, dynamic>?> _showRecipeForm(BuildContext context, {Map<String, dynamic>? recipe, bool isEditing = false}) async {
    TextEditingController nameController = TextEditingController(text: recipe?['name'] ?? '');
    TextEditingController descriptionController = TextEditingController(text: recipe?['beschreibung'] ?? '');
    TextEditingController instructionsController = TextEditingController(text: recipe?['kochanweisungen'] ?? '');
    List<Map<String, String>> ingredients = List<Map<String, String>>.from(recipe?['zutaten'] ?? []);

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Rezept bearbeiten' : 'Rezept hinzufügen'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Rezeptname'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Beschreibung'),
                ),
                const SizedBox(height: 10),
                const Text('Zutaten', style: TextStyle(fontWeight: FontWeight.bold)),
                Column(
                  children: ingredients.map((ingredient) {
                    return ListTile(
                      title: Text(ingredient['name'] ?? ''),
                      subtitle: Text('Menge: ${ingredient['menge']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            ingredients.remove(ingredient);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Zutat hinzufügen'),
                  onPressed: () async {
                    Map<String, String>? newIngredient = await _showAddIngredientDialog(context);
                    if (newIngredient != null) {
                      setState(() {
                        ingredients.add(newIngredient);
                      });
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: instructionsController,
                  decoration: const InputDecoration(labelText: 'Kochanweisungen'),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'beschreibung': descriptionController.text,
                  'zutaten': ingredients,
                  'kochanweisungen': instructionsController.text,
                });
              },
              child: Text(isEditing ? 'Aktualisieren' : 'Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, String>?> _showAddIngredientDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Zutat hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Zutatenname'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Menge'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'menge': quantityController.text,
                });
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  // Keep _showRecipeForm and _showAddIngredientDialog as they are

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        showArrow: true,
        showHome: true,
        showProfile: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meine Rezepte',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _recipes.isEmpty
                ? const Center(child: Text('Keine Rezepte vorhanden.'))
                : Expanded(
              child: ListView.builder(
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  return _buildRecipeCard(index);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRecipe,
        backgroundColor: const Color(0xFFFDD9CF),
        child: const Icon(Icons.add, color: Color(0xFF3A0B01)),
      ),
    );
  }

  Widget _buildRecipeCard(int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFFDD9CF),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: Text(
          _recipes[index]['name'] ?? '',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3A0B01)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_recipes[index]['beschreibung'] ?? '', style: const TextStyle(color: Color(0xFF3A0B01))),
            const SizedBox(height: 8),
            const Text('Zutaten:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...(_recipes[index]['zutaten'] as List).map((ingredient) {
              return Text('${ingredient['name']} - ${ingredient['menge']}', style: const TextStyle(color: Color(0xFF3A0B01)));
            }).toList(),
            const SizedBox(height: 8),
            const Text('Kochanweisungen:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_recipes[index]['kochanweisungen'] ?? '', style: const TextStyle(color: Color(0xFF3A0B01))),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF3A0B01)),
              onPressed: () => _editRecipe(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF3A0B01)),
              onPressed: () => _deleteRecipe(index),
            ),
          ],
        ),
      ),
    );
  }
}