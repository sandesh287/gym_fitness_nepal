import 'package:flutter/material.dart';
import '../../../core/storage/auth_storage.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../core/network/api_service.dart';
import '../../gyms/presentation/gym_detail_screen.dart';
import '../../membership/presentation/membership_history_screen.dart';
import '../../booking/presentation/booking_history_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../gyms/presentation/gym_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final apiService = ApiService();
  Map? activeMembership;
  bool isLoadingMembership = true;

  List gyms = [];
  bool isLoadingGyms = true;

  Future<void> logout() async {
    final authStorage = AuthStorage();
    await authStorage.clearSession();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchGyms();
    fetchMembership();
  }

  Future<void> fetchGyms() async {
    try {
      final result = await apiService.getGyms();

      setState(() {
        gyms = result;
        isLoadingGyms = false;
      });
    } catch (e) {
      setState(() {
        isLoadingGyms = false;
      });
    }
  }

  Future<void> fetchMembership() async {
    try {
      final authStorage = AuthStorage();
      final phone = await authStorage.getPhone();

      if (phone == null) {
        setState(() {
          isLoadingMembership = false;
        });
        return;
      }

      final result = await apiService.getActiveMembership(phone);

      setState(() {
        activeMembership = result['data'];
        isLoadingMembership = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMembership = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text('Fit Nepal'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _activeMembershipCard(),
            const SizedBox(height: 20),

            _sectionTitle('Quick Actions'),
            const SizedBox(height: 12),
            _quickActions(),

            const SizedBox(height: 24),

            _sectionTitle('Nearby Gyms'),
            const SizedBox(height: 12),
            _nearbyGyms(),

            const SizedBox(height: 24),

            _sectionTitle('Featured Classes'),
            const SizedBox(height: 12),
            _featuredClasses(),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GymsScreen(),
              ),
            );
            return;
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BookingHistoryScreen(),
              ),
            );
            return;
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
            return;
          }

          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Gyms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _activeMembershipCard() {
    if (isLoadingMembership) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: activeMembership == null
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Membership',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 8),
                Text(
                  'No active plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Membership',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  activeMembership!['plan_title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activeMembership!['gym_name'],
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  'Valid till: ${activeMembership!['end_date']}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _quickActions() {
    return Row(
      children: [
        _quickAction(Icons.history, 'History'),
        const SizedBox(width: 10),
        _quickAction(Icons.fitness_center, 'Gyms'),
        const SizedBox(width: 10),
        _quickAction(Icons.calendar_month, 'Bookings'),
      ],
    );
  }

  Widget _quickAction(IconData icon, String title) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (title == 'History') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MembershipHistoryScreen(),
              ),
            );
          }
          if (title == 'Gyms') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GymsScreen(),
              ),
            );
          }

          if (title == 'Bookings') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BookingHistoryScreen(),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF1B5E20), size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nearbyGyms() {
    if (isLoadingGyms) {
      return const Center(child: CircularProgressIndicator());
    }

    if (gyms.isEmpty) {
      return const EmptyState(
        icon: Icons.fitness_center,
        title: 'No gyms found',
        message: 'We could not find any gyms right now. Please try again later.',
      );
    }

    return Column(
      children: gyms.map((gym) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GymDetailScreen(gym: gym),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Color(0xFF1B5E20),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gym['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gym['location'],
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gym['display_price'],
                        style: const TextStyle(
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _featuredClasses() {
    final classes = [
      {'title': 'Morning Yoga', 'time': '6:00 AM', 'trainer': 'Trainer Sita'},
      {
        'title': 'HIIT Training',
        'time': '5:30 PM',
        'trainer': 'Trainer Ramesh',
      },
    ];

    return Column(
      children: classes.map((fitnessClass) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.self_improvement,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fitnessClass['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fitnessClass['time']} • ${fitnessClass['trainer']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GymsScreen(
                        classTitle: fitnessClass['title'],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Explore'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
