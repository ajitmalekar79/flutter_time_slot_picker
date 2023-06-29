library flutter_time_slot_picker;

import 'package:flutter_time_slot_picker/datetime_extensions.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

extension DateTimeExt on DateTime {
  DateTime applyTimeOfDay({required int hour, required int minute}) {
    return DateTime(year, month, day, hour, minute);
  }
}

typedef OnSlotChange = void Function(
  bool availablity,
  DateTime startTime,
  DateTime endTime,
);

checkSlotAvailablity(DateTime startTime, DateTime endTime,
    List<Map<String, dynamic>> hideSlots) {
  String slotString = makeSlotString(startTime, endTime);
  var slots = calculateSlots([slotString]);
  bool availablity = true;
  for (int i = 0; i < slots.length; i++) {
    var matchedSlot = hideSlots.firstWhere(
      (element) {
        Map<String, dynamic> selectedSlot = slots[i];
        if (element['i'] == selectedSlot['i']) {
          if (selectedSlot['firstHalf'] && element['firstHalf']) {
            return true;
          }
          if (selectedSlot['secondHalf'] && element['secondHalf']) {
            return true;
          }
          if (selectedSlot['thirdHalf'] && element['thirdHalf']) {
            return true;
          }
          if (selectedSlot['fourthHalf'] && element['fourthHalf']) {
            return true;
          }
          return false;
        }
        return false;
      },
      orElse: () => {},
    );
    if (matchedSlot.isNotEmpty) {
      availablity = false;
      break;
    }
  }

  return availablity;
}

makeSlotString(DateTime startTime, DateTime endTime) {
  final DateFormat formatter = DateFormat('HH:mm');
  final String formattedStartTime = formatter.format(startTime);
  final String formattedEndTime = formatter.format(endTime);

  return '$formattedStartTime-$formattedEndTime';
}

