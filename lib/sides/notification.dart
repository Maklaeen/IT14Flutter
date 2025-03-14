import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      print("No user logged in.");
      return;
    }

    print("Fetching notifications for user: $userId");

    try {
      final response = await Supabase.instance.client
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print("Notifications fetched: $response");

      if (mounted) {
        setState(() {
          notifications = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (error) {
      print("Error fetching notifications: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Notifications'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Color(0xFFFD8A8A)),
        child: notifications.isEmpty
            ? Center(child: Text("No new notifications."))
            : ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotification(notifications[index]['message']);
                },
              ),
      ),
    );
  }

  Widget _buildNotification(String message) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 0.8),
      ),
      child: Text(message, style: TextStyle(fontSize: 16)),
    );
  }
}
