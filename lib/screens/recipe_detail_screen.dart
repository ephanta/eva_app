// lib/screens/recipe_detail_screen.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/data_provider.dart';
import '../models/recipe.dart';
import '../routes/app_router.gr.dart';

@RoutePage()
class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({Key? key, @PathParam('id') required this.recipeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.router.push(RecipeEditRoute(recipeId: recipeId)),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<Recipe>(
        future: _fetchRecipe(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final recipe = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    recipe.description,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ingredients:',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Text('• $ingredient'),
                  )),
                  const SizedBox(height: 24),
                  Text(
                    'Steps:',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 8),
                  ...recipe.steps.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: Text('${entry.key + 1}. ${entry.value}'),
                  )),
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

  Future<Recipe> _fetchRecipe(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final recipes = await dataProvider.fetchRecipes('dummy_household_id'); // Replace with actual household ID
    final recipe = recipes.firstWhere((r) => r.id == recipeId, orElse: () => throw Exception('Recipe not found'));
    return recipe;
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: const Text('Are you sure you want to delete this recipe?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).maybePop();
                _deleteRecipe(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteRecipe(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.deleteRecipe(recipeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe deleted successfully')),
      );
      context.router.maybePop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting recipe: $e')),
      );
    }
  }
}