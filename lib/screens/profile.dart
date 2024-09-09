import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        if (response != null) {
          setState(() {
            _userName = response['username'] ?? 'Benutzer';
            isLoading = false;
          });
        } else {
          setState(() {
            _userName = 'Benutzer';
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user profile: $e');
        setState(() {
          _userName = 'Benutzer';
          isLoading = false;
        });
      }
    }
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
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
              AutoRouter.of(context).push(const RecipeManagementRoute());
            }),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Supabase.instance.client.auth.signOut();
                AutoRouter.of(context).popUntilRoot();
                AutoRouter.of(context).replace(const AuthRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
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
}