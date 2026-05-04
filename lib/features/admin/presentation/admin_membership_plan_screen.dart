import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';

class AdminMembershipPlansScreen extends StatefulWidget {
  const AdminMembershipPlansScreen({super.key});

  @override
  State<AdminMembershipPlansScreen> createState() =>
      _AdminMembershipPlansScreenState();
}

class _AdminMembershipPlansScreenState
    extends State<AdminMembershipPlansScreen> {
  final apiService = ApiService();

  List gyms = [];
  List plans = [];

  bool isLoading = true;

  final durationOptions = [
    {
      'label': '1 Month',
      'days': 30,
    },
    {
      'label': '3 Months',
      'days': 90,
    },
    {
      'label': '6 Months',
      'days': 180,
    },
    {
      'label': '1 Year',
      'days': 365,
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final gymResult = await apiService.getGyms();
      final planResult = await apiService.getAllMembershipPlans();

      setState(() {
        gyms = gymResult;
        plans = planResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> showPlanDialog({Map? plan}) async {
    final isEdit = plan != null;

    if (gyms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a gym first')),
      );
      return;
    }

    Map selectedGym = isEdit
        ? gyms.firstWhere(
            (gym) => gym['id'] == plan['gym_id'],
            orElse: () => gyms.first,
          )
        : gyms.first;

    Map selectedDuration = isEdit
        ? durationOptions.firstWhere(
            (item) => item['label'] == plan['duration'],
            orElse: () => durationOptions.first,
          )
        : durationOptions.first;

    final titleController = TextEditingController(text: plan?['title'] ?? '');
    final priceController =
        TextEditingController(text: plan?['price']?.toString() ?? '');
    final featuresController = TextEditingController(
      text: plan?['features'] is List
          ? (plan!['features'] as List).join(', ')
          : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Plan' : 'Add Plan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: selectedGym['id'],
                      decoration: const InputDecoration(labelText: 'Gym'),
                      items: gyms.map((gym) {
                        return DropdownMenuItem<int>(
                          value: gym['id'],
                          child: Text(gym['name']),
                        );
                      }).toList(),
                      onChanged: (gymId) {
                        final gym = gyms.firstWhere((g) => g['id'] == gymId);
                        setDialogState(() {
                          selectedGym = gym;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Plan Title',
                        hintText: 'Monthly Plan',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDuration['label'] as String,
                      decoration: const InputDecoration(labelText: 'Duration'),
                      items: durationOptions.map((duration) {
                        return DropdownMenuItem<String>(
                          value: duration['label'] as String,
                          child: Text(duration['label'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        final duration = durationOptions.firstWhere(
                          (item) => item['label'] == value,
                        );

                        setDialogState(() {
                          selectedDuration = duration;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: '2500',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: featuresController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Features',
                        hintText:
                            'Gym access, Locker access, Trainer guidance',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final price = int.tryParse(priceController.text.trim());

                    if (titleController.text.trim().isEmpty ||
                        price == null ||
                        featuresController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields correctly'),
                        ),
                      );
                      return;
                    }

                    if (isEdit) {
                      await apiService.updateMembershipPlan(
                        planId: plan['id'],
                        gymId: selectedGym['id'],
                        gymName: selectedGym['name'],
                        title: titleController.text.trim(),
                        duration: selectedDuration['label'] as String,
                        durationDays: selectedDuration['days'] as int,
                        price: price,
                        features: featuresController.text.trim(),
                      );
                    } else {
                      await apiService.createMembershipPlan(
                        gymId: selectedGym['id'],
                        gymName: selectedGym['name'],
                        title: titleController.text.trim(),
                        duration: selectedDuration['label'] as String,
                        durationDays: selectedDuration['days'] as int,
                        price: price,
                        features: featuresController.text.trim(),
                      );
                    }

                    if (!context.mounted) return;

                    Navigator.pop(context);
                    fetchData();
                  },
                  child: Text(isEdit ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> confirmDelete(Map plan) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Plan'),
          content: Text('Delete ${plan['title']} for ${plan['gym_name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await apiService.deleteMembershipPlan(plan['id']);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan deleted')),
    );

    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Manage Membership Plans'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showPlanDialog(),
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: plans.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No membership plans added yet')),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.card_membership,
                                color: Color(0xFF1B5E20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan['title'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(plan['gym_name']),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${plan['display_price']} • ${plan['duration']}',
                                      style: const TextStyle(
                                        color: Color(0xFF1B5E20),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => showPlanDialog(plan: plan),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () => confirmDelete(plan),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}