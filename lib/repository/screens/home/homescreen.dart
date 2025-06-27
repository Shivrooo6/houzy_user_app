import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:houzy/repository/screens/1monthservice/onemonth.dart';
import 'package:houzy/repository/screens/booking/bookingscreen.dart';
import 'package:houzy/repository/screens/demoservice/demoservice.dart';
import 'package:houzy/repository/screens/sixmonthplan.dart';
import 'package:houzy/repository/screens/threemonth.dart';
import 'package:houzy/repository/screens/twelvemonth.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isLoading = false;
  String currentAddress = 'Fetching location...';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _carouselTimer;

  final List<Map<String, String>> testimonials = [
    {
      'review': "Amazing service! My house has never looked better.",
      'user': "Riya Sharma",
    },
    {
      'review': "Very professional and on time. Highly recommended!",
      'user': "James Rodrigues",
    },
    {
      'review': "Quick, clean and affordable. Loved the experience!",
      'user': "Sara Ali",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _getCurrentLocation();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  void _startAutoScroll() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % testimonials.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        await Geolocator.openLocationSettings();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) return;
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final Placemark place = placemarks.first;
      setState(() {
        currentAddress =
            "${place.name}, ${place.locality}, ${place.administrativeArea}";
      });
    } catch (e) {
      setState(() => currentAddress = 'Location Error');
    } finally {
      setState(() => isLoading = false);
    }
  }

Future<void> showServiceBottomCard(
  BuildContext context,
  Map<String, dynamic> item,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Background image within the card
              Positioned.fill(
                child: Image.asset(
                  'assets/images/serviceimage1.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Frosted glass blur
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(item['icon'], color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item['label'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (item.containsKey('rating'))
                      Row(
                        children: [
                          const Text(
                            "Rating: ",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.star,
                            color: Colors.greenAccent.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${item['rating']} ",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item['reviews'] ?? "",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    if (item.containsKey('description'))
                      Text(
                        item['description'],
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (item['route'] != null &&
                                  item['route'] is Widget Function()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => item['route'](),
                                  ),
                                );
                              } else {
                      

                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Book Now"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Optional: Add logic here
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BookingScreen(), // Fallback
                                  ),
                                );
                            },
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(color: Colors.white70),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Need Time"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
  Widget _buildLoadingOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
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
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : const AssetImage('assets/images/placeholder.png')
                                  as ImageProvider,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? 'No email',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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
                        title: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/login', (route) => false);
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
                  : const AssetImage('assets/images/placeholder.png')
                        as ImageProvider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        "label": "Cleaning Demo",
        "icon": Icons.auto_fix_high,
        "highlight": true,
        "badge": "Most Popular",
        "description":
            "Check demo first for cleaning service. Lorem ipsum dolor sit amet consectetur adipisicing elit. Dignissimos provident.",
        "rating": "4.9",
        "reviews": "(28k)",
        'route': () =>  DemoService(),
      },

      {
        "label": "1 Month Cleaning",
        "icon": Icons.flash_on,
        "highlight": true,
        "badge": "Fastest",
        "description":
            "Check 1 hour cleaning service. Lorem ipsum dolor sit amet consectetur adipisicing elit. Dignissimos provident.",
        "rating": "4.8",
        "reviews": "(15k)",
         'route': () =>  Onemonth(),
      },
      {
        "label": "3 Month Cleaning",
        "icon": Icons.cleaning_services,
        "description":
            "Check 1.5 hour cleaning service. Lorem ipsum dolor sit amet consectetur adipisicing elit. Dignissimos provident.",
        "rating": "4.7",
        "reviews": "(10k)",
            'route': () =>  ThreeMonthPlan(),
      },
      {
        "label": "6 Month Cleaning",
        "icon": Icons.local_laundry_service,
        "description":
            "Check 2 hour cleaning service. Lorem ipsum dolor sit amet consectetur adipisicing elit. Dignissimos provident.",
        "rating": "4.6",
        "reviews": "(8k)",
        'route': () =>  SixMonthPlan(),
      },
      {
        "label": "12 Month Cleaning",
        "icon": Icons.sanitizer,
        "description":
            "Check 2.5 hour cleaning service. Lorem ipsum dolor sit amet consectetur adipisicing elit. Dignissimos provident.",
        "rating": "4.5",
        "reviews": "(6k)",
        'route': () =>  TwelveMonth(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (context, index) {
          final item = services[index];
          return GestureDetector(
            onTap: () {
              // Directly show the bottom card with frosted glass
              showServiceBottomCard(context, item);
            },
            child: Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'], size: 40, color: Colors.orange.shade700),
                    const SizedBox(height: 10),
                    Text(
                      item['label'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestimonialCarousel() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "What Our Customers Say",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: testimonials.length,
            itemBuilder: (context, index) {
              final t = testimonials[index];
              return TestimonialCard(review: t['review']!, user: t['user']!);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            testimonials.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: _currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.orange : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildTopHeader(),

                  // Hero Section
                  SizedBox(
                    width: double.infinity,
                    height: 390,
                    child: Stack(
                      children: [
                        // Blurred background image only
                        ClipRRect(
                          borderRadius: BorderRadius.zero,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/serviceimage1.png',
                                fit: BoxFit.cover,
                              ),
                              BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 6.0,
                                  sigmaY: 6.0,
                                ),
                                child: Container(
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Foreground content (not blurred)
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Card(
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Where would you like to receive your service?",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 700,
                                          ),
                                          transitionBuilder:
                                              (child, animation) =>
                                                  FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  ),
                                          child:
                                              currentAddress ==
                                                  'Fetching location...'
                                              ? ElevatedButton.icon(
                                                  key: const ValueKey("btn"),
                                                  onPressed:
                                                      _getCurrentLocation,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.orange,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.my_location,
                                                  ),
                                                  label: const Text(
                                                    "Set my location",
                                                  ),
                                                )
                                              : Column(
                                                  key: const ValueKey("loc"),
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      color: Colors.green,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      currentAddress,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  children: const [
                                    Text(
                                      "Leave your to-do list to us!",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Check out some of our top home services:",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildServiceSection(context),
                  _buildTestimonialCarousel(),
                  _buildfooter(),
                ],
              ),
            ),
          ),
        ),
        if (isLoading) _buildLoadingOverlay(),
      ],
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final String review;
  final String user;

  const TestimonialCard({super.key, required this.review, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  Icon(Icons.star, color: Colors.amber),
                  Icon(Icons.star, color: Colors.amber),
                  Icon(Icons.star, color: Colors.amber),
                  Icon(Icons.star, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 8),
              Text('"$review"', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildfooter() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        const Text(
          "Houzy – Your Professional Cleaner",
          style: TextStyle(
            fontSize: 14,
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: () {}, child: const Text("Privacy Policy")),
            const Text("|"),
            TextButton(onPressed: () {}, child: const Text("Terms of Service")),
          ],
        ),
      ],
    ),
  );
}
