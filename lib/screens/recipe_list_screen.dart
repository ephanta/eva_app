import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/data_provider.dart';
import '../models/recipe.dart';
import '../routes/app_router.gr.dart';

@RoutePage()
class RecipeListScreen extends StatefulWidget {
  final String householdId;

  const RecipeListScreen({Key? key, @PathParam('id') required this.householdId}) : super(key: key);

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  int _currentPage = 1;
  static const int _itemsPerPage = 10;
  List<Recipe> _recipes = [];
  int _totalPages = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final result = await dataProvider.fetchRecipes(
        widget.householdId,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      setState(() {
        _recipes = result['recipes'];
        _totalPages = result['totalPages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipes for ${widget.householdId}')),
      body: RefreshIndicator(
        onRefresh: _loadRecipes,
        child: Column(
          children: [
            Expanded(
              child: _isLoading && _recipes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _recipes.isEmpty
                  ? const Center(child: Text('No recipes found'))
                  : ListView.builder(
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  final recipe = _recipes[index];
                  return ListTile(
                    title: Text(recipe.name),
                    subtitle: Text(recipe.description),
                    onTap: () => context.router.push(RecipeDetailRoute(recipeId: recipe.id)),
                  );
                },
              ),
            ),
            if (_totalPages > 1)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage > 1
                          ? () {
                        setState(() => _currentPage--);
                        _loadRecipes();
                      }
                          : null,
                      child: const Text('Previous'),
                    ),
                    const SizedBox(width: 16),
                    Text('Page $_currentPage of $_totalPages'),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _currentPage < _totalPages
                          ? () {
                        setState(() => _currentPage++);
                        _loadRecipes();
                      }
                          : null,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.router.push(RecipeCreateRoute(householdId: widget.householdId)),
        child: const Icon(Icons.add),
      ),
    );
  }
}