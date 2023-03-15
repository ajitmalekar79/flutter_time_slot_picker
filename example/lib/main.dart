import 'package:flutter/material.dart';
import 'package:flutter_time_slot_picker/flutter_time_slot_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Time Slot Picker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool timeSlotAvailablity = false;
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlutterTimeSlotPicker(
              height: 60,
              // ignore: prefer_const_literals_to_create_immutables
              bookedSlots: [
                '2:00-3:00',
                '4:00-5:30',
                '6:30-7:00',
                '8:30-9:30',
                '10:00-13:00',
                '14:00-14:30',
                '15:30-18:00',
              ],
              onSlotChange: (availablity, startTime, endTime) {
                setState(() {
                  timeSlotAvailablity = availablity;
                  selectedStartTime = startTime;
                  selectedEndTime = endTime;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Selected Time Slot:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${selectedStartTime ?? ''} - ${selectedEndTime ?? ''}',
              // style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Slot Availability',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '$timeSlotAvailablity',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
