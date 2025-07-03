import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:houzy/repository/screens/stripeservice.dart';

class PaymentScreen extends StatefulWidget {
  final String serviceTitle;
  final String sizeLabel;
  final int? selectedProfessionals;
  final int? selectedHours;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final int? durationInMonths;
  final int price;
  final String fullAddress;
  final String city;
  final String label;

  const PaymentScreen({
    super.key,
    required this.serviceTitle,
    required this.sizeLabel,
    required this.selectedProfessionals,
    required this.selectedHours,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.durationInMonths,
    required this.price,
    required this.fullAddress,
    required this.city,
    required this.label,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final priceStr = NumberFormat.currency(locale: 'en_AE', symbol: 'AED ').format(widget.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Booking Summary'),
            _summaryRow('Service', widget.serviceTitle),
            _summaryRow('Size', widget.sizeLabel),
            if (widget.selectedProfessionals != null)
              _summaryRow('Professionals per visit', '${widget.selectedProfessionals}'),
            if (widget.selectedHours != null)
              _summaryRow('Hours per visit', '${widget.selectedHours}'),
            _summaryRow('Date', DateFormat('MMM d, yyyy').format(widget.selectedDate)),
            _summaryRow('Time', widget.selectedTimeSlot),
            if (widget.durationInMonths != null)
              _summaryRow('Plan Duration', '${widget.durationInMonths} Months'),
            const Divider(height: 30),

            _sectionTitle('Address'),
            Text(widget.fullAddress),
            Text('${widget.city}, UAE'),
            Text('Label: ${widget.label}'),
            const SizedBox(height: 30),

            const Spacer(),

            Text('Total: $priceStr',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("💳 Initiating payment...")),
                      );

                      try {
                        final prefs = await SharedPreferences.getInstance();
                        final email = prefs.getString('userEmail') ?? '';
                        if (email.isEmpty) throw "User email not found";

                        // Fetch user ID from backend
                        final userDetailsResponse = await http.get(
                          Uri.parse("https://houzy-ozer.vercel.app/api/v1/mobile/user/getDetailsByEmail?email=$email"),
                          headers: {'Content-Type': 'application/json'},
                        );

                        if (userDetailsResponse.statusCode != 200) {
                          throw "Failed to fetch user details: ${userDetailsResponse.body}";
                        }

                        final decoded = jsonDecode(userDetailsResponse.body);
                        final userId = decoded?['data']?['user']?['id'];
                        if (userId == null) throw "User ID not found";

                        // Make Stripe payment
                        await Stripeservice.instance.makePayment(
                          amount: widget.price,
                          months: widget.durationInMonths ?? 1,
                          title: widget.serviceTitle,
                          email: email,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("✅ Payment successful")),
                        );

                        // ✅ Post booking summary
                        await _createSubscription(userId);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("✅ Booking saved successfully")),
                        );
                                        print("📦 Initiating payment for ${widget.serviceTitle} - Amount: ${widget.price} AED");

                        // Optional: Navigate to success screen or home
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("❌ Error: $e")),
                        );
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
                    
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.orange,
              ),
              icon: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.payment),
              label: Text(isLoading ? 'Processing...' : 'Pay Now'),

            ),
            
          ],
          
        ),
      ),
      
    );
    
  }


  /// 🔹 POST booking summary to backend
  Future<void> _createSubscription(String userId) async {
    final url = Uri.parse('https://houzy-ozer.vercel.app/api/v1/mobile/subscription');
    final body = {
      "userId": userId,
      "planTitle": widget.serviceTitle,
      "price": widget.price,
      "months": widget.durationInMonths ?? 1,
      "fullAddress": widget.fullAddress,
      "city": widget.city,
      "label": widget.label,
      "selectedProfessionals": widget.selectedProfessionals,
      "selectedHours": widget.selectedHours,
      "date": widget.selectedDate.toIso8601String(),
      "timeSlot": widget.selectedTimeSlot,
      "sizeLabel": widget.sizeLabel,
    };

    print("📦 Posting booking summary: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
      print("✅ Booking summary posted successfully to $url");

    print("📥 Backend response: ${response.statusCode} - ${response.body}");

    if (response.statusCode != 200) {
      throw "Failed to save booking: ${response.body}";
    }
  }

  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _summaryRow(String title, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            Text(value),
          ],
        ),
      );

