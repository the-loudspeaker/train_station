import 'package:flutter/material.dart';
import 'package:train_station/model/train.dart';

import '../model/platform.dart';
import '../model/station_platform.dart';
import '../utils.dart';
import 'AnimatedTrain.dart';

class PlatformsList extends StatefulWidget {
  final List<Train> arrivedTrains;
  final List<Platform> platforms;

  const PlatformsList({
    super.key,
    required this.arrivedTrains,
    required this.platforms,
  });

  @override
  State<PlatformsList> createState() => _PlatformsListState();
}

class _PlatformsListState extends State<PlatformsList> {
  late List<StationPlatform> stationPlatforms;

  @override
  void initState() {
    stationPlatforms =
        createStationPlatforms(widget.arrivedTrains, widget.platforms);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PlatformsList oldWidget) {
    //only modify the StationPlatforms which have train change.
    List<StationPlatform> oldStationPlatforms = stationPlatforms;
    List<StationPlatform> newStationPlatform =
        createStationPlatforms(widget.arrivedTrains, widget.platforms);
    for (int i = 0; i < oldStationPlatforms.length; i++) {
      var oldone = oldStationPlatforms[i];
      var newone = newStationPlatform[i];
      if (oldone.train != newone.train) {
        oldone.removeTrain();
        if (newone.train != null) {
          oldone.addTrain(newone.train!);
        }
      }
    }
    stationPlatforms = oldStationPlatforms;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
        itemBuilder: (context, index) {
          var currStation = stationPlatforms[index];
          //Gets updated only when train changes.
          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("Platform ${currStation.number}"),
              Spacer(),
              AnimatedTrain(train: currStation.train),
              Spacer(),
            ],
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: stationPlatforms.length,
        shrinkWrap: true,
      ),
    );
  }
}