// ignore: long-method
List<Map<String, dynamic>> calculateSlots(List<String> slots) {
  List<Map<String, dynamic>> mappedSlots = [];
  for (var element in slots) {
    var timeList = element.split('-');
    var splitTime = timeList[0].split(':');
    var splitTime2 = timeList[1].split(':');
    TimeOfDay start = TimeOfDay(
      hour: int.parse(splitTime[0]),
      minute: int.parse(splitTime[1]),
    );
    TimeOfDay end = TimeOfDay(
      hour: int.parse(splitTime2[0]) == 0 ? 24 : int.parse(splitTime2[0]),
      minute: int.parse(splitTime2[1]),
    );
    int totalSlots = 0;
    var hourMinus = end.hour - start.hour;
    var minuteMinus = (end.minute - start.minute);
    int minuteSlots = minuteMinus == 45
        ? 3
        : minuteMinus == -45
            ? -3
            : minuteMinus == 30
                ? 2
                : minuteMinus == -30
                    ? -2
                    : minuteMinus == 15
                        ? 1
                        : minuteMinus == -15
                            ? -1
                            : 0;
    totalSlots += hourMinus * 4;
    totalSlots += minuteSlots;
    Map<String, dynamic> firstSlotToAdd = {
      'i': int.parse(splitTime[0]),
      'firstHalf': (int.parse(splitTime[1]) == 0 &&
          (hourMinus > 0 || (int.parse(splitTime2[1]) >= 15))),
      'secondHalf': (int.parse(splitTime[1]) <= 15 &&
          (hourMinus > 0 || (int.parse(splitTime2[1]) >= 30))),
      'thirdHalf': (int.parse(splitTime[1]) <= 30 &&
          (hourMinus > 0 || (int.parse(splitTime2[1]) >= 45))),
      'fourthHalf': int.parse(splitTime[1]) <= 45 && hourMinus > 0,
    };
    final mappedSlotFirst = mappedSlots.firstWhere(
      (mapped) => mapped['i'] == firstSlotToAdd['i'],
      orElse: () => {},
    );
    if (mappedSlotFirst.isNotEmpty) {
      firstSlotToAdd = {
        'i': firstSlotToAdd['i'],
        'firstHalf': mappedSlotFirst['firstHalf']
            ? mappedSlotFirst['firstHalf']
            : firstSlotToAdd['firstHalf'],
        'secondHalf': mappedSlotFirst['secondHalf']
            ? mappedSlotFirst['secondHalf']
            : firstSlotToAdd['secondHalf'],
        'thirdHalf': mappedSlotFirst['thirdHalf']
            ? mappedSlotFirst['thirdHalf']
            : firstSlotToAdd['thirdHalf'],
        'fourthHalf': mappedSlotFirst['fourthHalf']
            ? mappedSlotFirst['fourthHalf']
            : firstSlotToAdd['fourthHalf'],
      };
      mappedSlots.removeWhere(
          (mappedElement) => mappedElement['i'] == mappedSlotFirst['i']);
    }

    if (totalSlots % 4 == 0) {
      if (firstSlotToAdd['firstHalf'] == true) {
        for (int i = 0; i < hourMinus; i++) {
          Map<String, dynamic> slotToAdd = {
            'i': int.parse(splitTime[0]) + i,
            'firstHalf': true,
            'secondHalf': true,
            'thirdHalf': true,
            'fourthHalf': true,
          };
          final mappedSlot = mappedSlots.firstWhere(
            (mapped) => mapped['i'] == slotToAdd['i'],
            orElse: () => {},
          );
          if (mappedSlot.isNotEmpty) {
            slotToAdd = {
              'i': int.parse(splitTime[0]) + i,
              'firstHalf': mappedSlot['firstHalf']
                  ? mappedSlot['firstHalf']
                  : slotToAdd['firstHalf'],
              'secondHalf': mappedSlot['secondHalf']
                  ? mappedSlot['secondHalf']
                  : slotToAdd['secondHalf'],
              'thirdHalf': mappedSlot['thirdHalf']
                  ? mappedSlot['thirdHalf']
                  : slotToAdd['thirdHalf'],
              'fourthHalf': mappedSlot['fourthHalf']
                  ? mappedSlot['fourthHalf']
                  : slotToAdd['fourthHalf'],
            };
            mappedSlots.removeWhere(
                (mappedElement) => mappedElement['i'] == mappedSlot['i']);
          }
          mappedSlots.add(slotToAdd);
        }
      } else {
        mappedSlots.add(firstSlotToAdd);
        for (int i = 1; i < hourMinus; i++) {
          Map<String, dynamic> slotToAdd = {
            'i': int.parse(splitTime[0]) + i,
            'firstHalf': true,
            'secondHalf': true,
            'thirdHalf': true,
            'fourthHalf': true,
          };
          final mappedSlot = mappedSlots.firstWhere(
            (mapped) => mapped['i'] == slotToAdd['i'],
            orElse: () => {},
          );
          if (mappedSlot.isNotEmpty) {
            slotToAdd = {
              'i': int.parse(splitTime[0]) + i,
              'firstHalf': mappedSlot['firstHalf']
                  ? mappedSlot['firstHalf']
                  : slotToAdd['firstHalf'],
              'secondHalf': mappedSlot['secondHalf']
                  ? mappedSlot['secondHalf']
                  : slotToAdd['secondHalf'],
              'thirdHalf': mappedSlot['thirdHalf']
                  ? mappedSlot['thirdHalf']
                  : slotToAdd['thirdHalf'],
              'fourthHalf': mappedSlot['fourthHalf']
                  ? mappedSlot['fourthHalf']
                  : slotToAdd['fourthHalf'],
            };
            mappedSlots.removeWhere(
                (mappedElement) => mappedElement['i'] == mappedSlot['i']);
          }
          mappedSlots.add(slotToAdd);
        }
        final mappedSlot = mappedSlots.firstWhere(
          (mapped) => mapped['i'] == int.parse(splitTime2[0]),
          orElse: () => {},
        );
        if (mappedSlot.isNotEmpty) {
          mappedSlots.removeWhere(
              (mappedElement) => mappedElement['i'] == mappedSlot['i']);
          mappedSlots.add({
            'i': int.parse(splitTime2[0]),
            'firstHalf': mappedSlot['firstHalf']
                ? mappedSlot['firstHalf']
                : int.parse(splitTime2[1]) >= 15,
            'secondHalf': mappedSlot['secondHalf']
                ? mappedSlot['secondHalf']
                : int.parse(splitTime2[1]) >= 30,
            'thirdHalf': mappedSlot['thirdHalf']
                ? mappedSlot['thirdHalf']
                : int.parse(splitTime2[1]) >= 45,
            'fourthHalf': false,
          });
        } else {
          mappedSlots.add({
            'i': int.parse(splitTime2[0]),
            'firstHalf': int.parse(splitTime2[1]) >= 15,
            'secondHalf': int.parse(splitTime2[1]) >= 30,
            'thirdHalf': int.parse(splitTime2[1]) >= 45,
            'fourthHalf': false,
          });
        }
      }
    } else {
      Map<String, dynamic> slotToAdd = {};
      if (firstSlotToAdd['firstHalf'] == true) {
        if (hourMinus > 0) {
          for (int i = 0; i < hourMinus; i++) {
            slotToAdd = {
              'i': int.parse(splitTime[0]) + i,
              'firstHalf': true,
              'secondHalf': true,
              'thirdHalf': true,
              'fourthHalf': true,
            };
            final mappedSlot = mappedSlots.firstWhere(
              (mapped) => mapped['i'] == slotToAdd['i'],
              orElse: () => {},
            );
            if (mappedSlot.isNotEmpty) {
              slotToAdd = {
                'i': int.parse(splitTime[0]) + i,
                'firstHalf': mappedSlot['firstHalf']
                    ? mappedSlot['firstHalf']
                    : slotToAdd['firstHalf'],
                'secondHalf': mappedSlot['secondHalf']
                    ? mappedSlot['secondHalf']
                    : slotToAdd['secondHalf'],
                'thirdHalf': mappedSlot['thirdHalf']
                    ? mappedSlot['thirdHalf']
                    : slotToAdd['thirdHalf'],
                'fourthHalf': mappedSlot['fourthHalf']
                    ? mappedSlot['fourthHalf']
                    : slotToAdd['fourthHalf'],
              };
              mappedSlots.removeWhere(
                  (mappedElement) => mappedElement['i'] == mappedSlot['i']);
            }
            mappedSlots.add(slotToAdd);
          }
          slotToAdd = {
            'i': int.parse(splitTime2[0]),
            'firstHalf': int.parse(splitTime2[1]) >= 15,
            'secondHalf': int.parse(splitTime2[1]) >= 30,
            'thirdHalf': int.parse(splitTime2[1]) >= 45,
            'fourthHalf': false,
          };
          final mappedSlot = mappedSlots.firstWhere(
            (mapped) => mapped['i'] == slotToAdd['i'],
            orElse: () => {},
          );
          if (mappedSlot.isNotEmpty) {
            slotToAdd = {
              'i': int.parse(splitTime2[0]),
              'firstHalf': mappedSlot['firstHalf']
                  ? mappedSlot['firstHalf']
                  : slotToAdd['firstHalf'],
              'secondHalf': mappedSlot['secondHalf']
                  ? mappedSlot['secondHalf']
                  : slotToAdd['secondHalf'],
              'thirdHalf': mappedSlot['thirdHalf']
                  ? mappedSlot['thirdHalf']
                  : slotToAdd['thirdHalf'],
              'fourthHalf': mappedSlot['fourthHalf']
                  ? mappedSlot['fourthHalf']
                  : slotToAdd['fourthHalf'],
            };
            mappedSlots.removeWhere(
                (mappedElement) => mappedElement['i'] == mappedSlot['i']);
          }
          mappedSlots.add(slotToAdd);
        } else {
          slotToAdd = {
            'i': int.parse(splitTime[0]),
            'firstHalf': true,
            'secondHalf': totalSlots > 1,
            'thirdHalf': totalSlots > 2,
            'fourthHalf': false,
          };
          final mappedSlot = mappedSlots.firstWhere(
            (mapped) => mapped['i'] == [slotToAdd['i']],
            orElse: () => {},
          );
          if (mappedSlot.isNotEmpty) {
            slotToAdd = {
              'i': int.parse(splitTime[0]),
              'firstHalf': mappedSlot['firstHalf']
                  ? mappedSlot['firstHalf']
                  : slotToAdd['firstHalf'],
              'secondHalf': mappedSlot['secondHalf']
                  ? mappedSlot['secondHalf']
                  : slotToAdd['secondHalf'],
              'thirdHalf': mappedSlot['thirdHalf']
                  ? mappedSlot['thirdHalf']
                  : slotToAdd['thirdHalf'],
              'fourthHalf': mappedSlot['fourthHalf']
                  ? mappedSlot['fourthHalf']
                  : slotToAdd['fourthHalf'],
            };
            mappedSlots.removeWhere(
                (mappedElement) => mappedElement['i'] == mappedSlot['i']);
          }
          mappedSlots.add(slotToAdd);
        }
      } else {
        mappedSlots.add(firstSlotToAdd);
        for (int i = 1; i < hourMinus; i++) {
          slotToAdd = {
            'i': int.parse(splitTime[0]) + i,
            'firstHalf': true,
            'secondHalf': true,
            'thirdHalf': true,
            'fourthHalf': true,
          };
          final mappedSlot = mappedSlots.firstWhere(
            (mapped) => mapped['i'] == slotToAdd['i'],
            orElse: () => {},
          );
          if (mappedSlot.isNotEmpty) {
            slotToAdd = {
              'i': int.parse(splitTime[0]) + i,
              'firstHalf': mappedSlot['firstHalf']
                  ? mappedSlot['firstHalf']
                  : slotToAdd['firstHalf'],
              'secondHalf': mappedSlot['secondHalf']
                  ? mappedSlot['secondHalf']
                  : slotToAdd['secondHalf'],
              'thirdHalf': mappedSlot['thirdHalf']
                  ? mappedSlot['thirdHalf']
                  : slotToAdd['thirdHalf'],
              'fourthHalf': mappedSlot['fourthHalf']
                  ? mappedSlot['fourthHalf']
                  : slotToAdd['fourthHalf'],
            };
            mappedSlots.removeWhere(
                (mappedElement) => mappedElement['i'] == mappedSlot['i']);
          }
          mappedSlots.add(slotToAdd);
        }
        if (hourMinus > 0) {
          slotToAdd = {
            'i': int.parse(splitTime2[0]),
            'firstHalf': int.parse(splitTime2[1]) >= 15,
            'secondHalf': int.parse(splitTime2[1]) >= 30,
            'thirdHalf': int.parse(splitTime2[1]) >= 45,
            'fourthHalf': false,
          };
          final mappedSlot = mappedSlots.firstWhere(
            (mapped) => mapped['i'] == slotToAdd['i'],
            orElse: () => {},
          );
          if (mappedSlot.isNotEmpty) {
            slotToAdd = {
              'i': int.parse(splitTime2[0]),
              'firstHalf': mappedSlot['firstHalf']
                  ? mappedSlot['firstHalf']
                  : slotToAdd['firstHalf'],
              'secondHalf': mappedSlot['secondHalf']
                  ? mappedSlot['secondHalf']
                  : slotToAdd['secondHalf'],
              'thirdHalf': mappedSlot['thirdHalf']
                  ? mappedSlot['thirdHalf']
                  : slotToAdd['thirdHalf'],
              'fourthHalf': mappedSlot['fourthHalf']
                  ? mappedSlot['fourthHalf']
                  : slotToAdd['fourthHalf'],
            };
            mappedSlots.removeWhere(
                (mappedElement) => mappedElement['i'] == mappedSlot['i']);
          }
          mappedSlots.add(slotToAdd);
        }
      }
    }
  }

  return mappedSlots;
}

