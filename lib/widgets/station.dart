import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:train_station/model/train.dart';
import 'package:train_station/widgets/platforms_list.dart';
import '../model/platform.dart';
import '../utils.dart';

class Station extends StatefulWidget {
  final int platformCount;
  final List<Train> trains;

  const Station({super.key, required this.platformCount, required this.trains});

  @override
  State<Station> createState() => _StationState();
}

class _StationState extends State<Station> {
  List<Train> finalChart = List.empty();
  List<Platform> platforms = List.empty();

  String currentTime = getCurrentTime();
  List<Train> currentlyWaitingTrains = List.empty();
  List<Train> arrivedTrains = List.empty();

  late Timer _timer;

  @override
  void initState() {
    //create final chart & platforms.
    finalChart = widget.trains;
    platforms =
        List.generate(widget.platformCount, (index) => Platform(index + 1));
    assignPlatformsAndTimes(finalChart, widget.platformCount);

    //Set current time & update waiting & arrived list.
    updateCurrentTimeAndLists();

    // Calculate delay until next minute boundary
    final now = DateTime.now();
    final int secondsUntilNextMinute = 60 - now.second;
    _timer =
        Timer(Duration(seconds: secondsUntilNextMinute), _startMinuteSyncTimer);
    super.initState();
  }

  void _startMinuteSyncTimer() {
    // Update immediately at the minute boundary
    updateCurrentTimeAndLists();
    // Start periodic timer that fires every minute at the start of each minute
    // Update current time & update waiting & arrived list.
    _timer = Timer.periodic(
        const Duration(minutes: 1), (timer) => updateCurrentTimeAndLists());
  }

  void updateCurrentTimeAndLists() {
    setState(() {
      currentTime = getCurrentTime();
      currentlyWaitingTrains = getWaitingTrains(finalChart, currentTime);
      arrivedTrains = getArrivedTrains(finalChart, currentTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("⌛  $currentTime"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            Text("${widget.trains.length} Trains - ${widget.platformCount} Platforms"),
            ElevatedButton(onPressed: exportChart, child: Text("Export Data")),
            PlatformsList(
                arrivedTrains: arrivedTrains, platforms: platforms),
            Text("Currently waiting trains:"),
            ListView.separated(
              itemBuilder: (item, index) => Text(
                  "🚅 ${currentlyWaitingTrains[index].trainNumber}",
                  textAlign: TextAlign.center),
              separatorBuilder: (item, index) => Divider(),
              itemCount: currentlyWaitingTrains.length,
              shrinkWrap: true,
            ),
            if (currentlyWaitingTrains.isEmpty) Text("None") else SizedBox()
          ],
        ),
      ),
    );
  }

  void exportChart() async {
    // Show system save dialog box.
    var csvData = generateOutputCSV(finalChart);
    String? outputFile = await FilePicker.platform.saveFile(
        bytes: Uint8List.fromList(utf8.encode(csvData)),
        dialogTitle: 'Please select where to save the report:',
        fileName: 'train_station_report.csv',
        type: FileType.custom);
    if (outputFile == null) {
      Fluttertoast.showToast(msg: "Report not saved");
    } else {
      Fluttertoast.showToast(msg: "Report saved 📁");
    }
  }
}
