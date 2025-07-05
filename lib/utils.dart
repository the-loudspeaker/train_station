
import 'dart:core';

import 'model/platform.dart';
import 'model/station_platform.dart';
import 'model/train.dart';

int compareTime(String time1, String time2) {
  List<String> parts1 = time1.split(':');
  List<String> parts2 = time2.split(':');

  int hours1 = int.parse(parts1[0]);
  int minutes1 = int.parse(parts1[1]);
  int hours2 = int.parse(parts2[0]);
  int minutes2 = int.parse(parts2[1]);

  int totalMinutes1 = hours1 * 60 + minutes1;
  int totalMinutes2 = hours2 * 60 + minutes2;

  return totalMinutes1.compareTo(totalMinutes2);
}

String addMinsToTime(String time, int minutes) {
  List<String> parts = time.split(':');
  int hours = int.parse(parts[0]);
  int mins = int.parse(parts[1]);

  int totalMinutes = hours * 60 + mins + minutes;
  int newHours = totalMinutes ~/ 60;
  int newMins = totalMinutes % 60;

  return '${newHours.toString().padLeft(2, '0')}:${newMins.toString().padLeft(2, '0')}';
}

int calculateDelayMins(String scheduledTime, String actualTime) {
  List<String> scheduledParts = scheduledTime.split(':');
  List<String> actualParts = actualTime.split(':');

  int scheduledMinutes = int.parse(scheduledParts[0]) * 60 + int.parse(scheduledParts[1]);
  int actualMinutes = int.parse(actualParts[0]) * 60 + int.parse(actualParts[1]);

  return actualMinutes - scheduledMinutes;
}

void assignPlatformsAndTimes(List<Train> trains, int numPlatforms) {
  // Sort trains by arrival time, then by priority
  trains.sort((a, b) {
    int timeComparison = compareTime(a.scheduledArrival, b.scheduledArrival);
    if (timeComparison != 0) return timeComparison;
    return a.priorityValue.compareTo(b.priorityValue);
  });

  // if departure time is less than arrival time, update departure time.
  for(Train train in trains){
    if(compareTime(train.scheduledArrival, train.scheduledDeparture)>0){
      train.scheduledDeparture = train.scheduledArrival;
    }
  }

  //if scheduled arrival time is more than 24:00, reduce 24 from hours
  for(Train train in trains){
    if(compareTime("24:00", train.scheduledArrival)<=0){
      int hours = int.parse(train.scheduledArrival.split(":")[0]);
      int mins = int.parse(train.scheduledArrival.split(":")[1]);
      hours = hours-24;
      train.scheduledArrival = "$hours:$mins";
    }
  }

  //if scheduled departure time is more than 24:00, reduce 24 from hours
  for(Train train in trains){
    if(compareTime("24:00", train.scheduledDeparture)<=0){
      int hours = int.parse(train.scheduledDeparture.split(":")[0]);
      int mins = int.parse(train.scheduledDeparture.split(":")[1]);
      hours = hours-24;
      train.scheduledDeparture = "$hours:$mins";
    }
  }

  // Initialize platforms
  List<Platform> platforms = List.generate(numPlatforms, (index) => Platform(index + 1));

  for (Train train in trains) {
    Platform? bestPlatform;
    String bestArrivalTime = train.scheduledArrival;

    //if a platform is free at scheduled arrival, that is best platform
    for (Platform platform in platforms) {
      if (platform.isAvailable(train.scheduledArrival)) {
        bestPlatform = platform;
        break; // Take the first available platform immediately
      }
    }

    // If no platform is free, find the one that becomes free earliest
    if (bestPlatform == null) {
      String earliestFreeTime = '';

      //find lowest free time for each platform, set that as best platform.
      for (Platform platform in platforms) {
        String platformFreeTime = platform.occupiedUntil ?? '00:00';

        if (earliestFreeTime.isEmpty || compareTime(platformFreeTime, earliestFreeTime) < 0) {
          earliestFreeTime = platformFreeTime;
          bestPlatform = platform;
        }
      }

      // Set lowest free time as best arrival time
      if (compareTime(earliestFreeTime, train.scheduledArrival) > 0) {
        bestArrivalTime = earliestFreeTime;
      } else {
        bestArrivalTime = train.scheduledArrival;
      }
    }

    // Set platform and actual arrival time
    train.platform = bestPlatform!.number;
    train.actualArrival = bestArrivalTime;

    // check for crossing 24 hour actualArrival
    if(compareTime("24:00", train.actualArrival)<=0){
      int hours = int.parse(train.actualArrival.split(":")[0]);
      int mins = int.parse(train.actualArrival.split(":")[1]);
      hours = hours-24;
      train.actualArrival = "$hours:$mins";
    }

    // Set actual departure time
    if (bestArrivalTime != train.scheduledArrival) {
      int delay = calculateDelayMins(train.scheduledArrival, bestArrivalTime);
      train.actualDeparture = addMinsToTime(train.scheduledDeparture, delay);
    } else {
      train.actualDeparture = train.scheduledDeparture;
    }

    // check for crossing 24 hour actualDeparture
    if(compareTime("24:00", train.actualDeparture)<=0){
      int hours = int.parse(train.actualDeparture.split(":")[0]);
      int mins = int.parse(train.actualDeparture.split(":")[1]);
      hours = hours-24;
      train.actualDeparture = "$hours:$mins";
    }

    // Occupy the platform until departure
    bestPlatform.occupy(train.actualDeparture);
  }
}

List<Train> getWaitingTrains(List<Train> finalChart, String currentTime){
  List<Train> waitingTrains = [];
  for(Train each in finalChart){
    if(compareTime(each.actualArrival, currentTime)>0 && compareTime(each.scheduledArrival, currentTime)<=0){
      waitingTrains.add(each);
    }
  }
  return waitingTrains;
}

List<Train> getArrivedTrains(List<Train> finalChart, String currentTime) {
  List<Train> arrivedTrains = [];
  for(Train each in finalChart){
    if(compareTime(each.actualArrival, currentTime)<=0 && compareTime(each.actualDeparture, currentTime)>0){
      arrivedTrains.add(each);
    }
  }
  return arrivedTrains;
}


String generateOutputCSV(List<Train> trains) {
  StringBuffer buffer = StringBuffer();
  buffer.writeln('Train Number,Scheduled Arrival,Scheduled Departure,Priority,Actual Arrival,Actual Departure,Platform');

  for (Train train in trains) {
    buffer.writeln('${train.trainNumber},${train.scheduledArrival},${train.scheduledDeparture},${train.priority},${train.actualArrival},${train.actualDeparture},${train.platform}');
  }

  return buffer.toString();
}

String getCurrentTime(){
  var time = DateTime.timestamp().toLocal();
  var mins = time.minute;
  var timeString = "${time.hour}:${mins<10? "0$mins" : mins}";
  return timeString;
}

List<StationPlatform> createStationPlatforms(
    List<Train> arrivedTrains, List<Platform> platforms) {
  List<StationPlatform> temp =
  List.generate(platforms.length, (index) => StationPlatform(index + 1));
  for (StationPlatform currPlatform in temp) {
    if (arrivedTrains
        .where((it) => it.platform == currPlatform.number)
        .isNotEmpty) {
      currPlatform.addTrain(
          arrivedTrains.firstWhere((it) => it.platform == currPlatform.number));
    }
  }
  return temp;
}