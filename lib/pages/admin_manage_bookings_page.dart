// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminManageBookingsPage extends StatefulWidget {
  @override
  _AdminManageBookingsPageState createState() =>
      _AdminManageBookingsPageState();
}

class _AdminManageBookingsPageState extends State<AdminManageBookingsPage> {
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final response = await Supabase.instance.client
          .from('bookings')
          .select('id, user_id, car_id, status, created_at');

      if (response == null || response.isEmpty) {
        print("No bookings found.");
        return;
      }

      if (mounted) {
        setState(() {
          bookings = List<Map<String, dynamic>>.from(response);
        });

        print("Fetched Bookings:");
        for (var booking in bookings) {
          print("ID: ${booking['id']}, Status: ${booking['status']}");
        }
      }
    } catch (e) {
      print("Error fetching bookings: $e");
    }
  }

  Future<void> _updateBookingStatus(
      String bookingId, String status, String userId, String carId) async {
    try {
      print("Updating booking ID: '$bookingId' with status: '$status'");

      final response = await Supabase.instance.client
          .from('bookings')
          .update({'status': status})
          .eq('id', bookingId)
          .select();

      if (response.isEmpty) {
        print("❌ Error: No rows updated. Booking ID might be incorrect.");
        return;
      }

      print("✅ Booking updated successfully: $response");

      if (status == "approved") {
        print("Setting car ID: $carId to NOT available...");

        final carUpdateResponse = await Supabase.instance.client
            .from('cars')
            .update({'availability': false})
            .eq('id', int.parse(carId))
            .select();

        if (carUpdateResponse.isEmpty) {
          print("❌ Car availability update failed.");
        } else {
          print("✅ Car availability updated successfully: $carUpdateResponse");
        }
      }

      await Supabase.instance.client.from('notifications').insert({
        'user_id': userId,
        'message': "Your booking has been $status.",
        'created_at': DateTime.now().toIso8601String(),
      });

      await _fetchBookings();
    } catch (e) {
      print("❌ Error updating booking: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFD8A8A),
      appBar: AppBar(
        title: Text("Manage Bookings"),
        backgroundColor: Color(0xFFFD8A8A),
      ),
      body: bookings.isEmpty
          ? Center(
              child: Text("No bookings available."),
            )
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                        "Car ID: ${booking['car_id']} | User ID: ${booking['user_id']}"),
                    subtitle: Text(
                        "Status: ${booking['status']} | Date: ${booking['created_at']}"),
                    trailing: booking['status'] == "pending"
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () => _updateBookingStatus(
                                    booking['id'].toString(),
                                    "approved",
                                    booking['user_id'].toString(),
                                    booking['car_id'].toString()),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () => _updateBookingStatus(
                                    booking['id'].toString(),
                                    "rejected",
                                    booking['user_id'].toString(),
                                    booking['car_id'].toString()),
                              ),
                            ],
                          )
                        : Text(
                            booking['status'].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: booking['status'] == "approved"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
