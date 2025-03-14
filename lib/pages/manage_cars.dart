// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminManageCarsPage extends StatefulWidget {
  @override
  _AdminManageCarsPageState createState() => _AdminManageCarsPageState();
}

class _AdminManageCarsPageState extends State<AdminManageCarsPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Car> cars = [];

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    try {
      final response = await supabase.from('cars').select();
      print("Cars response: $response");
      if (response.isEmpty) {
        print("No cars found.");
      } else {
        setState(() {
          cars = response.map<Car>((car) => Car.fromJson(car)).toList();
        });
      }
    } catch (error) {
      print("Error fetching cars: $error");
    }
  }

  Future<void> _addCar(String name, String transmission, int seats, int doors,
      bool availability, double price) async {
    await supabase.from('cars').insert({
      'name': name,
      'transmission': transmission,
      'seats': seats,
      'doors': doors,
      'availability': availability,
      'price': price,
    });
    _fetchCars();
  }

  Future<void> _updateCar(int id, String name, String transmission, int seats,
      int doors, bool availability, double price) async {
    await supabase.from('cars').update({
      'name': name,
      'transmission': transmission,
      'seats': seats,
      'doors': doors,
      'availability': availability,
      'price': price,
    }).eq('id', id);
    _fetchCars();
  }

  void _removeCar(int index) async {
    await supabase.from('cars').delete().eq('id', cars[index].id);

    if (mounted) {
      setState(() {
        cars.removeAt(index);
      });
    }
  }

  void _showAddCarDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController transmissionController = TextEditingController();
    TextEditingController seatsController = TextEditingController();
    TextEditingController doorsController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    bool selectedAvailability = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Car'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Car Name'),
              ),
              TextField(
                controller: transmissionController,
                decoration: InputDecoration(hintText: 'Transmission Type'),
              ),
              TextField(
                  controller: seatsController,
                  decoration: InputDecoration(hintText: 'Seats'),
                  keyboardType: TextInputType.number),
              TextField(
                  controller: doorsController,
                  decoration: InputDecoration(hintText: 'Doors'),
                  keyboardType: TextInputType.number),
              DropdownButtonFormField<bool>(
                value: selectedAvailability,
                decoration: InputDecoration(labelText: "Availability"),
                items: [
                  DropdownMenuItem(value: true, child: Text("Available")),
                  DropdownMenuItem(value: false, child: Text("Not Available")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedAvailability = value;
                  }
                },
              ),
              TextField(
                  controller: priceController,
                  decoration: InputDecoration(hintText: 'Price'),
                  keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _addCar(
                  nameController.text,
                  transmissionController.text,
                  int.tryParse(seatsController.text) ?? 0,
                  int.tryParse(doorsController.text) ?? 0,
                  selectedAvailability,
                  double.tryParse(priceController.text) ?? 0.0,
                );
                Navigator.pop(context);
              },
              child: Text("Add Car"),
            ),
          ],
        );
      },
    );
  }

  void _showEditCarDialog(Car car) {
    TextEditingController nameController =
        TextEditingController(text: car.name);
    TextEditingController transmissionController =
        TextEditingController(text: car.transmission);
    TextEditingController seatsController = TextEditingController(
      text: car.seats.toString(),
    );
    TextEditingController doorsController = TextEditingController(
      text: car.doors.toString(),
    );
    TextEditingController availabilityController = TextEditingController(
      text: car.availability ? "Available" : "Not Available",
    );
    TextEditingController priceController = TextEditingController(
      text: car.price.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Car'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, "Car Name"),
              _buildTextField(transmissionController, "Transmission Type"),
              _buildTextField(seatsController, "Seats", isNumeric: true),
              _buildTextField(doorsController, "Doors", isNumeric: true),
              _buildTextField(availabilityController, "Availability"),
              _buildTextField(priceController, "Price", isNumeric: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                bool availability =
                    availabilityController.text.toLowerCase() == 'true';
                await _updateCar(
                  car.id,
                  nameController.text,
                  transmissionController.text,
                  int.tryParse(seatsController.text) ?? 0,
                  int.tryParse(doorsController.text) ?? 0,
                  availability, // Converted to boolean
                  double.tryParse(priceController.text) ?? 0.0,
                );
                Navigator.pop(context);
              },
              child: Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFD8A8A),
      appBar: AppBar(
        title: Text("Manage Cars"),
        backgroundColor: Color(0xFFFD8A8A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showAddCarDialog,
              child: Text("Add Car"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  final car = cars[index];
                  return CarCard(
                    car: car,
                    onRemove: () => _removeCar(index),
                    onEdit: () => _showEditCarDialog(car),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Car {
  final int id;
  final String name;
  final String transmission;
  final int seats;
  final int doors;
  final bool availability;
  final double price;

  Car({
    required this.id,
    required this.name,
    required this.transmission,
    required this.seats,
    required this.doors,
    required this.availability,
    required this.price,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      name: json['name'],
      transmission: json['transmission'],
      seats: json['seats'],
      doors: json['doors'],
      availability: json['availability'] == true,
      price: (json['price'] as num).toDouble(),
    );
  }
}

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  const CarCard(
      {required this.car, required this.onRemove, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              car.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("Transmission: ${car.transmission}"),
            Text("Seats: ${car.seats}"),
            Text("Doors: ${car.doors}"),
            Text(
              car.availability ? "Available" : "Not Available",
              style: TextStyle(
                color: car.availability ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "\$${car.price}/Day",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: onEdit),
                IconButton(icon: Icon(Icons.delete), onPressed: onRemove),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
