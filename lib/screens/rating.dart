import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/constants.dart';
import '../provider/data_provider.dart';
import '../widgets/buttons/custom_text_button.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/text/custom_text.dart';

/// {@category Screens}
/// Ansicht der Bewertungsübersicht
@RoutePage()
class RatingScreen extends StatefulWidget {
  final String? recipeId;
  final String? recipeName;

  const RatingScreen({Key? key, this.recipeId, this.recipeName})
      : super(key: key);

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
      if (kDebugMode) {
        print('Error loading ratings: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  void _showAddRatingDialog() {
    int rating = 3;
    String comment = '';

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
                    value: rating.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (value) {
                      setState(() => rating = value.round());
                    },
                    label: rating.toString(),
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
                  child: const Text('Bewertung abgeben'),
                  onPressed: () async {
                    AutoRouter.of(context).maybePop();
                    await _dataProvider.addRating(
                        widget.recipeId!, rating, comment);
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
        showProfile: true,
      ),
      body: Column(
        children: [
          Container(
            color: Constants.secondaryBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CustomText(
                text: widget.recipeName != null
                    ? 'Bewertungen für ${widget.recipeName}'
                    : 'Meine Bewertungen',
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
              backgroundColor: Constants.primaryBackgroundColor,
              child: const Icon(Icons.add, color: Constants.primaryTextColor),
            )
          : null,
    );
  }

  Widget _buildRatingCard(Map<String, dynamic> rating) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Constants.primaryBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.recipeId == null
                    ? CustomText(
                        text: rating['recipe_name'] ?? 'Unbekanntes Rezept',
                        fontSize: 18,
                      )
                    : const SizedBox.shrink(),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < (rating['rating'] as int)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              rating['comment'] ?? '',
              style: const TextStyle(color: Constants.primaryTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
