import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../shared/widgets/empty_state.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final apiService = ApiService();
  final authStorage = AuthStorage();

  List bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookingHistory();
  }

  Future<void> fetchBookingHistory() async {
    final phone = await authStorage.getPhone();

    if (phone == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final result = await apiService.getBookingHistory(phone);

      setState(() {
        bookings = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bookings: $e')),
      );
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    final phone = await authStorage.getPhone();

    if (phone == null) return;

    final result = await apiService.cancelBooking(
      bookingId: bookingId,
      userPhone: phone,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );

    fetchBookingHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Booking History'),
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
              onRefresh: fetchBookingHistory,
              child: bookings.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        EmptyState(
                          icon: Icons.calendar_month,
                          title: 'No bookings yet',
                          message:
                              'Book a class from any gym and your bookings will appear here.',
                        ),
                      ],
                    )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking['class_title'],
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Time: ${booking['time']}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                if (booking['status'] == 'booked')
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () => cancelBooking(booking['id']),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Cancel Booking'),
                                    ),
                                  )
                                else
                                  const Text(
                                    'Cancelled',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                
                                Text(
                                  'Status: ${booking['status']}',
                                  style: TextStyle(
                                    color: booking['status'] == 'booked' ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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