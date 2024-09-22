import 'package:auto_route/auto_route.dart';
import 'package:eva_app/data/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/data_provider.dart';
import '../routes/app_router.gr.dart';
import '../widgets/navigation/app_bar_custom.dart';
import '../widgets/text/custom_text.dart';

/// {@category Screens}
/// Ansicht des Profils eines Nutzers
@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DataProvider _dataProvider;
  bool _isEditing = false;
  late TextEditingController _usernameController;
  late TextEditingController _dietaryNoteController;
  String _avatarUrl = '';
  List<String> _dietaryNotes = ['keine'];

  @override
  void initState() {
    super.initState();
    _dataProvider = Provider.of<DataProvider>(context, listen: false);
    _usernameController = TextEditingController();
    _dietaryNoteController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final profile = await _dataProvider.fetchUserProfile();
      final String? localeUsername = prefs.getString('username');
      setState(() {
        if (localeUsername != null && profile['username'] == 'New User') {
          _usernameController.text = localeUsername;
          final updatedProfile = {
            'username': localeUsername,
          };
          _dataProvider.updateProfile(updatedProfile);
        } else {
          _usernameController.text = profile['username'] ?? '';
        }
        _avatarUrl = profile['avatar_url'] ?? '';

        final dietaryNotes =
            profile['hinweise_zur_ernaehrung']?.toString().split(',') ?? [];
        _dietaryNotes =
            dietaryNotes.isNotEmpty && dietaryNotes.first.trim() != ''
                ? dietaryNotes.map((note) => note.trim()).toList()
                : ['keine'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Constants.primaryBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickAvatarImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _avatarUrl.isNotEmpty
                    ? NetworkImage(_avatarUrl)
                    : const AssetImage('assets/default_avatar.png')
                        as ImageProvider,
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nutzername',
                labelStyle: TextStyle(color: Constants.primaryTextColor),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Constants.primaryTextColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Constants.primaryTextColor),
                ),
              ),
              enabled: _isEditing,
              style: const TextStyle(color: Constants.primaryTextColor),
            ),
            const SizedBox(height: 16),
            const CustomText(text: 'Hinweise zur Ernährung:', fontSize: 18),
            Wrap(
              spacing: 8,
              children: _dietaryNotes.map((note) {
                return Chip(
                  label: Text(note,
                      style:
                          const TextStyle(color: Constants.primaryTextColor)),
                  backgroundColor: Constants.secondaryBackgroundColor,
                  deleteIcon: const Icon(Icons.close,
                      color: Constants.primaryTextColor),
                  onDeleted:
                      note == 'keine' ? null : () => _removeDietaryNote(note),
                );
              }).toList(),
            ),
            if (_isEditing) ...[
              TextField(
                controller: _dietaryNoteController,
                decoration: const InputDecoration(
                  labelText: 'Neue Hinweise zur Ernährung',
                  labelStyle: TextStyle(color: Constants.primaryTextColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Constants.primaryTextColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Constants.primaryTextColor),
                  ),
                ),
                style: const TextStyle(color: Constants.primaryTextColor),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _addDietaryNotes(value);
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_dietaryNoteController.text.isNotEmpty) {
                    _addDietaryNotes(_dietaryNoteController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.secondaryBackgroundColor,
                ),
                child: const Text('Neuen Ernährungshinweis hinzufügen',
                    style: TextStyle(color: Constants.primaryTextColor)),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isEditing ? _saveProfile : _startEditing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.secondaryBackgroundColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(_isEditing ? 'Speichern' : 'Profil bearbeiten',
                  style: const TextStyle(color: Constants.primaryTextColor)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addDietaryNotes(String notes) async {
    setState(() {
      final newNotes = notes
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (_dietaryNotes.contains('keine')) {
        _dietaryNotes.remove('keine');
      }

      _dietaryNotes.addAll(newNotes);
      _dietaryNoteController.clear();
    });

    await _updateDietaryNotesInDatabase();
  }

  Future<void> _removeDietaryNote(String note) async {
    setState(() {
      _dietaryNotes.remove(note);
      if (_dietaryNotes.isEmpty) {
        _dietaryNotes = ['keine'];
      }
    });

    await _updateDietaryNotesInDatabase();
  }

  Future<void> _updateDietaryNotesInDatabase() async {
    try {
      String notesString =
          _dietaryNotes.contains('keine') ? '' : _dietaryNotes.join(',');
      await _dataProvider.updateDietaryNotes(notesString);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dietary notes updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating dietary notes: $e')),
      );
    }
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final newAvatarUrl = await _dataProvider.uploadAvatar(pickedFile.path);
        setState(() {
          _avatarUrl = newAvatarUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile picture updated successfully.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating avatar: $e')),
        );
      }
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton('Meine Bewertungen', Icons.star, () {
          context.router.push(RatingRoute());
        }),
        _buildActionButton('Rezeptverwaltung', Icons.book, () {
          context.router.push(const RecipeManagementRoute());
        }),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Constants.primaryTextColor),
        // Matching icon color
        label: Text(
          label,
          style: const TextStyle(
            color: Constants.primaryTextColor, // Matching text color
          ),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.secondaryBackgroundColor,
          // Matching background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded look
          ),
          minimumSize: const Size(double.infinity, 50),
          // Ensuring full-width buttons
          elevation: 2, // Optional elevation for a more distinct button
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _logout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Constants.warningColor,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Log Out', style: TextStyle(color: Colors.white)),
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  Future<void> _saveProfile() async {
    try {
      String dietaryNotesString =
          _dietaryNotes.contains('keine') ? '' : _dietaryNotes.join(',');

      final updatedProfile = {
        'username': _usernameController.text,
        'avatar_url': _avatarUrl,
        'hinweise_zur_ernaehrung': dietaryNotesString,
      };

      await _dataProvider.updateProfile(updatedProfile);

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil erfolgreich aktualisiert')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Aktualisieren des Profils: $e')),
      );
    }
  }

  void _logout() {
    _dataProvider.signOut();
    context.router.replace(const AuthRoute());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _dietaryNoteController.dispose();
    super.dispose();
  }

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
          children: [
            Container(
              color: Constants.secondaryBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Center(
                child: CustomText(
                  text: 'Profil',
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileSection(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
