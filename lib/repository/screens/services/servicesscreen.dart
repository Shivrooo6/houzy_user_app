import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:houzy/repository/screens/checkout/checkout.dart';

class Corporate extends StatefulWidget {
  const Corporate({super.key});

  @override
  State<Corporate> createState() => _CorporateState();
}

class _CorporateState extends State<Corporate> {
  bool showCorporate = false;
  bool showAirbnb = false;

  int selectedDurationIndex = 0;
  int selectedWorkerCount = 1;
  bool isPetFriendly = false;
  TextEditingController specialInstructionsController = TextEditingController();
  DateTime? selectedDate;
  String? selectedTimeSlot;

  final List<String> allTimeSlots = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM',
  ];

  final List<Map<String, dynamic>> durations = [
    {'label': '1 Hour', 'price': 60},
    {'label': '1.5 Hours', 'price': 85},
    {'label': '2 Hours', 'price': 110},
    {'label': '2.5 Hours', 'price': 135},
    {'label': '3.5 Hours', 'price': 160},
    {'label': '4 Hours', 'price': 180},
  ];

  String selectedServiceType = '';

  @override
  Widget build(BuildContext context) {
    int basePrice = durations[selectedDurationIndex]['price'];
    int totalPrice = (isPetFriendly ? basePrice + 25 : basePrice) * selectedWorkerCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(context),
              const SizedBox(height: 12),

              // Corporate Services Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: showCorporate ? Colors.orange.shade50 : Colors.white,
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    children: [
                      Icon(Icons.business_center_outlined, color: Colors.orange.shade700),
                      const SizedBox(width: 10),
                      const Text("Corporate Services", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  initiallyExpanded: showCorporate,
                  onExpansionChanged: (val) => setState(() {
                    showCorporate = val;
                    if (val) {
                      showAirbnb = false;
                      selectedServiceType = 'Corporate';
                    }
                  }),
                  children: [_buildBookingOptions(totalPrice)],
                ),
              ),

              const SizedBox(height: 12),

              // Airbnb Services Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: showAirbnb ? Colors.orange.shade50 : Colors.white,
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Row(
                    children: [
                      Icon(Icons.home_work_outlined, color: Colors.orange.shade700),
                      const SizedBox(width: 10),
                      const Text("Airbnb Services", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  initiallyExpanded: showAirbnb,
                  onExpansionChanged: (val) => setState(() {
                    showAirbnb = val;
                    if (val) {
                      showCorporate = false;
                      selectedServiceType = 'Airbnb';
                    }
                  }),
                  children: [_buildBookingOptions(totalPrice)],
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Houzy – Your Professional Cleaner",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Image.asset('assets/images/houzylogoimage.png', height: 40),
          const Spacer(),
          IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () {}),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : const AssetImage('assets/images/placeholder.png') as ImageProvider,
                      ),
                      const SizedBox(height: 8),
                      Text(user?.email ?? 'No email', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Profile'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/account');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                        onTap: () async {
                          Navigator.pop(context);
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/images/placeholder.png') as ImageProvider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingOptions(int totalPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text("Select Duration", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(durations.length, (index) {
          bool isSelected = selectedDurationIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedDurationIndex = index),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange[100] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? Colors.orange : Colors.transparent),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(durations[index]['label'])),
                  Text("AED ${durations[index]['price']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
        const Text("Select Workers", style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 10,
          children: List.generate(4, (index) {
            int worker = index + 1;
            bool isSelected = selectedWorkerCount == worker;
            return ChoiceChip(
              label: Text("$worker Needed"),
              selected: isSelected,
              onSelected: (_) => setState(() => selectedWorkerCount = worker),
              selectedColor: Colors.orange[200],
            );
          }),
        ),

        const SizedBox(height: 16),
        _buildDatePicker(),
        const SizedBox(height: 16),
        _buildTimePicker(),
        const SizedBox(height: 16),
        _buildBookingSummary(selectedServiceType, totalPrice),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: (selectedDate != null && selectedTimeSlot != null)
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Checkout(
                          selectedDate: selectedDate!,
                          selectedTimeSlot: selectedTimeSlot!,
                          sizeLabel: durations[selectedDurationIndex]['label'],
                          price: totalPrice,serviceTitle: "6 Month Cleaning Plan",
                        ),
                      ),
                    );
                  }
                : null,
            child: const Text("Continue to Checkout"),
          ),
        )
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (picked != null) setState(() => selectedDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null ? DateFormat('MMM d, yyyy').format(selectedDate!) : 'Select a date',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Time Slot", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: allTimeSlots.map((slot) {
            bool isSelected = selectedTimeSlot == slot;
            return GestureDetector(
              onTap: () => setState(() => selectedTimeSlot = slot),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange[100] : Colors.white,
                  border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(slot),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookingSummary(String type, int price) {
    final currencyFormat = NumberFormat.currency(locale: 'en_AE', symbol: 'AED ');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Service Type: $type", style: const TextStyle(fontWeight: FontWeight.bold)),
          _summaryRow("Duration", durations[selectedDurationIndex]['label']),
          _summaryRow("Workers", "$selectedWorkerCount"),
          if (selectedDate != null)
            _summaryRow("Date", DateFormat('MMM d, yyyy').format(selectedDate!)),
          if (selectedTimeSlot != null)
            _summaryRow("Time", selectedTimeSlot!),
          const Divider(),
          _summaryRow("Total", currencyFormat.format(price), isBold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
