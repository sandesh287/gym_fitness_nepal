import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../shared/widgets/empty_state.dart';

class ClassesScreen extends StatefulWidget {
  final int gymId;
  final String gymName;

  const ClassesScreen({
    super.key,
    required this.gymId,
    required this.gymName,
  });

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final apiService = ApiService();
  final authStorage = AuthStorage();

  List classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      final result = await apiService.getClasses(gymId: widget.gymId);

      setState(() {
        classes = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('${widget.gymName} Classes'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B5E20),
              ),
            )
          : classes.isEmpty
              ? const EmptyState(
                  icon: Icons.self_improvement,
                  title: 'No classes available',
                  message: 'This gym has not added any classes yet. Please check again later.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final c = classes[index];
                    return _classCard(c);
                  },
                ),
    );
  }

  Widget _classCard(Map c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c['title'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text('Trainer: ${c['trainer']}'),

          const SizedBox(height: 6),

          Text('${c['time']} • ${c['duration']}'),

          const SizedBox(height: 6),

          Text('Available Slots: ${c['available_slots']}'),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () async {
                final phone = await authStorage.getPhone();

                if (phone == null) return;

                final result = await apiService.bookClass(
                  classId: c['id'],
                  userPhone: phone,
                );

                if (!mounted) return;

                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Class booked successfully')),
                  );

                  fetchClasses(); // refresh slots
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
              ),
              child: const Text('Book Class'),
            ),
          )
        ],
      ),
    );
  }
}