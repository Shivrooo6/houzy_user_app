import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:houzy/repository/screens/stripeservice.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Checkout extends StatefulWidget {
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final String sizeLabel;
  final int price;
  final String serviceTitle;
  final int? selectedHours;
  final int? selectedProfessionals;
  final int? durationInMonths;

  const Checkout({
    super.key,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.sizeLabel,
    required this.price,
    required this.serviceTitle,
    this.selectedHours,
    this.selectedProfessionals,
    this.durationInMonths,
  });

  @override
  State<Checkout> createState() => _CheckoutUIState();
}

class _CheckoutUIState extends State<Checkout> {
  bool isLoading = false;

  final houseNoController = TextEditingController();
  final streetController = TextEditingController();
  final areaController = TextEditingController();
  final cityController = TextEditingController();
  final landmarkController = TextEditingController();

  String _selectedLabel = 'Home';

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = 'your_stripe_publishable_key_here'; // Replace this!
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    houseNoController.text = prefs.getString('houseNo') ?? '';
    streetController.text = prefs.getString('street') ?? '';
    areaController.text = prefs.getString('area') ?? '';
    cityController.text = prefs.getString('city') ?? '';
    landmarkController.text = prefs.getString('landmark') ?? '';
  }

  Future<void> _saveAddressToBackend() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw "User not logged in";

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final place = placemarks.isNotEmpty ? placemarks.first : null;

    final body = {
      "userId": user.uid,
      "label": _selectedLabel,
      "street": "${houseNoController.text.trim()}, "
                "${streetController.text.trim()}, "
                "${areaController.text.trim()}",
      "city": (place?.locality?.isNotEmpty ?? false)
          ? place!.locality
          : cityController.text.trim(),
      "state": place?.administrativeArea ?? "",
      "country": place?.country ?? "UAE",
      "pincode": place?.postalCode ?? "",
      "lat": position.latitude,
      "lng": position.longitude,
    };

    debugPrint("Saving address: ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse("https://houzy-ozer.vercel.app/api/v1/mobile/user/location"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    debugPrint("Backend response: ${response.statusCode} - ${response.body}");

    if (response.statusCode != 200) {
      String message = "Failed to save address";
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'];
        }
      } catch (_) {}
      throw message;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Booking Checkout'),
          backgroundColor: Colors.orange,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildBookingSummary(),
              const SizedBox(height: 20),
              _buildStructuredAddressForm(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.orange,
                ),
                icon: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.payment),
                label: Text(isLoading ? 'Processing...' : 'Continue to Pay'),
                onPressed: () async {
                  if (houseNoController.text.trim().isEmpty ||
                      streetController.text.trim().isEmpty ||
                      areaController.text.trim().isEmpty ||
                      cityController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all address fields")),
                    );
                    return;
                  }

                  setState(() => isLoading = true);
                  try {
                    await _saveAddressToBackend();
                    Stripeservice.instance.makePayment(); // continue payment
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Error: $e')),
                    );
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
              ),
            ],
          ),
        ),
      );

  Widget _buildStructuredAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _customTextField(houseNoController, 'House / Flat Number'),
        _customTextField(streetController, 'Street / Road'),
        _customTextField(areaController, 'Area / Locality'),
        _customTextField(cityController, 'City'),
        _customTextField(landmarkController, 'Landmark (Optional)', required: false),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedLabel,
          items: ['Home', 'Work', 'Other'].map((label) {
            return DropdownMenuItem(value: label, child: Text(label));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedLabel = val);
          },
          decoration: const InputDecoration(
            labelText: 'Save Address As',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _customTextField(TextEditingController controller, String label,
      {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    final priceStr =
        NumberFormat.currency(locale: 'en_AE', symbol: 'AED ').format(widget.price);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Booking Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _summaryRow('Service', widget.serviceTitle),
          _summaryRow('Size', widget.sizeLabel),
          if (widget.selectedProfessionals != null)
            _summaryRow('Professionals per visit', '${widget.selectedProfessionals}'),
          if (widget.selectedHours != null)
            _summaryRow('Hours per visit', '${widget.selectedHours}'),
          _summaryRow('Start Date',
              DateFormat('MMM d, yyyy').format(widget.selectedDate)),
          _summaryRow('Time', widget.selectedTimeSlot),
          if (widget.durationInMonths != null)
            _summaryRow('Plan Duration', '${widget.durationInMonths} Months'),
          const Divider(),
          _summaryRow('Total', priceStr, isBold: true),
          const SizedBox(height: 4),
          Text(
            widget.durationInMonths != null
                ? 'AED ${widget.price ~/ widget.durationInMonths!} per month'
                : 'One-time payment',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(val,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
