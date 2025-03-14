import 'package:flutter/material.dart';

class TermsConditionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms & Conditions'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Icon(Icons.file_present),
          SizedBox(width: 16),
        ],
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Color(0xFFFD8A8A),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By using our services, you agree to comply with these Terms & Conditions. Please read them carefully.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTermItem(
                      'You must be at least 21 years old to rent a vehicle. Additional fees may apply for drivers under 21.'),
                  _buildTermItem(
                      'All rentals require a valid credit card. Payment will be processed upon booking confirmation.'),
                  _buildTermItem(
                      'Cancellations made 24 hours before the rental will receive a full refund. Cancellations made less than 24 hours in advance may incur a fee.'),
                  _buildTermItem(
                      'Vehicles must be used for lawful purposes only. Off-road driving and racing are prohibited.'),
                  _buildTermItem(
                      'You are responsible for any damages incurred during the rental period. Optional insurance coverage is available.'),
                  _buildTermItem(
                      'Vehicles must be returned in the same condition as received, with a full tank of gas.'),
                  _buildTermItem(
                      'We reserve the right to modify these Terms & Conditions at any time. Changes will be communicated through the app.'),
                  _buildTermItem(
                      'For questions regarding these terms, please contact our customer support.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
