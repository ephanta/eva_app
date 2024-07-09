// lib/screens/recipe_edit_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/data_provider.dart';
import '../models/recipe.dart';

@RoutePage()
class RecipeEditScreen extends StatefulWidget {
  final String recipeId;

  const RecipeEditScreen({Key? key, @PathParam('id') required this.recipeId}) : super(key: key);

  @override
  _RecipeEditScreenState createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends State<RecipeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<Recipe> _recipeFuture;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _stepControllers = [];

  String _userId = '';
  String _householdId = '';
  DateTime _createdAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _recipeFuture = _fetchRecipe();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<Recipe> _fetchRecipe() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    return dataProvider.fetchRecipeById(widget.recipeId);
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientControllers.removeAt(index).dispose();
    });
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    setState(() {
      _stepControllers.removeAt(index).dispose();
    });
  }

  void _updateRecipe() async {
    if (_formKey.currentState!.validate()) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      final updatedRecipe = Recipe(
        id: widget.recipeId,
        name: _nameController.text,
        description: _descriptionController.text,
        ingredients: _ingredientControllers.map((c) => c.text).toList(),
        steps: _stepControllers.map((c) => c.text).toList(),
        userId: _userId,
        householdId: _householdId,
        createdAt: _createdAt,
      );

      try {
        await dataProvider.updateRecipe(updatedRecipe);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully')),
        );
        context.router.maybePop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating recipe: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
      ),
      body: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final recipe = snapshot.data!;

            // Initialize controllers and fields with existing data
            _nameController.text = recipe.name;
            _descriptionController.text = recipe.description;
            _ingredientControllers.clear();
            _ingredientControllers.addAll(recipe.ingredients.map((i) => TextEditingController(text: i)));
            _stepControllers.clear();
            _stepControllers.addAll(recipe.steps.map((s) => TextEditingController(text: s)));
            _userId = recipe.userId;
            _householdId = recipe.householdId;
            _createdAt = recipe.createdAt;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Recipe Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a recipe name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
                  ..._ingredientControllers.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            decoration: const InputDecoration(labelText: 'Ingredient'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an ingredient';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _removeIngredient(entry.key),
                        ),
                      ],
                    ),
                  )),
                  ElevatedButton(
                    onPressed: _addIngredient,
                    child: const Text('Add Ingredient'),
                  ),
                  const SizedBox(height: 16),
                  Text('Steps', style: Theme.of(context).textTheme.titleLarge),
                  ..._stepControllers.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            decoration: InputDecoration(labelText: 'Step ${entry.key + 1}'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a step';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _removeStep(entry.key),
                        ),
                      ],
                    ),
                  )),
                  ElevatedButton(
                    onPressed: _addStep,
                    child: const Text('Add Step'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateRecipe,
                    child: const Text('Update Recipe'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Recipe not found'));
          }
        },
      ),
    );
  }
}