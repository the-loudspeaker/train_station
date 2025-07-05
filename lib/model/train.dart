class Train {
  final String trainNumber;
  String scheduledArrival;
  String scheduledDeparture;
  final String priority;
  String actualArrival;
  String actualDeparture;
  int platform;

  Train({
    required this.trainNumber,
    required this.scheduledArrival,
    required this.scheduledDeparture,
    required this.priority,
    this.actualArrival = '',
    this.actualDeparture = '',
    this.platform = 0,
  });

  int get priorityValue {
    switch (priority) {
      case 'P1': return 1;
      case 'P2': return 2;
      case 'P3': return 3;
      default: return 4;
    }
  }
}
// fromList & to toList can be added here.