// ignore: must_be_immutable
class FlutterTimeSlotPicker extends StatefulWidget {
  final double height;
  List<String> bookedSlots;
  OnSlotChange? onSlotChange;
  DateTime? initialTime;
  DateTime? startTime;
  DateTime? endTime;
  Widget? bookedSlotBackground;
  int minimumTimeInterval;
  FlutterTimeSlotPicker({
    super.key,
    this.height = 150,
    this.initialTime,
    this.startTime,
    this.endTime,
    required this.bookedSlots,
    this.onSlotChange,
    this.bookedSlotBackground,
    this.minimumTimeInterval = 30,
  });

  @override
  State<FlutterTimeSlotPicker> createState() => _FlutterTimeSlotPickerState();
}

class _FlutterTimeSlotPickerState extends State<FlutterTimeSlotPicker> {
  final ScrollController _scrollController = ScrollController();
  double leftPositioned = 0;
  double sliderWidth = 40;
  double initialLeftPositioned = 0;
  DateTime? initialTime;
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;
  List<Map<String, dynamic>> hideSlots = [];
  List hiddenHours = [];
  bool isAvailable = false;
  int minimumTimeInterval = 30;

  adjustLeft() {
    double division = (leftPositioned / 80);
    double decimal = (division - division.floor()) * 10;
    if (decimal >= 0 && decimal < 1.25) {
      decimal = 0;
    } else if (decimal >= 1.25 && decimal < 3.75) {
      decimal = 20;
    } else if (decimal >= 3.75 && decimal < 6.25) {
      decimal = 40;
    } else if (decimal >= 6.25 && decimal < 8.75) {
      decimal = 60;
    } else if (decimal >= 8.75) {
      decimal = 80;
    }

    leftPositioned = (80.0 * division.floor()) + decimal;
  }

