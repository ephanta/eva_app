import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/data_provider.dart';
import '../widgets/navigation/app_bar_custom.dart';

@RoutePage()
class RatingScreen extends StatefulWidget {
  final String? recipeId;
  final String? recipeName;

  const RatingScreen({Key? key, this.recipeId, this.recipeName}) : super(key: key);

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
      final ratings = widget.recipeId != null
          ? await _dataProvider.getRatings(widget.recipeId!)
          : await _dataProvider.getUserRatings();
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
        return StatefulBuilder(
          builder: (context, setState) {
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
                    await _dataProvider.addRating(widget.recipeId!, _rating, _comment);
                    _loadRatings();
                  },
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
        showProfile: false,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFFDF6F4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                widget.recipeName != null
                    ? 'Bewertungen für ${widget.recipeName}'
                    : 'Meine Bewertungen',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A0B01),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _ratings.isEmpty
                ? const Center(child: Text('Keine Bewertungen vorhanden'))
                : ListView.builder(
              itemCount: _ratings.length,
              itemBuilder: (context, index) {
                return _buildRatingCard(_ratings[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.recipeId != null
          ? FloatingActionButton(
        onPressed: _showAddRatingDialog,
        backgroundColor: const Color(0xFFFDD9CF),
        child: const Icon(Icons.add, color: Color(0xFF3A0B01)),
      )
          : null,
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> rating) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFFDD9CF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.recipeId == null
                    ? Text(
                  rating['recipe_name'] ?? 'Unbekanntes Rezept',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A0B01),
                  ),
                )
                    : const SizedBox.shrink(),
                Row(
                  children: List.generate(
                    5,
                        (index) => Icon(
                      index < (rating['rating'] as int) ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              rating['comment'] ?? '',
              style: const TextStyle(color: Color(0xFF3A0B01)),
            ),
          ],
        ),
      ),
    );
  }
}