import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';

class AdminClassesScreen extends StatefulWidget {
  const AdminClassesScreen({super.key});

  @override
  State<AdminClassesScreen> createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends State<AdminClassesScreen> {
  final apiService = ApiService();

  List gyms = [];
  List classes = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final gymResult = await apiService.getGyms();
      final classResult = await apiService.getClasses();

      setState(() {
        gyms = gymResult;
        classes = classResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> showClassDialog({Map? fitnessClass}) async {
    final isEdit = fitnessClass != null;

    if (gyms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a gym first')),
      );
      return;
    }

    Map selectedGym = isEdit
        ? gyms.firstWhere(
            (gym) => gym['id'] == fitnessClass['gym_id'],
            orElse: () => gyms.first,
          )
        : gyms.first;

    final titleController =
        TextEditingController(text: fitnessClass?['title'] ?? '');
    final trainerController =
        TextEditingController(text: fitnessClass?['trainer'] ?? '');
    final timeController =
        TextEditingController(text: fitnessClass?['time'] ?? '');
    final durationController =
        TextEditingController(text: fitnessClass?['duration'] ?? '');
    final capacityController = TextEditingController(
      text: fitnessClass?['capacity']?.toString() ?? '',
    );
    final availableSlotsController = TextEditingController(
      text: fitnessClass?['available_slots']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Class' : 'Add Class'),
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
                        labelText: 'Class Title',
                        hintText: 'Morning Yoga',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: trainerController,
                      decoration: const InputDecoration(
                        labelText: 'Trainer',
                        hintText: 'Trainer Sita',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        hintText: '06:00 AM',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        hintText: '60 min',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacity',
                        hintText: '20',
                      ),
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: availableSlotsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Available Slots',
                        ),
                      ),
                    ],
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
                    final capacity =
                        int.tryParse(capacityController.text.trim());

                    final availableSlots = isEdit
                        ? int.tryParse(
                            availableSlotsController.text.trim(),
                          )
                        : capacity;

                    if (titleController.text.trim().isEmpty ||
                        trainerController.text.trim().isEmpty ||
                        timeController.text.trim().isEmpty ||
                        durationController.text.trim().isEmpty ||
                        capacity == null ||
                        availableSlots == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields correctly'),
                        ),
                      );
                      return;
                    }

                    if (isEdit) {
                      await apiService.updateClass(
                        classId: fitnessClass['id'],
                        gymId: selectedGym['id'],
                        gymName: selectedGym['name'],
                        title: titleController.text.trim(),
                        trainer: trainerController.text.trim(),
                        time: timeController.text.trim(),
                        duration: durationController.text.trim(),
                        capacity: capacity,
                        availableSlots: availableSlots,
                      );
                    } else {
                      await apiService.createClass(
                        gymId: selectedGym['id'],
                        gymName: selectedGym['name'],
                        title: titleController.text.trim(),
                        trainer: trainerController.text.trim(),
                        time: timeController.text.trim(),
                        duration: durationController.text.trim(),
                        capacity: capacity,
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

  Future<void> confirmDelete(Map fitnessClass) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Class'),
          content: Text(
            'Are you sure you want to delete ${fitnessClass['title']}?',
          ),
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

    await apiService.deleteClass(fitnessClass['id']);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Class deleted')),
    );

    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Manage Classes'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showClassDialog(),
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: classes.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No classes added yet')),
                      ],
                    )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final fitnessClass = classes[index];

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
                            Icons.self_improvement,
                            color: Color(0xFF1B5E20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fitnessClass['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(fitnessClass['gym_name']),
                                const SizedBox(height: 4),
                                Text(
                                  '${fitnessClass['time']} • ${fitnessClass['duration']}',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Slots: ${fitnessClass['available_slots']}/${fitnessClass['capacity']}',
                                  style: const TextStyle(
                                    color: Color(0xFF1B5E20),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                showClassDialog(fitnessClass: fitnessClass),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => confirmDelete(fitnessClass),
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