  adjustWidth() {
    double division = (sliderWidth / 80);
    double decimal = (division - division.floor()) * 10;
    if (decimal >= 0 && decimal < 1.25) {
      decimal = 0;
    } else if (decimal >= 1.25 && decimal < 3.75) {
      decimal = 20;
    } else if (decimal >= 3.75 && decimal < 6.25) {
      decimal = 40;
    } else if (decimal >= 6.25 && decimal < 8.75) {
      decimal = 60;
    } else if (decimal >= 8.75) {
      decimal = 80;
    }

    sliderWidth = (80.0 * division.floor()) + decimal;
  }

  calculateTimeSlot() {
    double division = (leftPositioned / 80);
    double timeText = division;
    selectedStartTime = getTimeFromDouble(timeText);
    division = ((leftPositioned + sliderWidth) / 80);
    timeText = division.toDouble();
    selectedEndTime = getTimeFromDouble(timeText);
    if (selectedEndTime!.isBefore(selectedStartTime!)) {
      selectedEndTime = selectedEndTime!.add(const Duration(days: 1));
    }
  }

  DateTime getTimeFromDouble(double value) {
    int flooredValue = value.floor();
    double decimalValue = value - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);
    //ignore: avoid-non-null-assertion
    DateTime? finalTime = selectedStartTime!.applyTimeOfDay(
      hour: int.parse(hourValue),
      minute: int.parse(minuteString),
    );

