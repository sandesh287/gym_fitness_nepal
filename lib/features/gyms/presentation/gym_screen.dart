import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/widgets/empty_state.dart';
import 'gym_detail_screen.dart';

class GymsScreen extends StatefulWidget {
  final String? classTitle;

  const GymsScreen({
    super.key,
    this.classTitle,
  });

  @override
  State<GymsScreen> createState() => _GymsScreenState();
}

class _GymsScreenState extends State<GymsScreen> {
  final apiService = ApiService();

  final searchController = TextEditingController();

  List allGyms = [];
  List gyms = [];
  List allClasses = [];

  bool isLoading = true;

  String selectedClass = 'All';
  String selectedLocation = 'All';
  String selectedPrice = 'All';

  @override
  void initState() {
    super.initState();
    fetchGyms();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchGyms() async {
    try {
      final gymResult = await apiService.getGyms();
      final classResult = await apiService.getClasses();

      allGyms = gymResult;
      allClasses = classResult;

      if (widget.classTitle != null) {
        selectedClass = widget.classTitle!;
      }

      final filteredGyms = await apiService.getGyms(
        classTitle: selectedClass,
      );

      setState(() {
        gyms = filteredGyms;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load gyms: $e')),
      );
    }
  }

  Future<void> applyFilters() async {
    int? minPrice;
    int? maxPrice;

    if (selectedPrice == 'Below Rs. 2,500') {
      maxPrice = 2499;
    } else if (selectedPrice == 'Rs. 2,500 - Rs. 3,000') {
      minPrice = 2500;
      maxPrice = 3000;
    } else if (selectedPrice == 'Above Rs. 3,000') {
      minPrice = 3001;
    }

    try {
      final result = await apiService.getGyms(
        search: searchController.text.trim(),
        location: selectedLocation,
        classTitle: selectedClass,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      setState(() {
        gyms = result;
      });
    } catch (e) {
      // optional: show error later
    }
  }

  List<String> get classOptions {
    final names = allClasses.map((c) => c['title'].toString()).toSet().toList();
    names.sort();
    return ['All', ...names];
  }

  List<String> get locationOptions {
    final locations =
        allGyms.map((gym) => gym['location'].toString()).toSet().toList();
    locations.sort();
    return ['All', ...locations];
  }

  List<String> get priceOptions {
    return [
      'All',
      'Below Rs. 2,500',
      'Rs. 2,500 - Rs. 3,000',
      'Above Rs. 3,000',
    ];
  }

  void clearFilters() {
    searchController.clear();

    setState(() {
      selectedClass = widget.classTitle ?? 'All';
      selectedLocation = 'All';
      selectedPrice = 'All';
    });

    applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = searchController.text.isNotEmpty ||
        selectedClass != 'All' ||
        selectedLocation != 'All' ||
        selectedPrice != 'All';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.classTitle == null
              ? 'Nearby Gyms'
              : '${widget.classTitle} Gyms',
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          if (hasFilters)
            IconButton(
              onPressed: clearFilters,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B5E20),
              ),
            )
          : Column(
              children: [
                _filterSection(),
                Expanded(
                  child: gyms.isEmpty
                      ? EmptyState(
                          icon: Icons.fitness_center,
                          title: 'No gyms found',
                          message:
                              'Try changing your search or filter options.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: gyms.length,
                          itemBuilder: (context, index) {
                            final gym = gyms[index];
                            return _gymCard(gym);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _filterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: (_) => applyFilters(),
            decoration: const InputDecoration(
              hintText: 'Search by gym name or location',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _dropdownFilter(
                  label: 'Class',
                  value: selectedClass,
                  options: classOptions,
                  onChanged: (value) {
                    setState(() {
                      selectedClass = value!;
                    });
                    applyFilters();
                  },
                ),
                const SizedBox(width: 10),
                _dropdownFilter(
                  label: 'Location',
                  value: selectedLocation,
                  options: locationOptions,
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value!;
                    });
                    applyFilters();
                  },
                ),
                const SizedBox(width: 10),
                _dropdownFilter(
                  label: 'Price',
                  value: selectedPrice,
                  options: priceOptions,
                  onChanged: (value) {
                    setState(() {
                      selectedPrice = value!;
                    });
                    applyFilters();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownFilter({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text('$label: $option'),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _gymCard(Map gym) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GymDetailScreen(gym: gym),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
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
  }
}