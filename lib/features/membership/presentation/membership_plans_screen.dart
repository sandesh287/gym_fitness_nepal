import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import 'purchase_screen.dart';

class MembershipPlansScreen extends StatefulWidget {
  final Map gym;

  const MembershipPlansScreen({
    super.key,
    required this.gym,
  });

  @override
  State<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {
  final apiService = ApiService();

  List plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    try {
      final result = await apiService.getGymPlans(widget.gym['id']);

      setState(() {
        plans = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load plans: $e')),
      );
    }
  }

  void buyPlan(Map plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PurchaseScreen(
          plan: plan,
          gym: widget.gym,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Membership Plans'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B5E20),
              ),
            )
          : plans.isEmpty
              ? const Center(
                  child: Text('No plans found'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];

                    return _planCard(plan);
                  },
                ),
    );
  }

  Widget _planCard(Map plan) {
    final features = plan['features'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan['title'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            plan['duration'],
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            plan['price'],
            style: const TextStyle(
              color: Color(0xFF1B5E20),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ...features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF1B5E20),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(feature.toString()),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => buyPlan(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Buy Plan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}