    return finalTime;
  }

  String getMinuteString(double decimalValue) {
    return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
  }

  String getHourString(int flooredValue) {
    return '${flooredValue % 24}'.padLeft(2, '0');
  }

  getInitialLeftPosition() {
    DateTime? startTime = initialTime!.applyTimeOfDay(
      hour: 0,
      minute: 0,
    );
    String slotString = makeSlotString(startTime, initialTime!);
    var slots = calculateSlots([slotString]);
    int totalSlots = 0;
    if (!startTime.isAtSameMomentAs(initialTime!)) {
      for (var element in slots) {
        if (element['firstHalf'] == true) {
          totalSlots += 1;
        }
        if (element['secondHalf'] == true) {
          totalSlots += 1;
        }
        if (element['thirdHalf'] == true) {
          totalSlots += 1;
        }
        if (element['fourthHalf'] == true) {
          totalSlots += 1;
        }
      }
      leftPositioned = totalSlots * 20;
      initialLeftPositioned = leftPositioned;
    }

    slotString = makeSlotString(startTime, selectedStartTime!);
    slots = calculateSlots([slotString]);
    totalSlots = 0;
    for (var element in slots) {
      if (element['firstHalf'] == true) {
        totalSlots += 1;
      }
      if (element['secondHalf'] == true) {
        totalSlots += 1;
      }
      if (element['thirdHalf'] == true) {
        totalSlots += 1;
      }
      if (element['fourthHalf'] == true) {
        totalSlots += 1;
      }
    }
    leftPositioned = totalSlots * 20;
  }

  getInitialWidth() {
    String slotString = makeSlotString(selectedStartTime!, selectedEndTime!);
    var slots = calculateSlots([slotString]);
    int totalSlots = 0;
    for (var element in slots) {
      if (element['firstHalf'] == true) {
        totalSlots += 1;
      }
      if (element['secondHalf'] == true) {
        totalSlots += 1;
      }
      if (element['thirdHalf'] == true) {
        totalSlots += 1;
      }
      if (element['fourthHalf'] == true) {
        totalSlots += 1;
      }
    }
    sliderWidth = totalSlots * 20;
  }

  getSelectedInitialLeftPosition() {
    // ignore: avoid-non-null-assertion
    DateTime? startTime = selectedStartTime!.applyTimeOfDay(
      hour: 0,
      minute: 0,
    );
    // ignore: avoid-non-null-assertion
    String slotString = makeSlotString(startTime, selectedStartTime!);
    var slots = calculateSlots([slotString]);
    int totalSlots = 0;
    for (var element in slots) {
      if (element['firstHalf'] == true) {
        totalSlots += 1;
      }
      if (element['secondHalf'] == true) {
        totalSlots += 1;
      }
      if (element['thirdHalf'] == true) {
        totalSlots += 1;
      }
      if (element['fourthHalf'] == true) {
        totalSlots += 1;
      }
    }
    leftPositioned = totalSlots * 40;
  }

  setMinimumInterval() {
    double division = minimumTimeInterval / 60;
    double decimal = (division - division.floor()) * 100;

    if (decimal > 0 && decimal <= 25) {
      minimumTimeInterval = 20;
    } else if (decimal > 25 && decimal <= 50) {
      minimumTimeInterval = 40;
    } else if (decimal > 50 && decimal <= 75) {
      minimumTimeInterval = 60;
    } else if (decimal > 75 && decimal <= 100) {
      minimumTimeInterval = 80;
    }

    minimumTimeInterval += (60 * division.floor());
  }

  loadInitialData() {
    selectedStartTime = widget.startTime ??
        DateTime.now().roundUp(delta: const Duration(minutes: 15));
    selectedEndTime = widget.endTime ??
        selectedStartTime!.add(Duration(minutes: widget.minimumTimeInterval));
    if (selectedEndTime!.difference(selectedStartTime!).inMinutes !=
        widget.minimumTimeInterval) {
      selectedEndTime =
          selectedStartTime!.add(Duration(minutes: widget.minimumTimeInterval));
    }
    setMinimumInterval();
    getInitialWidth();
    getInitialLeftPosition();
    hideSlots = calculateSlots(widget.bookedSlots);
    hiddenHours = hideSlots.map((m) => m['i']).toList();
    isAvailable = checkSlotAvailablity(
      selectedStartTime!,
      selectedEndTime!,
      hideSlots,
    );
  }

  @override
  void initState() {
    super.initState();
    minimumTimeInterval = widget.minimumTimeInterval;

    if (widget.initialTime != null) {
      initialTime = widget.initialTime;
    } else {
      initialTime = DateTime.now().roundUp(delta: const Duration(minutes: 15));
    }
    loadInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          leftPositioned - 100,
          duration: const Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double topTextHeight = 16;
    // (widgeteight / 5);

    return SizedBox(
      height: widget.height,
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Stack(
            children: [
              Row(
                children: [
                  for (int i = 0; i < 25; i++)
                    SizedBox(
                      height: widget.height,
                      width: i != 24 ? 80 : 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: widget.height,
                            width: 1,
                            color: const Color(0xffE8E8E8),
                          ),
                          if (i != 24)
                            Stack(
                              children: [
                                if (hiddenHours.contains(i) &&
                                    hideSlots.firstWhere(
                                          (element) => element['i'] == i,
                                          orElse: () => {},
                                        )['firstHalf'] ==
                                        true)
                                  Positioned(
                                    top: topTextHeight,
                                    child: Container(
                                      height: (widget.height - topTextHeight),
                                      width: 20,
                                      decoration: widget.bookedSlotBackground !=
                                              null
                                          ? const BoxDecoration()
                                          : BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.grey.withOpacity(0.2),
                                                  Colors.grey.withOpacity(0.5),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                      child: widget.bookedSlotBackground ??
                                          Container(),
                                    ),
                                  ),
                                if (hiddenHours.contains(i) &&
                                    hideSlots.firstWhere(
                                          (element) => element['i'] == i,
                                          orElse: () => {},
                                        )['secondHalf'] ==
                                        true)
                                  Positioned(
                                    top: topTextHeight,
                                    left: 20,
                                    child: Container(
                                      height: (widget.height - topTextHeight),
                                      width: 20,
                                      decoration: widget.bookedSlotBackground !=
                                              null
                                          ? const BoxDecoration()
                                          : BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.grey.withOpacity(0.2),
                                                  Colors.grey.withOpacity(0.5),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                      child: widget.bookedSlotBackground ??
                                          Container(),
                                    ),
                                  ),
                                if (hiddenHours.contains(i) &&
                                    hideSlots.firstWhere(
                                          (element) => element['i'] == i,
                                          orElse: () => {},
                                        )['thirdHalf'] ==
                                        true)
                                  Positioned(
                                    top: topTextHeight,
                                    left: 40,
                                    child: Container(
                                      height: (widget.height - topTextHeight),
                                      width: 20,
                                      decoration: widget.bookedSlotBackground !=
                                              null
                                          ? const BoxDecoration()
                                          : BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.grey.withOpacity(0.2),
                                                  Colors.grey.withOpacity(0.5),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                      child: widget.bookedSlotBackground ??
                                          Container(),
                                    ),
                                  ),
                                if (hiddenHours.contains(i) &&
                                    hideSlots.firstWhere(
                                          (element) => element['i'] == i,
                                          orElse: () => {},
                                        )['fourthHalf'] ==
                                        true)
                                  Positioned(
                                    top: topTextHeight,
                                    left: 60,
                                    child: Container(
                                      height: (widget.height - topTextHeight),
                                      width: 20,
                                      decoration: widget.bookedSlotBackground !=
                                              null
                                          ? const BoxDecoration()
                                          : BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.grey.withOpacity(0.2),
                                                  Colors.grey.withOpacity(0.5),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                      child: widget.bookedSlotBackground ??
                                          Container(),
                                    ),
                                  ),
                                Column(
                                  children: [
                                    Container(
                                      height: topTextHeight,
                                      color: const Color(0xffFAFAFA),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 2),
                                            child: Text(
                                              '$i:00',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 11),
                                            ),
                                          ),
                                          Container(
                                            height: 1,
                                            width: 79,
                                            color: const Color(0xffE8E8E8),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          height:
                                              (widget.height - topTextHeight) /
                                                  4,
                                          width: 1,
                                          color: const Color(0xffE8E8E8),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          height:
                                              (widget.height - topTextHeight) /
                                                  2,
                                          width: 1,
                                          color: const Color(0xffE8E8E8),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          height:
                                              (widget.height - topTextHeight) /
                                                  4,
                                          width: 1,
                                          color: const Color(0xffE8E8E8),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 1,
                                      width: 79,
                                      color: const Color(0xffE8E8E8),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              Positioned(
                left: leftPositioned,
                top: topTextHeight,
                child: Stack(
                  children: [
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          if (!(details.delta.direction > 0)) {
                            leftPositioned =
                                leftPositioned + details.delta.distance;
                            if (leftPositioned + sliderWidth > 1920) {
                              leftPositioned = 1920 - sliderWidth;
                            }
                          } else {
                            leftPositioned =
                                leftPositioned - details.delta.distance;
                            if (leftPositioned < initialLeftPositioned) {
                              leftPositioned = initialLeftPositioned;
                            }
                          }
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        setState(() {
                          adjustLeft();
                          calculateTimeSlot();
                          isAvailable = checkSlotAvailablity(
                            selectedStartTime!,
                            selectedEndTime!,
                            hideSlots,
                          );
                          widget.onSlotChange!(
                            isAvailable,
                            selectedStartTime!,
                            selectedEndTime!,
                          );
                        });
                      },
                      child: Container(
                        height: widget.height - topTextHeight,
                        width: sliderWidth,
                        color: isAvailable
                            ? const Color(0xff38D68B).withOpacity(0.1)
                            : const Color(0xffFF4141).withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      left: 1,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            if (!(details.delta.direction > 0)) {
                              if (sliderWidth - details.delta.distance >
                                  minimumTimeInterval) {
                                sliderWidth =
                                    sliderWidth - details.delta.distance;
                                leftPositioned =
                                    leftPositioned + details.delta.distance;
                                if (leftPositioned + sliderWidth > 1920) {
                                  leftPositioned = 1920 - sliderWidth;
                                }
                              }
                            } else {
                              leftPositioned =
                                  leftPositioned - details.delta.distance;
                              if (leftPositioned < initialLeftPositioned) {
                                leftPositioned = initialLeftPositioned;
                              } else {
                                sliderWidth =
                                    sliderWidth + details.delta.distance;
                              }
                            }
                          });
                        },
                        onHorizontalDragEnd: (details) {
                          setState(() {
                            adjustLeft();
                            adjustWidth();
                            calculateTimeSlot();
                            isAvailable = checkSlotAvailablity(
                              selectedStartTime!,
                              selectedEndTime!,
                              hideSlots,
                            );
                            widget.onSlotChange!(
                              isAvailable,
                              selectedStartTime!,
                              selectedEndTime!,
                            );
                          });
                        },
                        child: Container(
                          height: widget.height - topTextHeight,
                          width: 10,
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: Container(
                            height: 14,
                            width: 3,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? const Color(0xff38D68B)
                                  : const Color(0xffFF4141),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 1,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            if (!(details.delta.direction > 0)) {
                              sliderWidth =
                                  sliderWidth + details.delta.distance;
                            } else {
                              if (sliderWidth - details.delta.distance >
                                  minimumTimeInterval) {
                                sliderWidth =
                                    sliderWidth - details.delta.distance;
                              }
                            }
                          });
                        },
                        onHorizontalDragEnd: (details) {
                          setState(() {
                            adjustWidth();
                            calculateTimeSlot();
                            isAvailable = checkSlotAvailablity(
                              selectedStartTime!,
                              selectedEndTime!,
                              hideSlots,
                            );
                            widget.onSlotChange!(
                              isAvailable,
                              selectedStartTime!,
                              selectedEndTime!,
                            );
                          });
                        },
                        child: Container(
                          height: widget.height - topTextHeight,
                          width: 10,
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          child: Container(
                            height: 14,
                            width: 3,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? const Color(0xff38D68B)
                                  : const Color(0xffFF4141),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
