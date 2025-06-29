import 'package:flutter/material.dart';
import 'package:houzy/paymentscreen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => PaymentScreen(
      serviceTitle: widget.serviceTitle,
      sizeLabel: widget.sizeLabel,
      selectedProfessionals: widget.selectedProfessionals,
      selectedHours: widget.selectedHours,
      selectedDate: widget.selectedDate,
      selectedTimeSlot: widget.selectedTimeSlot,
      durationInMonths: widget.durationInMonths,
      price: widget.price,
      fullAddress: "${houseNoController.text.trim()}, "
          "${streetController.text.trim()}, "
          "${areaController.text.trim()}",
      city: cityController.text.trim(),
      label: _selectedLabel,
    ),
  ),
);
              }
            ),
          ],
        ),
      ),
    );
  }

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
          items: ['Home', 'Work', 'Other']
              .map((label) => DropdownMenuItem(value: label, child: Text(label)))
              .toList(),
          onChanged: (val) => setState(() => _selectedLabel = val ?? 'Home'),
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
