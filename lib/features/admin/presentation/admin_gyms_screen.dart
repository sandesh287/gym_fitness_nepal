import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';

class AdminGymsScreen extends StatefulWidget {
  const AdminGymsScreen({super.key});

  @override
  State<AdminGymsScreen> createState() => _AdminGymsScreenState();
}

class _AdminGymsScreenState extends State<AdminGymsScreen> {
  final apiService = ApiService();

  List gyms = [];
  bool isLoading = true;

  final durationOptions = ['month', '3 months', '6 months', 'year'];

  @override
  void initState() {
    super.initState();
    fetchGyms();
  }

  Future<void> fetchGyms() async {
    try {
      final result = await apiService.getGyms();

      setState(() {
        gyms = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> showGymDialog({Map? gym}) async {
    final isEdit = gym != null;

    final nameController = TextEditingController(text: gym?['name'] ?? '');
    final locationController =
        TextEditingController(text: gym?['location'] ?? '');
    final priceController =
        TextEditingController(text: gym?['price']?.toString() ?? '');

    String selectedDuration = gym?['price_duration'] ?? 'month';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Gym' : 'Add Gym'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Gym Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: '1500',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDuration,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                      ),
                      items: durationOptions.map((duration) {
                        return DropdownMenuItem(
                          value: duration,
                          child: Text(duration),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDuration = value!;
                        });
                      },
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

                    if (nameController.text.trim().isEmpty ||
                        locationController.text.trim().isEmpty ||
                        price == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields correctly'),
                        ),
                      );
                      return;
                    }

                    if (isEdit) {
                      await apiService.updateGym(
                        gymId: gym['id'],
                        name: nameController.text.trim(),
                        location: locationController.text.trim(),
                        price: price,
                        priceDuration: selectedDuration,
                      );
                    } else {
                      await apiService.createGym(
                        name: nameController.text.trim(),
                        location: locationController.text.trim(),
                        price: price,
                        priceDuration: selectedDuration,
                      );
                    }

                    if (!context.mounted) return;

                    Navigator.pop(context);
                    fetchGyms();
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

  Future<void> confirmDelete(Map gym) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Gym'),
          content: Text('Are you sure you want to delete ${gym['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await apiService.deleteGym(gym['id']);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gym deleted')),
    );

    fetchGyms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Manage Gyms'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showGymDialog(),
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchGyms,
              child: gyms.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(child: Text('No gyms added yet')),
                      ],
                    )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: gyms.length,
                  itemBuilder: (context, index) {
                    final gym = gyms[index];

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
                            Icons.fitness_center,
                            color: Color(0xFF1B5E20),
                          ),
                          const SizedBox(width: 12),
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
                                Text(gym['location']),
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
                          IconButton(
                            onPressed: () => showGymDialog(gym: gym),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => confirmDelete(gym),
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