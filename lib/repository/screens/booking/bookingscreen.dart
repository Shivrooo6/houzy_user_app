import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String formatAED(dynamic value) {
    return NumberFormat.currency(locale: 'en_AE', symbol: 'AED ').format(value ?? 0);
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Image.asset('assets/images/houzylogoimage.png', height: 36),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
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
                        backgroundImage: currentUser?.photoURL != null
                            ? NetworkImage(currentUser!.photoURL!)
                            : const AssetImage('assets/images/placeholder.png') as ImageProvider,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentUser?.email ?? 'No email',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
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
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
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
              backgroundImage: currentUser?.photoURL != null
                  ? NetworkImage(currentUser!.photoURL!)
                  : const AssetImage('assets/images/placeholder.png') as ImageProvider,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text("Please sign in."));
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text("My Bookings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('email', isEqualTo: currentUser!.email)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No bookings found."));
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final data = bookings[index].data() as Map<String, dynamic>;

                    final cleaningDate = (data['date'] as Timestamp?)?.toDate();
                    final timeSlot = data['timeSlot'] ?? 'N/A';
                    final bookingTime = (data['timestamp'] as Timestamp?)?.toDate();
                    final workers = data['workers']?.toString() ?? 'N/A';
                    final hours = data['duration']?.toString() ?? 'N/A';
                    final instructions = data['instructions']?.toString().trim() ?? '';
                    final price = data['price'] ?? 0;
                    final email = data['email'] ?? 'N/A';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cleaning on ${cleaningDate != null ? DateFormat('dd MMM yyyy').format(cleaningDate) : 'Unknown'} at $timeSlot",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _summaryRow("Hours", hours),
                            _summaryRow("Workers", workers),
                            if (instructions.isNotEmpty)
                              _summaryRow("Instructions", instructions),
                            _summaryRow("Email", email),
                            if (bookingTime != null)
                              _summaryRow("Booked On", DateFormat('MMM d, yyyy • hh:mm a').format(bookingTime)),
                            const Divider(),
                            _summaryRow("Total", formatAED(price), isBold: true),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                                onPressed: () {
                                  // Navigate to details if needed
                                },
                                child: const Text("View Details"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
