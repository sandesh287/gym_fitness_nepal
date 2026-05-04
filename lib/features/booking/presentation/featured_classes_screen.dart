import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../gyms/presentation/gym_screen.dart';

class FeaturedClassesScreen extends StatefulWidget {
  const FeaturedClassesScreen({super.key});

  @override
  State<FeaturedClassesScreen> createState() => _FeaturedClassesScreenState();
}

class _FeaturedClassesScreenState extends State<FeaturedClassesScreen> {
  final apiService = ApiService();

  List uniqueClasses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      final result = await apiService.getClasses();

      final seenTitles = <String>{};

      final filtered = result.where((c) {
        final title = c['title'].toString();

        if (seenTitles.contains(title)) {
          return false;
        }

        seenTitles.add(title);
        return true;
      }).toList();

      setState(() {
        uniqueClasses = filtered;
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
        title: const Text('Featured Classes'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B5E20),
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchClasses,
              child: uniqueClasses.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        EmptyState(
                          icon: Icons.self_improvement,
                          title: 'No classes available',
                          message:
                              'Classes added by admins will appear here.',
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: uniqueClasses.length,
                      itemBuilder: (context, index) {
                        final fitnessClass = uniqueClasses[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 58,
                                width: 58,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(14),
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
                                      fitnessClass['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${fitnessClass['time']} • ${fitnessClass['duration']}',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
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
                                child: const Text('Explore'),
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