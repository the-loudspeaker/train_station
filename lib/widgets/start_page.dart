import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:train_station/service/csv_service.dart';
import 'package:train_station/widgets/station.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  TextEditingController linkController = TextEditingController(
      text:
          "https://coverzmylwaehqsqfdgm.supabase.co/storage/v1/object/public/trains//sample_train_schedule.csv");
  int platformCount = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Train Station Simulator"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            Text("CSV URL"),
            TextField(
                autofocus: false,
                controller: linkController,
                keyboardType: TextInputType.url,
                maxLines: 3,
                onSubmitted: null),
            Text("Number of platforms: $platformCount"),
            Slider(
                autofocus: true,
                value: platformCount.toDouble(),
                onChanged: (value) {
                  setState(() {
                    platformCount = value.floor();
                  });
                },
                min: 2,
                max: 20,
                divisions: 19,
                allowedInteraction: SliderInteraction.tapAndSlide),
            ElevatedButton(
                onPressed: () async {
                  Fluttertoast.showToast(
                      msg: "Fetching!", toastLength: Toast.LENGTH_SHORT);
                  var res =
                      await CSVService.fetchTrainsFromURL(linkController.text);
                  Fluttertoast.cancel();
                  if (res.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Error reading CSV or no trains present.",
                        toastLength: Toast.LENGTH_SHORT);
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Station(platformCount: platformCount, trains: res);
                    }));
                  }
                },
                child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
