import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      // baseUrl: 'http://127.0.0.1:8000/api/v1',
      baseUrl: 'https://gym-fitness-nepal-backend.onrender.com/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );


  // OTP request and response
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await _dio.post('/auth/send-otp', data: {'phone': phone});

    return response.data;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final response = await _dio.post(
      '/auth/verify-otp',
      data: {'phone': phone, 'otp': otp},
    );

    return response.data;
  }


  // Search
  Future<List<dynamic>> getGyms({
    String? search,
    String? location,
    String? classTitle,
    int? minPrice,
    int? maxPrice,
  }) async {
    final response = await _dio.get(
      '/gyms/',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (location != null && location != 'All') 'location': location,
        if (classTitle != null && classTitle != 'All') 'class_title': classTitle,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
      },
    );

    return response.data['data'];
  }


  // Gym Membership Plans
  Future<List<dynamic>> getGymPlans(int gymId) async {
    final response = await _dio.get('/membership-plans/gym/$gymId');

    return response.data['data'];
  }

  Future<List<dynamic>> getAllMembershipPlans() async {
    final response = await _dio.get('/membership-plans/');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> createMembershipPlan({
    required int gymId,
    required String gymName,
    required String title,
    required String duration,
    required int durationDays,
    required int price,
    required String features,
  }) async {
    final response = await _dio.post(
      '/membership-plans/',
      data: {
        'gym_id': gymId,
        'gym_name': gymName,
        'title': title,
        'duration': duration,
        'duration_days': durationDays,
        'price': price,
        'features': features,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> updateMembershipPlan({
    required int planId,
    required int gymId,
    required String gymName,
    required String title,
    required String duration,
    required int durationDays,
    required int price,
    required String features,
  }) async {
    final response = await _dio.put(
      '/membership-plans/$planId',
      data: {
        'gym_id': gymId,
        'gym_name': gymName,
        'title': title,
        'duration': duration,
        'duration_days': durationDays,
        'price': price,
        'features': features,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> deleteMembershipPlan(int planId) async {
    final response = await _dio.delete('/membership-plans/$planId');
    return response.data;
  }


  // Payment Gateway
  Future<Map<String, dynamic>> initiateKhaltiPayment({
    required int amount,
    required String purchaseOrderId,
    required String purchaseOrderName,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    final response = await _dio.post(
      '/payments/khalti/initiate',
      data: {
        'amount': amount,
        'purchase_order_id': purchaseOrderId,
        'purchase_order_name': purchaseOrderName,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'customer_phone': customerPhone,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> verifyKhaltiPayment(String pidx) async {
    final response = await _dio.post(
      '/payments/khalti/lookup',
      data: {
        'pidx': pidx,
      },
    );

    return response.data;
  }


  // Gym Membership
  Future<Map<String, dynamic>> createMembership({
    required String userPhone,
    required int gymId,
    required String gymName,
    required int planId,
    required String planTitle,
    required String planPrice,
    required int durationDays,
    required String paymentMethod,
    required String pidx,
  }) async {
    final response = await _dio.post(
      '/memberships/',
      data: {
        'user_phone': userPhone,
        'gym_id': gymId,
        'gym_name': gymName,
        'plan_id': planId,
        'plan_title': planTitle,
        'plan_price': planPrice,
        'duration_days': durationDays,
        'payment_method': paymentMethod,
        'pidx': pidx,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getActiveMembership(String userPhone) async {
    final response = await _dio.get(
      '/memberships/active',
      queryParameters: {
        'user_phone': userPhone,
      },
    );

    return response.data;
  }

  Future<List<dynamic>> getMembershipHistory(String userPhone) async {
    final response = await _dio.get(
      '/memberships/history',
      queryParameters: {
        'user_phone': userPhone,
      },
    );

    return response.data['data'];
  }


  // Gym Classes Booking
  Future<List<dynamic>> getClasses({int? gymId}) async {
    final response = await _dio.get(
      '/bookings/classes',
      queryParameters: gymId != null ? {'gym_id': gymId} : null,
    );

    return response.data['data'];
  }

  Future<Map<String, dynamic>> bookClass({
    required int classId,
    required String userPhone,
  }) async {
    final response = await _dio.post(
      '/bookings/book',
      queryParameters: {
        'class_id': classId,
        'user_phone': userPhone,
      },
    );

    return response.data;
  }

  Future<List<dynamic>> getBookingHistory(String userPhone) async {
    final response = await _dio.get(
      '/bookings/history',
      queryParameters: {
        'user_phone': userPhone,
      },
    );

    return response.data['data'];
  }

  Future<Map<String, dynamic>> cancelBooking({
    required int bookingId,
    required String userPhone,
  }) async {
    final response = await _dio.patch(
      '/bookings/$bookingId/cancel',
      queryParameters: {
        'user_phone': userPhone,
      },
    );

    return response.data;
  }


  // Profile
  Future<Map<String, dynamic>> getProfile(String phone) async {
    final response = await _dio.get(
      '/users/profile',
      queryParameters: {'phone': phone},
    );

    return response.data['data'];
  }

  Future<Map<String, dynamic>> updateProfile({
    required String phone,
    String? name,
    String? email,
  }) async {
    final response = await _dio.put(
      '/users/profile',
      data: {
        'phone': phone,
        'name': name,
        'email': email,
      },
    );

    return response.data['data'];
  }


  // Gyms
  Future<Map<String, dynamic>> createGym({
    required String name,
    required String location,
    required int price,
    required String priceDuration,
  }) async {
    final response = await _dio.post(
      '/gyms/',
      data: {
        'name': name,
        'location': location,
        'price': price,
        'price_duration': priceDuration,
        'rating': 0.0,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> updateGym({
    required int gymId,
    required String name,
    required String location,
    required int price,
    required String priceDuration,
  }) async {
    final response = await _dio.put(
      '/gyms/$gymId',
      data: {
        'name': name,
        'location': location,
        'price': price,
        'price_duration': priceDuration,
        'rating': 0.0,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> deleteGym(int gymId) async {
    final response = await _dio.delete('/gyms/$gymId');
    return response.data;
  }


  // Gym classes inside Gym (from admin panel)
  Future<Map<String, dynamic>> createClass({
    required int gymId,
    required String gymName,
    required String title,
    required String trainer,
    required String time,
    required String duration,
    required int capacity,
  }) async {
    final response = await _dio.post(
      '/bookings/classes',
      data: {
        'gym_id': gymId,
        'gym_name': gymName,
        'title': title,
        'trainer': trainer,
        'time': time,
        'duration': duration,
        'capacity': capacity,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> updateClass({
    required int classId,
    required int gymId,
    required String gymName,
    required String title,
    required String trainer,
    required String time,
    required String duration,
    required int capacity,
    required int availableSlots,
  }) async {
    final response = await _dio.put(
      '/bookings/classes/$classId',
      data: {
        'gym_id': gymId,
        'gym_name': gymName,
        'title': title,
        'trainer': trainer,
        'time': time,
        'duration': duration,
        'capacity': capacity,
        'available_slots': availableSlots,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> deleteClass(int classId) async {
    final response = await _dio.delete('/bookings/classes/$classId');
    return response.data;
  }


  // esewa mock payment
  Future<Map<String, dynamic>> mockEsewaPayment({
    required int amount,
    required String purchaseOrderId,
    required String purchaseOrderName,
    required String customerPhone,
  }) async {
    final response = await _dio.post(
      '/payments/esewa/mock-pay',
      data: {
        'amount': amount,
        'purchase_order_id': purchaseOrderId,
        'purchase_order_name': purchaseOrderName,
        'customer_phone': customerPhone,
      },
    );

    return response.data;
  }
}
