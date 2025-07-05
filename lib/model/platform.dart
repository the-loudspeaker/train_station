import '../utils.dart';

class Platform {
  final int number;
  String? occupiedUntil; //last occupied train's departure time

  Platform(this.number);

  bool isAvailable(String time) {
    if (occupiedUntil == null) return true;
    return compareTime(time, occupiedUntil!) >= 0;
  }

  void occupy(String departureTime) {
    occupiedUntil = departureTime;
  }
}