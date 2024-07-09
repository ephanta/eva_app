// lib/screens/recipe_create_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/data_provider.dart';
import '../models/recipe.dart';
import 'package:uuid/uuid.dart';

@RoutePage()
class RecipeCreateScreen extends StatefulWidget {
  final String householdId;

  const RecipeCreateScreen({Key? key, @PathParam('householdId') required this.householdId}) : super(key: key);

  @override
  _RecipeCreateScreenState createState() => _RecipeCreateScreenState();
}

class _RecipeCreateScreenState extends State<RecipeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [TextEditingController()];
  final List<TextEditingController> _stepControllers = [TextEditingController()];

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

  void _createRecipe() async {
    if (_formKey.currentState!.validate()) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final userId = dataProvider.getCurrentUserId();

      final newRecipe = Recipe(
        id: const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        ingredients: _ingredientControllers.map((c) => c.text).toList(),
        steps: _stepControllers.map((c) => c.text).toList(),
        userId: userId,
        householdId: widget.householdId,
        createdAt: DateTime.now(),
      );

      try {
        await dataProvider.createRecipe(newRecipe);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe created successfully')),
        );
        context.router.maybePop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating recipe: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe'),
      ),
      body: Form(
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
              onPressed: _createRecipe,
              child: const Text('Create Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}