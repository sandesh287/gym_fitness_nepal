import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../shared/widgets/empty_state.dart';

class MembershipHistoryScreen extends StatefulWidget {
  const MembershipHistoryScreen({super.key});

  @override
  State<MembershipHistoryScreen> createState() =>
      _MembershipHistoryScreenState();
}

class _MembershipHistoryScreenState extends State<MembershipHistoryScreen> {
  final apiService = ApiService();
  final authStorage = AuthStorage();

  List memberships = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final phone = await authStorage.getPhone();

    if (phone == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final result = await apiService.getMembershipHistory(phone);

      setState(() {
        memberships = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load history: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Membership History'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B5E20),
              ),
            )
          : memberships.isEmpty
              ? const EmptyState(
                icon: Icons.card_membership,
                title: 'No memberships yet',
                message: 'Purchase a gym plan and your membership history will appear here.',
              )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: memberships.length,
                  itemBuilder: (context, index) {
                    final membership = memberships[index];
                    return _membershipCard(membership);
                  },
                ),
    );
  }

  Widget _membershipCard(Map membership) {
    final isActive = membership['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF1B5E20) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.card_membership,
                color: Color(0xFF1B5E20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  membership['plan_title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  membership['status'],
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            membership['gym_name'],
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            membership['plan_price'],
            style: const TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text('Start: ${membership['start_date']}'),
          Text('End: ${membership['end_date']}'),
          const SizedBox(height: 6),
          Text(
            'Payment: ${membership['payment_method']}',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}