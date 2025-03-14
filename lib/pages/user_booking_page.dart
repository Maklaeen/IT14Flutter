import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserBookingPage extends StatefulWidget {
  @override
  _UserBookingPageState createState() => _UserBookingPageState();
}

class _UserBookingPageState extends State<UserBookingPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List<dynamic> response = await _supabase
          .from('bookings')
          .select('id, car_id, start_date, end_date, status')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        print("No bookings found.");
      } else {
        print("Bookings fetched: $response");
      }

      setState(() {
        _bookings = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFD8A8A),
      appBar: AppBar(
        title: Text("M&M Car Rentals"),
        backgroundColor: Color(0xFFFD8A8A),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(child: Text("No bookings found."))
              : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Icon(Icons.directions_car),
                        title: Text("Car ID: ${booking['car_id']}"),
                        subtitle: Text(
                            "Start: ${booking['start_date']}\nEnd: ${booking['end_date']}\nStatus: ${booking['status']}"),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      ),
                    );
                  },
                ),
    );
  }
}
