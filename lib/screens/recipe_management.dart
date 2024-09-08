import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../widgets/navigation/app_bar_custom.dart';  // Custom app bar

/// {@category Screens}
/// Recipe Management Screen where users can add, edit, delete their recipes
@RoutePage()
class RecipeManagementScreen extends StatefulWidget {
  const RecipeManagementScreen({super.key});

  @override
  State<RecipeManagementScreen> createState() => _RecipeManagementScreenState();
}

class _RecipeManagementScreenState extends State<RecipeManagementScreen> {
  List<Map<String, dynamic>> _recipes = [];  // Recipes with ingredients

  @override
  void initState() {
    super.initState();
    _loadUserRecipes();  // Load user recipes when the screen initializes
  }

  // Simulate loading recipes (you'll replace this with actual API calls)
  Future<void> _loadUserRecipes() async {
    setState(() {
      _recipes = [
        {
          'name': 'Pasta',
          'description': 'Delicious homemade pasta',
          'ingredients': [
            {'name': 'Spaghetti', 'quantity': '200g'},
            {'name': 'Tomato Sauce', 'quantity': '100ml'}
          ]
        },
        {
          'name': 'Pizza',
          'description': 'Cheese and tomato pizza',
          'ingredients': [
            {'name': 'Pizza Dough', 'quantity': '1 piece'},
            {'name': 'Cheese', 'quantity': '100g'}
          ]
        },
      ];  // Temporarily adding sample recipes
    });
  }

  void _addNewRecipe() async {
    // Navigate to Add Recipe Screen (you can implement this with a form dialog)
    Map<String, dynamic>? newRecipe = await _showRecipeForm(context, isEditing: false);
    if (newRecipe != null) {
      setState(() {
        _recipes.add(newRecipe);
      });
    }
  }

  void _editRecipe(int index) async {
    // Navigate to Edit Recipe Screen (or show an edit dialog)
    Map<String, dynamic>? updatedRecipe = await _showRecipeForm(context, recipe: _recipes[index], isEditing: true);
    if (updatedRecipe != null) {
      setState(() {
        _recipes[index] = updatedRecipe;
      });
    }
  }

  Future<Map<String, dynamic>?> _showRecipeForm(BuildContext context, {Map<String, dynamic>? recipe, bool isEditing = false}) async {
    // A dialog to add or edit recipes, including ingredients
    TextEditingController nameController = TextEditingController(text: recipe?['name'] ?? '');
    TextEditingController descriptionController = TextEditingController(text: recipe?['description'] ?? '');
    List<Map<String, String>> ingredients = List<Map<String, String>>.from(recipe?['ingredients'] ?? []);

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Rezept bearbeiten' : 'Neues Rezept hinzufügen'),
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
                      subtitle: Text('Menge: ${ingredient['quantity']}'),
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
                    Map<String, String>? newIngredient = await _showAddIngredientDialog();
                    if (newIngredient != null) {
                      setState(() {
                        ingredients.add(newIngredient);
                      });
                    }
                  },
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
                  'description': descriptionController.text,
                  'ingredients': ingredients,
                });
              },
              child: Text(isEditing ? 'Aktualisieren' : 'Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, String>?> _showAddIngredientDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Neue Zutat hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Zutat Name'),
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
                  'quantity': quantityController.text,
                });
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  void _deleteRecipe(int index) {
    setState(() {
      _recipes.removeAt(index);  // Delete the recipe from the list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        showArrow: true,  // Back arrow
        showHome: true,  // Home icon if needed
        showProfile: false,  // Disable profile icon on this page
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
                  return _buildRecipeCard(index);  // Build recipe card with actions
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRecipe,  // Add new recipe
        backgroundColor: const Color(0xFFFDD9CF),  // Match floating action button style
        child: const Icon(Icons.add, color: Color(0xFF3A0B01)),
      ),
    );
  }

  // Recipe card widget
  Widget _buildRecipeCard(int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFFDD9CF),  // Matching background color
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: Text(
          _recipes[index]['name'] ?? '',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3A0B01)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_recipes[index]['description'] ?? '', style: const TextStyle(color: Color(0xFF3A0B01))),
            const SizedBox(height: 8),
            const Text('Zutaten:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...(_recipes[index]['ingredients'] as List).map((ingredient) {
              return Text('${ingredient['name']} - ${ingredient['quantity']}', style: const TextStyle(color: Color(0xFF3A0B01)));
            }).toList(),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF3A0B01)),
              onPressed: () => _editRecipe(index),  // Edit recipe
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF3A0B01)),
              onPressed: () => _deleteRecipe(index),  // Delete recipe
            ),
          ],
        ),
      ),
    );
  }
}
