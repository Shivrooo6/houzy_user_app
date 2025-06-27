import 'package:flutter/material.dart';
import 'package:houzy/repository/screens/checkout/checkout.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TwelveMonth extends StatefulWidget {
  const TwelveMonth({super.key});

  @override
  State<TwelveMonth> createState() => _TwelveMonthPlanState();
}

class _TwelveMonthPlanState extends State<TwelveMonth> {
  int selectedHours = 2;
  int selectedProfessionals = 1;
  String specialInstructions = '';
  DateTime? selectedDate;
  String? selectedTime;

  final List<String> includedTasks = [
    'Dusting all surfaces and furniture',
    'Vacuuming carpets and rugs',
    'Mopping hard floors',
    'Kitchen cleaning (counters, sink, stovetop)',
    'Bathroom cleaning (toilet, sink, shower/tub)',
    'Emptying trash bins',
    'Making beds',
  ];

  final List<String> timeSlots = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM',
    '4:00 PM', '5:00 PM'
  ];

  Future<void> _handlePayment(int total) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Checkout(
          selectedDate: selectedDate ?? DateTime.now(),
          selectedTimeSlot: selectedTime ?? '10:00 AM - 12:00 PM',
          sizeLabel: '1 BHK',
          price: total,
          serviceTitle: "12 Month Cleaning Plan",
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                      Text(user?.email ?? 'No email',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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

  Widget _buildBadge(String text, IconData icon, {Color? bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.orange),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopHeader(),
          const SizedBox(height: 10),
          const Text("12 Month Cleaning Plan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Weekly professional cleaning service for a full year."),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildBadge("AED 200/month", Icons.monetization_on),
              const SizedBox(width: 8),
              _buildBadge("Best Value Plan", Icons.thumb_up_alt_outlined, bgColor: Colors.orange.shade50),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/serviceimage1.png',
                height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionSelector(String title, int count, int selected, Function(int) onTap) {
    IconData icon = title.toLowerCase().contains("hour")
        ? Icons.timer_outlined
        : Icons.groups_outlined;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: List.generate(count, (i) {
                final index = i + 1;
                return ChoiceChip(
                  label: Text("$index"),
                  avatar: Icon(icon),
                  selected: selected == index,
                  onSelected: (_) => onTap(index),
                  selectedColor: Colors.orange.shade100,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsInput() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Any specific instructions?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Add any special instructions for the cleaning professional...",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => specialInstructions = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncludedSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What's Included",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ...includedTasks.map((task) => Row(
              children: [
                const Icon(Icons.check, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(task)),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("When would you like to start?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (date) => setState(() => selectedDate = date),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: timeSlots.map((slot) {
          return ChoiceChip(
            label: Text(slot),
            selected: selectedTime == slot,
            onSelected: (_) => setState(() => selectedTime = slot),
            selectedColor: Colors.orange.shade100,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookingSummary() {
    int monthlyRate = 200;
    int total = monthlyRate * 12;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.orange, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Booking Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            const Text("Service: 12 Month Cleaning Plan"),
            Text("Professionals per visit: $selectedProfessionals"),
            Text("Hours per visit: $selectedHours"),
            Text("Start Date: ${selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : 'Select a date'}"),
            const SizedBox(height: 10),
            Text("Total for 12 Months: AED $total",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => _handlePayment(total),
              child: Text("Pay AED $total for 12 Months"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderCard(),
            _buildIncludedSection(),
            _buildOptionSelector("Hours per visit", 6, selectedHours, (val) {
              setState(() => selectedHours = val);
            }),
            _buildOptionSelector("Professionals per visit", 4, selectedProfessionals, (val) {
              setState(() => selectedProfessionals = val);
            }),
            _buildInstructionsInput(),
            _buildDatePicker(),
            const SizedBox(height: 8),
            _buildTimeSlots(),
            const SizedBox(height: 16),
            _buildBookingSummary(),
          ],
        ),
      ),
    );
  }
}
