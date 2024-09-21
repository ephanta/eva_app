import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/constants.dart';
import '../provider/data_provider.dart';
import '../widgets/buttons/custom_text_button.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/text/custom_text.dart';

@RoutePage()
class RecipeManagementScreen extends StatefulWidget {
  const RecipeManagementScreen({super.key});

  @override
  State<RecipeManagementScreen> createState() => _RecipeManagementScreenState();
}

class _RecipeManagementScreenState extends State<RecipeManagementScreen> {
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRecipes();
  }

  Future<void> _loadUserRecipes() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      final recipes = await dataProvider.fetchUserRecipes();
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Rezepte: $e')),
      );
    }
  }

  void _editRecipe(int index) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    Map<String, dynamic>? updatedRecipe = await _showRecipeForm(context,
        recipe: _recipes[index], isEditing: true);
    if (updatedRecipe != null) {
      try {
        await dataProvider.updateRecipe(_recipes[index]['id'], updatedRecipe);
        _loadUserRecipes(); // Reload after update
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Aktualisieren des Rezepts: $e')),
        );
      }
    }
  }

  void _deleteRecipe(int index) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.deleteRecipe(_recipes[index]['id']);
      _loadUserRecipes(); // Reload after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Löschen des Rezepts: $e')),
      );
    }
  }

  void _addNewRecipe() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    Map<String, dynamic>? newRecipe =
        await _showRecipeForm(context, isEditing: false);
    if (newRecipe != null) {
      try {
        await dataProvider.addNewRecipe(newRecipe);
        _loadUserRecipes(); // Reload after adding
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hinzufügen des Rezepts: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _showRecipeForm(BuildContext context,
      {Map<String, dynamic>? recipe, bool isEditing = false}) async {
    TextEditingController nameController =
        TextEditingController(text: recipe?['name'] ?? '');
    TextEditingController descriptionController =
        TextEditingController(text: recipe?['beschreibung'] ?? '');
    TextEditingController instructionsController =
        TextEditingController(text: recipe?['kochanweisungen'] ?? '');

    List<Map<String, String>> ingredients = (recipe?['zutaten'] as List?)
            ?.map((ingredient) => Map<String, String>.from(ingredient))
            .toList() ??
        [];

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title:
                  Text(isEditing ? 'Rezept bearbeiten' : 'Rezept hinzufügen'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Rezeptname'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Beschreibung'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Zutaten',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
                        Map<String, String>? newIngredient =
                            await _showAddIngredientDialog(context);
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
                      decoration:
                          const InputDecoration(labelText: 'Kochanweisungen'),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
              actions: [
                CustomTextButton(
                  buttonType: ButtonType.abort,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty) {
                      AutoRouter.of(context).maybePop({
                        'name': nameController.text,
                        'beschreibung': descriptionController.text,
                        'zutaten': ingredients,
                        'kochanweisungen': instructionsController.text,
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Bitte füllen Sie alle Felder aus.')),
                      );
                    }
                  },
                  style: _elevatedButtonStyle(),
                  child: Text(isEditing ? 'Aktualisieren' : 'Hinzufügen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>?> _showAddIngredientDialog(
      BuildContext context) async {
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
              CustomTextButton(
                buttonType: ButtonType.abort,
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      quantityController.text.isNotEmpty) {
                    AutoRouter.of(context).maybePop({
                      'name': nameController.text,
                      'menge': quantityController.text,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Bitte füllen Sie alle Felder aus.')),
                    );
                  }
                },
                style: _elevatedButtonStyle(),
                child: const Text('Hinzufügen'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        showArrow: true,
        showHome: true,
        showProfile: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // Center alignment for the column
                children: [
                  Container(
                    color: Constants.secondaryBackgroundColor,
                    // Matching background color for consistency
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Center(
                      child: CustomText(text: 'Meine Rezepte'),
                    ),
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
        backgroundColor: Constants.primaryBackgroundColor,
        child: const Icon(Icons.add, color: Constants.primaryTextColor),
      ),
    );
  }

  Widget _buildRecipeCard(int index) {
    final zutaten = _recipes[index]['zutaten'] as List<dynamic>? ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Constants.primaryBackgroundColor,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: CustomText(
          text: _recipes[index]['name'] ?? '',
          fontSize: 18,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_recipes[index]['beschreibung'] ?? '',
                style: const TextStyle(color: Constants.primaryTextColor)),
            const SizedBox(height: 8),
            const Text('Zutaten:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...zutaten.map((ingredient) {
              if (ingredient is Map<String, dynamic> &&
                  ingredient.containsKey('name') &&
                  ingredient.containsKey('menge')) {
                return Text('${ingredient['name']} - ${ingredient['menge']}',
                    style: const TextStyle(color: Constants.primaryTextColor));
              } else {
                return const SizedBox
                    .shrink(); // Skip if not properly formatted
              }
            }).toList(),
            const SizedBox(height: 8),
            const Text('Kochanweisungen:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_recipes[index]['kochanweisungen'] ?? '',
                style: const TextStyle(color: Constants.primaryTextColor)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Constants.primaryTextColor),
              onPressed: () => _editRecipe(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Constants.primaryTextColor),
              onPressed: () => _deleteRecipe(index),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Constants.secondaryBackgroundColor,
      foregroundColor: Constants.primaryTextColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      minimumSize: const Size(120, 40),
    );
  }
}
