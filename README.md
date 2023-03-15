
flutter_time_slot_picker

A package that provide user to pick time slot by horizontal slider view. Also it will help to show the schedule of entity.

Getting started

In the pubspec.yaml of your flutter project, add the following dependency:

dependencies:
  ...
  flutter_time_slot_picker: <latest_version>
In your library add the following import:

import 'package:flutter_time_slot_picker/flutter_time_slot_picker.dart';

For help getting started with Flutter, view the online documentation.

TimeSlotPiker example

    FlutterTimeSlotPicker(
        height: 60,
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

One can start with simply adding dependency and use FlutterTimeSlotPicker this widget to display Horizontal Time Slot Picker.
![Alt Text](https://github.com/ajitmalekar79/flutter_time_slot_picker/blob/main/flutter_time_slot_picker.gif)
