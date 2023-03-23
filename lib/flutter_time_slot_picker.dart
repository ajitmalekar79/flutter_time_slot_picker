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

// ignore: must_be_immutable
class FlutterTimeSlotPicker extends StatefulWidget {
  final double height;
  List<String> bookedSlots;
  OnSlotChange? onSlotChange;
  DateTime? startTime;
  DateTime? endTime;
  Widget? bookedSlotBackground;
  FlutterTimeSlotPicker({
    super.key,
    this.height = 150,
    this.startTime,
    this.endTime,
    required this.bookedSlots,
    this.onSlotChange,
    this.bookedSlotBackground,
  });

  @override
  State<FlutterTimeSlotPicker> createState() => _FlutterTimeSlotPickerState();
}

class _FlutterTimeSlotPickerState extends State<FlutterTimeSlotPicker> {
  final ScrollController _scrollController = ScrollController();
  double leftPositioned = 0;
  double sliderWidth = 40;
  double initialLeftPositioned = 0;
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;
  List<Map<String, dynamic>> hideSlots = [];
  List hiddenHours = [];
  bool isAvailable = false;

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
        hour: int.parse(splitTime2[0]),
        minute: int.parse(splitTime2[1]),
      );
      int totalSlots = 0;
      var hourMinus = end.hour - start.hour;
      var minuteMinus = (end.minute - start.minute);
      int minuteSlots = minuteMinus == 30
          ? 1
          : minuteMinus == -30
              ? -1
              : 0;
      totalSlots += hourMinus * 2;
      totalSlots += minuteSlots;
      Map<String, dynamic> firstSlotToAdd = {
        'i': int.parse(splitTime[0]),
        'firstHalf': int.parse(splitTime[1]) == 0,
        'secondHalf': int.parse(splitTime[1]) == 30,
      };
      if (totalSlots % 2 == 0) {
        if (firstSlotToAdd['firstHalf'] == true) {
          for (int i = 0; i < hourMinus; i++) {
            Map<String, dynamic> slotToAdd = {
              'i': int.parse(splitTime[0]) + i,
              'firstHalf': true,
              'secondHalf': true,
            };
            mappedSlots.add(slotToAdd);
          }
        } else {
          mappedSlots.add(firstSlotToAdd);
          for (int i = 1; i < hourMinus; i++) {
            Map<String, dynamic> slotToAdd = {
              'i': int.parse(splitTime[0]) + i,
              'firstHalf': true,
              'secondHalf': true,
            };
            mappedSlots.add(slotToAdd);
          }
          mappedSlots.add({
            'i': int.parse(splitTime[0]) + hourMinus,
            'firstHalf': true,
            'secondHalf': false,
          });
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
              };
              mappedSlots.add(slotToAdd);
            }
            slotToAdd = {
              'i': int.parse(splitTime[0]) + hourMinus,
              'firstHalf': true,
              'secondHalf': false,
            };
            mappedSlots.add(slotToAdd);
          } else {
            slotToAdd = {
              'i': int.parse(splitTime[0]),
              'firstHalf': true,
              'secondHalf': false,
            };
            mappedSlots.add(slotToAdd);
          }
        } else {
          mappedSlots.add(firstSlotToAdd);
          for (int i = 1; i < hourMinus; i++) {
            slotToAdd = {
              'i': int.parse(splitTime[0]) + i,
              'firstHalf': true,
              'secondHalf': true,
            };
            mappedSlots.add(slotToAdd);
          }
        }
      }
    }

    return mappedSlots;
  }

  adjustLeft() {
    int division = (leftPositioned / 20).round();
    leftPositioned = 20.0 * division;
  }

  adjustWidth() {
    int division = (sliderWidth / 20).round();
    sliderWidth = 20.0 * division;
  }

  calculateTimeSlot() {
    int division = (leftPositioned / 20).round();
    leftPositioned = 20.0 * division;
    double timeText = division / 2;
    selectedStartTime = getTimeFromDouble(timeText);
    division = ((leftPositioned + sliderWidth) / 20).round();
    timeText = division / 2;
    selectedEndTime = getTimeFromDouble(timeText);
    //ignore: avoid-non-null-assertion
    if (selectedEndTime!.isBefore(selectedStartTime!)) {
      //ignore: avoid-non-null-assertion
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

  checkSlotAvailablity(DateTime startTime, DateTime endTime) {
    String slotString = makeSlotString(startTime, endTime);
    var slots = calculateSlots([slotString]);
    bool availablity = true;
    for (int i = 0; i < slots.length; i++) {
      var matchedSlot = hideSlots.singleWhere(
        (element) =>
            element['i'] == slots[i]['i'] &&
            (element['firstHalf'] == slots[i]['firstHalf'] ||
                element['secondHalf'] == slots[i]['secondHalf']),
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

  getInitialLeftPosition() {
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
    }
    leftPositioned = totalSlots * 20;
    initialLeftPositioned = leftPositioned;
  }

  getInitialWidth() {
    // ignore: avoid-non-null-assertion
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
    }
    sliderWidth = totalSlots * 20;
  }

  loadInitialData() {
    selectedStartTime = widget.startTime ??
        DateTime.now().roundUp(delta: const Duration(minutes: 30));
    selectedEndTime =
        //ignore: avoid-non-null-assertion
        widget.endTime ?? selectedStartTime!.add(const Duration(minutes: 30));
    getInitialWidth();
    getInitialLeftPosition();
    hideSlots = calculateSlots(widget.bookedSlots);
    hiddenHours = hideSlots.map((m) => m['i']).toList();
    isAvailable = checkSlotAvailablity(
      //ignore: avoid-non-null-assertion
      selectedStartTime!, selectedEndTime!,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          initialLeftPositioned - 100,
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
                      width: i != 24 ? 40 : 2,
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
                                            width: 39,
                                            color: const Color(0xffE8E8E8),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      height:
                                          (widget.height - topTextHeight) / 2,
                                      width: 1,
                                      color: const Color(0xffE8E8E8),
                                    ),
                                    Container(
                                      height: 1,
                                      width: 39,
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
                            if (leftPositioned + sliderWidth > 960) {
                              leftPositioned = 960 - sliderWidth;
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
                            //ignore: avoid-non-null-assertion
                            selectedStartTime!, selectedEndTime!,
                          );
                          //ignore: avoid-non-null-assertion
                          widget.onSlotChange!(
                            //ignore: avoid-non-null-assertion
                            isAvailable, selectedStartTime!,
                            //ignore: avoid-non-null-assertion
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
                              if (sliderWidth - details.delta.distance > 20) {
                                sliderWidth =
                                    sliderWidth - details.delta.distance;
                                leftPositioned =
                                    leftPositioned + details.delta.distance;
                                if (leftPositioned + sliderWidth > 960) {
                                  leftPositioned = 960 - sliderWidth;
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
                              //ignore: avoid-non-null-assertion
                              selectedStartTime!, selectedEndTime!,
                            );
                            //ignore: avoid-non-null-assertion
                            widget.onSlotChange!(
                              isAvailable,
                              //ignore: avoid-non-null-assertion
                              selectedStartTime!, selectedEndTime!,
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
                              if (sliderWidth - details.delta.distance > 20) {
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
                              //ignore: avoid-non-null-assertion
                              selectedStartTime!, selectedEndTime!,
                            );
                            //ignore: avoid-non-null-assertion
                            widget.onSlotChange!(
                              isAvailable,
                              //ignore: avoid-non-null-assertion
                              selectedStartTime!,
                              //ignore: avoid-non-null-assertion
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
