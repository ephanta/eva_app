import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../main.dart';

import '../routes/app_router.gr.dart';
import '../widgets/navigation/app_bar_custom.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

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
    final userId = supabaseClientA.auth.currentUser?.id;  // Use Account A for authentication
    if (userId != null) {
      try {
        // Fetch user profile details from Supabase
        final response = await supabaseClientA
            .from('profiles')
            .select()
            .eq('id', userId)
            .single()
            .timeout(const Duration(seconds: 10));  // Add timeout for the request

        if (response != null && response is Map<String, dynamic>) {
          setState(() {
            _userName = response['username'] ?? 'Benutzer';
            _userPreferences = [
              response['allergy'] ?? 'Keine Allergie',
              response['diet'] ?? 'Keine Diät',
              response['dislike'] ?? 'Keine Abneigung'
            ];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
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
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Profil',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              _userName ?? 'Benutzer',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              runSpacing: 8.0,
              children: _userPreferences
                  .map((preference) => _buildTag(context, preference))
                  .toList(),
            ),
            const SizedBox(height: 32),
            _buildActionButton(context, 'Profil bearbeiten', Icons.edit,
                    () {
                  // Edit profile logic
                }),
            _buildActionButton(
                context, 'Haushalte verwalten', Icons.home, () {
              // Manage households logic
            }),
            _buildActionButton(
                context, 'Meine Bewertung', Icons.star, () {
              // Ratings logic
            }),
            _buildActionButton(context, 'Mein Rezeptbuch verwalten',
                Icons.book, () {
                  AutoRouter.of(context)
                      .push(const RecipeManagementRoute());
                }),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                supabaseClientA.auth.signOut();
                AutoRouter.of(context).popUntilRoot();
                AutoRouter.of(context).replace(const AuthRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDD9CF),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF3A0B01)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF3A0B01),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
