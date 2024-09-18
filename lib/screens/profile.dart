import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:image_picker/image_picker.dart';
import '../provider/data_provider.dart';
import '../routes/app_router.gr.dart';

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
      final profile = await _dataProvider.fetchUserProfile();
      setState(() {
        _usernameController.text = profile['username'] ?? '';
        _avatarUrl = profile['avatar_url'] ?? '';

        final dietaryNotes = profile['hinweise_zur_ernaehrung']?.toString().split(',') ?? [];
        _dietaryNotes = dietaryNotes.isNotEmpty && dietaryNotes.first.trim() != ''
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
                    : const AssetImage('assets/default_avatar.png') as ImageProvider,
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 10),
            Text(
              'Hinweise zur Ernährung:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Wrap(
              spacing: 8,
              children: _dietaryNotes.map((note) {
                return Chip(
                  label: Text(note),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: note == 'keine'
                      ? null
                      : () {
                    _removeDietaryNote(note);
                  },
                );
              }).toList(),
            ),
            if (_isEditing) ...[
              TextField(
                controller: _dietaryNoteController,
                decoration: const InputDecoration(labelText: 'Neue Hinweise zur Ernährung'),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _addDietaryNotes(value);
                  }
                },
              ),
            ],
            ElevatedButton(
              onPressed: _isEditing ? _saveProfile : _startEditing,
              child: Text(_isEditing ? 'Speichern' : 'Profil bearbeiten'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addDietaryNotes(String notes) async {
    setState(() {
      _dietaryNotes.addAll(
          notes.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
      _dietaryNotes.remove('keine');
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
      String notesString = _dietaryNotes.join(',');
      await _dataProvider.updateDietaryNotes(notesString);
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
          const SnackBar(content: Text('Profile picture updated successfully.')),
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
        _buildActionButton('Manage Households', Icons.home, () {
          // Navigate to Manage Households
          // context.router.push(const ManageHouseholdsRoute()); // Uncomment when implemented
        }),
        _buildActionButton('My Ratings', Icons.star, () {
          // Navigate to Ratings
          // context.router.push(const MyRatingsRoute()); // Uncomment when implemented
        }),
        _buildActionButton('Recipe Management', Icons.book, () {
          context.router.push(const RecipeManagementRoute());
        }),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _logout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
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
      final updatedProfile = {
        'username': _usernameController.text,
        'avatar_url': _avatarUrl,
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
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
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
    );
  }
}