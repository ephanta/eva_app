import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/data_provider.dart';
import '../routes/app_router.gr.dart';
import '../widgets/navigation/app_bar_custom.dart';
import 'package:image_picker/image_picker.dart'; // For selecting images

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
  String _avatarUrl = ''; // Directly storing the avatar URL
  List<String> _dietaryNotes = ['keine']; // List to store dietary notes with default ["keine"]

  @override
  void initState() {
    super.initState();
    _dataProvider = Provider.of<DataProvider>(context, listen: false);
    _usernameController = TextEditingController();
    _dietaryNoteController = TextEditingController(); // Controller for dietary notes input
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _dataProvider.fetchUserProfile();
      setState(() {
        _usernameController.text = profile['username'] ?? '';
        _avatarUrl = profile['avatar_url'] ?? '';

        // Fetch dietary notes, if empty, use default ["keine"]
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
                    : null, // Only display avatar if URL is valid
                backgroundColor: _avatarUrl.isEmpty
                    ? Colors.grey[300]
                    : Colors.transparent, // Default color for placeholder
                child: _avatarUrl.isEmpty
                    ? const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ) // Placeholder icon
                    : null,
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
                      ? null // Do not allow deletion of "keine"
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
      // Add new notes, splitting by comma, and trim whitespace
      _dietaryNotes.addAll(
          notes.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
      _dietaryNotes.remove('keine'); // Remove "keine" if there are new entries
      _dietaryNoteController.clear(); // Clear input after submission
    });

    await _updateDietaryNotesInDatabase();
  }

  Future<void> _removeDietaryNote(String note) async {
    setState(() {
      _dietaryNotes.remove(note);
      if (_dietaryNotes.isEmpty) {
        _dietaryNotes = ['keine']; // Reset to default if empty
      }
    });

    await _updateDietaryNotesInDatabase();
  }

  Future<void> _updateDietaryNotesInDatabase() async {
    try {
      // Prepare the dietary notes as a single string
      String notesString = _dietaryNotes.join(',');
      await _dataProvider.updateDietaryNotes(notesString); // Update database
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating dietary notes: $e')),
      );
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton('Manage Households', Icons.home, () {
          // Navigate to Manage Households
        }),
        _buildActionButton('My Ratings', Icons.star, () {
          // Navigate to Ratings
        }),
        _buildActionButton('Recipe Management', Icons.book, () {
          AutoRouter.of(context).push(const RecipeManagementRoute());
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
    AutoRouter.of(context).replace(const AuthRoute());
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
        showProfile: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Profil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
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
