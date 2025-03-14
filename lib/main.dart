// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:project/pages/welcome.dart';
import 'package:project/pages/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://idmcpghcunrrwzlnhsuo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlkbWNwZ2hjdW5ycnd6bG5oc3VvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk4Nzk3NzIsImV4cCI6MjA1NTQ1NTc3Mn0.UOj-mMuAdquioh-zfGsELNbZEJO1_HQ85rz8XqKQbcY',
  );

  final user = Supabase.instance.client.auth.currentUser;

  runApp(
    MyApp(
      startScreen:
          user != null ? Dash(userData: await _getUserData(user)) : Welcome(),
    ),
  );
}

Future<Map<String, dynamic>> _getUserData(User user) async {
  final response = await Supabase.instance.client
      .from('users')
      .select('role')
      .eq('id', user.id)
      .maybeSingle();

  if (response == null) {
    return {
      'id': user.id,
      'email': user.email,
      'role': 'user',
    };
  }

  return {
    'id': user.id,
    'email': user.email,
    'role': response['role'],
  };
}

extension on PostgrestMap {
  get data => null;
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'M&M Auto Rentals',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: startScreen,
    );
  }
}
