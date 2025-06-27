import 'package:flutter/material.dart';
import 'package:houzy/repository/screens/checkout/checkout.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SixMonthPlan extends StatefulWidget {

  const SixMonthPlan({super.key});

  @override
  State<SixMonthPlan> createState() => _SixMonthPlanState();
}

class _SixMonthPlanState extends State<SixMonthPlan> {
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
          price: total,serviceTitle: "6 Month Cleaning Plan",
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

  Widget _buildBookingSummary() {
    int ratePerMonth = 230; // You can adjust monthly rate
    int total = ratePerMonth * 6; // Total for 6 months

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
            const Text("Booking Summary",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            const Text("Service: 6 Month Cleaning Plan"),
            Text("Professionals per visit: $selectedProfessionals"),
            Text("Hours per visit: $selectedHours"),
            Text("Start Date: ${selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : 'Select a date'}"),
            const SizedBox(height: 10),
            Text("Total for 6 Months: AED $total",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => _handlePayment(total),
              child: Text("Pay AED $total for 6 Months"),
            )
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
            _buildTopHeader(),
            _buildBookingSummary(),
          ],
        ),
      ),
    );
  }
}
