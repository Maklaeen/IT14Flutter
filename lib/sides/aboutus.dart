import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          'About Us',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          Icon(Icons.groups, color: Colors.black),
          SizedBox(width: 16),
        ],
        elevation: 0,
      ),
      backgroundColor: Color(0xFFFD8A8A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'At M & M Auto Rentals, we are committed to providing reliable and affordable car rental solutions to enhance your travel experience. Founded in 2024 our mission is to offer a diverse fleet of well-maintained vehicles that cater to every need, from compact cars to spacious SUVs. We pride ourselves on our exceptional customer service, ensuring that every rental is smooth and hassle-free. With locations across Davao City we strive to make your journey convenient and enjoyable.',
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'Our dedication to safety means that all our vehicles undergo rigorous maintenance checks, allowing you to travel with peace of mind. Join us in exploring new destinations with confidence!',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
