import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/auth_storage.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final apiService = ApiService();
  final authStorage = AuthStorage();
  String role = 'user';

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final phone = await authStorage.getPhone();

    if (phone == null) return;

    final data = await apiService.getProfile(phone);

    role = data['role'] ?? 'user';

    nameController.text = data['name'] ?? '';
    emailController.text = data['email'] ?? '';

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveProfile() async {
    final phone = await authStorage.getPhone();

    if (phone == null) return;

    await apiService.updateProfile(
      phone: phone,
      name: nameController.text,
      email: emailController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.person,
                          size: 46,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        nameController.text.isEmpty
                            ? 'Your Profile'
                            : nameController.text,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emailController.text.isEmpty
                            ? 'Add your email'
                            : emailController.text,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Save Profile',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                if (role == 'admin') ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboardScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Open Admin Panel'),
                    ),
                  ),
                ],

              ],
            ),
          ),
    );
  }
}