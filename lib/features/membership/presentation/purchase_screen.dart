import 'package:flutter/material.dart';
// import 'success_screen.dart';
import '../../payment/presentation/payment_method_screen.dart';

class PurchaseScreen extends StatelessWidget {
  final Map plan;
  final Map gym;

  const PurchaseScreen({
    super.key,
    required this.plan,
    required this.gym,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Purchase'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gym['name'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              plan['title'],
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              plan['price'],
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentMethodScreen(
                        gym: gym, 
                        plan: plan
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                ),
                child: const Text(
                  'Confirm Payment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}