import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class Stripeservice {
  Stripeservice._();
  static final Stripeservice instance = Stripeservice._();

  Future<void> makePayment() async {
    try {
      String clientSecret = await _createPaymentIntent(10, "usd");

      if (clientSecret.isEmpty) {
        print("Client secret is empty");
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Houzy',
          billingDetails: const BillingDetails(
            email: 'karam123@gmail.com',
          ),
        ),
      );

      await _processPayment();
    } catch (e) {
      print("Payment error: $e");
    }
  }

  Future<String> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();

      Map<String, dynamic> body = {
        "plan": {
          "price": _calculateAmount(amount),
          "months": 1,
          "title": "example"
        },
        "email": "karam123@gmail.com"
      };

      final response = await dio.post(
        'https://houzy-ozer.vercel.app/api/checkout/mobile',
        data: body,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      final data = response.data;

      if (data != null && data['clientSecret'] != null) {
        return data['clientSecret'];
      } else {
        print("Invalid clientSecret in response: $data");
        return '';
      }
    } catch (e) {
      print("Error creating payment intent: $e");
      return '';
    }
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print("✅ Payment completed successfully");
    } on StripeException catch (e) {
      print("❌ StripeException: ${e.error.localizedMessage}");
    } catch (e, stackTrace) {
      print("❌ Unhandled error: $e");
      print("🔍 Stack trace:\n$stackTrace");
    }
  }

  String _calculateAmount(int amount) {
    return (amount ).toString(); // Convert dollars to cents
  }
}
