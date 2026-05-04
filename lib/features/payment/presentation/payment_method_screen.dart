import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import 'package:khalti_checkout_flutter/khalti_checkout_flutter.dart';
import '../../../core/storage/auth_storage.dart';
import '../../home/presentation/home_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Map gym;
  final Map plan;

  const PaymentMethodScreen({
    super.key,
    required this.gym,
    required this.plan,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  bool isLoading = false;
  String selectedPayment = 'khalti';
  final apiService = ApiService();
  final authStorage = AuthStorage();

  final String khaltiPublicKey = '9bc30054d17d4c338e3cf075e2ef49be';

  Future<void> payMock() async {
    if (selectedPayment == 'esewa') {
      await payWithEsewaMock();
      return;
    }

    await payWithKhalti();
  }

  Future<void> payWithEsewaMock() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userPhone = await authStorage.getPhone() ?? '';

      final result = await apiService.mockEsewaPayment(
        amount: widget.plan['price'],
        purchaseOrderId:
            'plan_${widget.plan['id']}_${DateTime.now().millisecondsSinceEpoch}',
        purchaseOrderName: widget.plan['title'],
        customerPhone: userPhone,
      );

      if (result['success'] == true) {
        await apiService.createMembership(
          userPhone: userPhone,
          gymId: widget.gym['id'],
          gymName: widget.gym['name'],
          planId: widget.plan['id'],
          planTitle: widget.plan['title'],
          planPrice: widget.plan['display_price'],
          durationDays: widget.plan['duration_days'],
          paymentMethod: 'esewa',
          pidx: result['transaction_id'],
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('eSewa payment successful')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('eSewa payment failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> payWithKhalti() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userPhone = await authStorage.getPhone() ?? '';

      final response = await apiService.initiateKhaltiPayment(
        amount: widget.plan['price'] * 100,
        purchaseOrderId: 'plan_${widget.plan['id']}_${DateTime.now().millisecondsSinceEpoch}',
        purchaseOrderName: widget.plan['title'],
        customerName: 'Test User',
        customerEmail: 'test@example.com',
        customerPhone: userPhone,
      );

      final pidx = response['pidx'];

      final payConfig = KhaltiPayConfig(
        publicKey: khaltiPublicKey,
        pidx: pidx,
        environment: Environment.test,
      );

      await Khalti.init(
        enableDebugging: true,
        payConfig: payConfig,
        onPaymentResult: (paymentResult, khalti) async {
          try {
            log(paymentResult.toString());

            final verify = await apiService.verifyKhaltiPayment(
              paymentResult.payload?.pidx ?? '',
            );

            if (!mounted) return;

            if (verify['success'] == true) {
              await apiService.createMembership(
                userPhone: userPhone,
                gymId: widget.gym['id'],
                gymName: widget.gym['name'],
                planId: widget.plan['id'],
                planTitle: widget.plan['title'],
                planPrice: widget.plan['display_price'],
                durationDays: widget.plan['duration_days'],
                paymentMethod: 'khalti',
                pidx: paymentResult.payload?.pidx ?? '',
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment verified successfully')),
              );

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(),
                ),
                (route) => false,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment not completed: ${verify['status']}')),
              );
            }
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification error: $e')),
            );
          }
        },
        onMessage: (
          khalti, {
          description,
          statusCode,
          event,
          needsPaymentConfirmation,
        }) async {
          log('Khalti message: $description');
        },
        onReturn: () {
          log('Returned from Khalti');
        },
      ).then((khalti) {
        if (!mounted) return;
        khalti.open(context);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Khalti payment failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKhalti = selectedPayment == 'khalti';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Choose Payment'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCard(),

            const SizedBox(height: 24),

            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _paymentCard(
              id: 'khalti',
              title: 'Khalti Digital Wallet',
              logoText: 'K',
              color: const Color(0xFF5C2D91),
            ),

            const SizedBox(height: 12),

            _paymentCard(
              id: 'esewa',
              title: 'eSewa Digital Wallet',
              logoText: 'e',
              color: const Color(0xFF60BB46),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : payMock,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isKhalti ? const Color(0xFF5C2D91) : const Color(0xFF60BB46),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isKhalti ? 'Pay with Khalti' : 'Pay with eSewa',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purchase Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.gym['name'],
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            widget.plan['title'],
            style: const TextStyle(color: Colors.black54),
          ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.plan['display_price'],
                style: const TextStyle(
                  color: Color(0xFF1B5E20),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _paymentCard({
    required String id,
    required String title,
    required String logoText,
    required Color color,
  }) {
    final isSelected = selectedPayment == id;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPayment = id;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Text(
                logoText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? color : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}