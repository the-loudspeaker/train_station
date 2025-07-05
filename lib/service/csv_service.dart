import '../model/train.dart';
import 'package:http/http.dart' as http;

class CSVService {
  static Future<List<Train>> fetchTrainsFromURL(String url) async {
    try {
      http.Response response  =  await http.get(Uri.parse(url));
      if(response.statusCode!=200){
        return List.empty();
      }
      else{
        String responseBody = response.body;
        List<String> lines = responseBody.trim().split("\n");
        List<Train> trains = [];
        for (int i = 1; i < lines.length; i++) {
          List<String> columns = lines[i].split(',');
          if (columns.length >= 4) {
            validateHHMMFormat(columns[1].trim());
            validateHHMMFormat(columns[2].trim());
            trains.add(Train(
              trainNumber: columns[0].trim(),
              scheduledArrival: columns[1].trim(),
              scheduledDeparture: columns[2].trim(),
              priority: columns[3].trim(),
            ));
          }
        }
        return trains;
      }
    }
    catch (_){
      return List.empty();
    }
  }
}

void validateHHMMFormat(String input) {
  final regex = RegExp(r'^\d{2}:\d{2}$');
  if (!regex.hasMatch(input)) {
    throw FormatException('Invalid time format: "$input". Expected "HH:MM".');
  }
}