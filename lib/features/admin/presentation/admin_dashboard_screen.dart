import 'package:flutter/material.dart';
import 'admin_gyms_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          children: [
            const _AdminCard(
              icon: Icons.dashboard,
              title: 'Dashboard',
              subtitle: 'Overview',
            ),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminGymsScreen(),
                  ),
                );
              },
              child: const _AdminCard(
                icon: Icons.fitness_center,
                title: 'Gyms',
                subtitle: 'Manage gyms',
              ),
            ),

            const _AdminCard(
              icon: Icons.self_improvement,
              title: 'Classes',
              subtitle: 'Manage classes',
            ),
            const _AdminCard(
              icon: Icons.calendar_month,
              title: 'Bookings',
              subtitle: 'View bookings',
            ),
            const _AdminCard(
              icon: Icons.card_membership,
              title: 'Memberships',
              subtitle: 'View plans',
            ),
            const _AdminCard(
              icon: Icons.people,
              title: 'Users',
              subtitle: 'View users',
            ),
          ],
        )
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF1B5E20),
            size: 34,
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}