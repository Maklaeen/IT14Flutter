// ignore_for_file: unnecessary_cast
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:project/auth/login.dart';
import 'package:project/pages/admin_manage_bookings_page.dart';
import 'package:project/pages/manage_cars.dart';
import 'package:project/pages/profile.dart';
import 'package:project/pages/user_booking_page.dart';
import 'package:project/sides/notification.dart';
import 'package:project/sides/termscondition.dart';
import 'package:project/sides/aboutus.dart';
import 'package:project/sides/helpcenter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dash extends StatelessWidget {
  final Map<String, dynamic> userData;

  const Dash({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFD8A8A),
      appBar: AppBar(
        backgroundColor: Color(0xFFFD8A8A),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(userData: userData),
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFFFD8A8A),
          child: Column(
            children: [
              Container(
                height: 200,
                color: Color(0xFF353392),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/profile.png'),
                        radius: 40,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${userData['email'] ?? 'User'}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _drawerItem("My Dashboard", Icons.dashboard, context,
                        Dash(userData: userData)),
                    _drawerItem("Notification", Icons.notifications, context,
                        NotificationPage()),
                    _drawerItem("Terms & Conditions", Icons.description,
                        context, TermsConditionPage()),
                    _drawerItem("About us", Icons.info, context, AboutUsPage()),
                    _drawerItem(
                        "Help Center", Icons.help, context, HelpCenterPage()),
                    if (userData['role'] == 'admin')
                      _drawerItem("Manage Cars", Icons.car_repair, context,
                          AdminManageCarsPage()),
                    if (userData['role'] == 'admin')
                      _drawerItem("Manage Booking", Icons.car_repair, context,
                          AdminManageBookingsPage()),
                    if (userData['role'] == 'user')
                      _drawerItem("Show Bookings", Icons.book_outlined, context,
                          UserBookingPage()),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: Color(0xFFFD8A8A),
                padding: EdgeInsets.all(16),
                child: Center(
                  child: OutlinedButton(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();

                      if (!context.mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: Colors.black),
                    ),
                    child: Text(
                      "Log out",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Text(
              "Hello, ${userData['role'] == 'admin' ? 'Admin' : 'User'}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search a vehicle",
                prefixIcon: Icon(Icons.search, color: Colors.black),
                suffixIcon: Icon(Icons.tune, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 25),
            if (userData['role'] == 'admin') AdminDashboard(),
            if (userData['role'] == 'user') UserDashboard(),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
      String title, IconData icon, BuildContext context, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: TextStyle(color: Colors.black)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> cars = [];

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    final response = await Supabase.instance.client.from('cars').select();

    if (mounted) {
      setState(() {
        cars = response as List<Map<String, dynamic>>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Admin Dashboard: Manage Cars",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 10),
          cars.isEmpty
              ? Center(child: Text("No cars found."))
              : Column(
                  children: cars.map((car) {
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(car['name']),
                        subtitle: Text("Price: \$${car['price']}"),
                        trailing: Icon(Icons.directions_car),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  List<Map<String, dynamic>> availableCars = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    try {
      final response = await Supabase.instance.client.from('cars').select();
      if (response.isEmpty) {
        print("No cars found.");
      } else {
        print("Fetched cars: $response");
        if (mounted) {
          setState(() {
            availableCars = List<Map<String, dynamic>>.from(response.map((car) {
              return {
                ...car,
                'availability': car['availability'] == true ||
                    car['availability'] == 'true',
              };
            }));
          });
        }
      }
    } catch (e) {
      print("Error fetching cars: $e");
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _bookCar(Map<String, dynamic> car) async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select both start and end dates!")),
      );
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You need to be logged in!")),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('bookings').insert({
        'user_id': userId,
        'car_id': car['id'],
        'start_date': startDate!.toIso8601String(),
        'end_date': endDate!.toIso8601String(),
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Car booked successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showBookingDialog(Map<String, dynamic> car) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Book ${car['name']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text: startDate != null
                      ? DateFormat('yyyy-MM-dd').format(startDate!)
                      : '',
                ),
                decoration: InputDecoration(
                  labelText: "Start Date",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, true),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text: endDate != null
                      ? DateFormat('yyyy-MM-dd').format(endDate!)
                      : '',
                ),
                decoration: InputDecoration(
                  labelText: "End Date",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, false),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _bookCar(car);
                Navigator.pop(context);
              },
              child: Text("Confirm Booking"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Available Cars",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 10),
          availableCars.isEmpty
              ? Center(child: Text("No cars available."))
              : Column(
                  children: availableCars.map((car) {
                    bool isAvailable = car['availability'] == true;
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(car['name']),
                        subtitle: Text("Price: \$${car['price']}"),
                        trailing: isAvailable
                            ? ElevatedButton(
                                onPressed: () => _showBookingDialog(car),
                                child: Text("Book Now"),
                              )
                            : Text("Not Available",
                                style: TextStyle(color: Colors.red)),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
