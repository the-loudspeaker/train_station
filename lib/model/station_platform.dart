import 'train.dart';

class StationPlatform {
  final int number;
  Train? train;

  StationPlatform(this.number);

  void addTrain(Train train) {
    this.train = train;
  }

  void removeTrain() {
    train = null;
  }
}