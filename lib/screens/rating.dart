import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/data_provider.dart';

@RoutePage()
class RatingScreen extends StatefulWidget {
  final String recipeId;
  final String recipeName;

  const RatingScreen({Key? key, required this.recipeId, required this.recipeName}) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  late DataProvider _dataProvider;
  List<Map<String, dynamic>> _ratings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataProvider = Provider.of<DataProvider>(context, listen: false);
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    try {
      final ratings = await _dataProvider.getRatings(widget.recipeId);
      setState(() {
        _ratings = ratings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading ratings: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showAddRatingDialog() {
    int _rating = 3;
    String _comment = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bewerte ${widget.recipeName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _rating.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (value) {
                  setState(() => _rating = value.round());
                },
                label: _rating.toString(),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Kommentar'),
                onChanged: (value) => _comment = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Bewertung abgeben'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _dataProvider.addRating(widget.recipeId, _rating, _comment);
                _loadRatings();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bewertungen für ${widget.recipeName}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _ratings.length,
        itemBuilder: (context, index) {
          final rating = _ratings[index];
          return ListTile(
            leading: Icon(Icons.star, color: Colors.yellow),
            title: Text('Bewertung: ${rating['rating']}'),
            subtitle: Text(rating['comment'] ?? ''),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRatingDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}