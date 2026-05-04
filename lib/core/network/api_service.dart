import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

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

  Future<List<dynamic>> getGymPlans(int gymId) async {
    final response = await _dio.get('/gyms/$gymId/plans');

    return response.data['data'];
  }

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
}
