import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../routes/app_router.gr.dart';
import '../widgets/navigation/app_bar_custom.dart';

/// {@category Screens}
/// Ansicht für das Profil des angemeldeten Benutzers
@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// Der Zustand für die Profil-Seite
class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;
  List<String> _userPreferences = [];  // Dynamic preferences such as allergies or diet
  bool isLoading = true;  // To show a loading indicator

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the screen initializes
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        // Fetch user profile details from a hypothetical `profiles` table in Supabase
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single()
            .timeout(const Duration(seconds: 10));  // Add timeout for the request

        // Log the response to see what it contains
        print('Response: $response');

        // Check if the response has the data
        if (response != null && response is Map<String, dynamic>) {
          final data = response; // The response is already a Map<String, dynamic>

          setState(() {
            _userName = data['username'] ?? 'Benutzer';
            _userPreferences = [
              data['allergy'] ?? 'Keine Allergie',
              data['diet'] ?? 'Keine Diät',
              data['dislike'] ?? 'Keine Abneigung'
            ];
            isLoading = false;  // Data loaded, stop showing loading indicator
          });
        } else {
          // If response is null or no data found
          print('Error: No data found for user profile.');
          setState(() {
            isLoading = false;  // Stop loading if no data is found
          });
        }
      } catch (e) {
        // Handle the error
        print('Error fetching user profile: $e');
        setState(() {
          isLoading = false;  // Stop loading even if there's an error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCustom(
        showArrow: true,
        showHome: true,
        showProfile: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())  // Show a loading spinner
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Title
            Text(
              'Profil',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300], // Placeholder color
              child: const Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            // User Name
            Text(
              _userName ?? 'Benutzer',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Allergies, General Eating Habits, Preferences
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              runSpacing: 8.0,
              children: _userPreferences.map((preference) {
                return _buildTag(context, preference);
              }).toList(),
            ),
            const SizedBox(height: 32),
            // Action buttons (Edit Profile, Manage Households, My Ratings, Recipe Management)
            _buildActionButton(context, 'Profil bearbeiten', Icons.edit, () {
              // Navigate to Edit Profile
            }),
            _buildActionButton(context, 'Haushalte verwalten', Icons.home, () {
              // Navigate to Manage Households
            }),
            _buildActionButton(context, 'Meine Bewertung', Icons.star, () {
              // Navigate to Ratings
            }),
            _buildActionButton(context, 'Mein Rezeptbuch verwalten', Icons.book, () {
              AutoRouter.of(context).push(const RecipeManagementRoute());  // Navigate to Recipe Management screen
            }),
            const Spacer(),
            // Log Out button at the bottom
            ElevatedButton(
              onPressed: () {
                Supabase.instance.client.auth.signOut();
                AutoRouter.of(context).popUntilRoot();
                AutoRouter.of(context).replace(const AuthRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Red color for the logout button
                minimumSize: const Size(double.infinity, 50), // Full width button
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the badges
  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

// Helper method to build buttons with floating button style
  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFDD9CF),
            borderRadius: BorderRadius.circular(30), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // Light shadow for floating effect
                offset: Offset(0, 2), // Shadow position
                blurRadius: 6, // Softness of the shadow
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Color(0xFF3A0B01)), // Icon with matching color
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF3A0B01), // Text color to match the icon
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
