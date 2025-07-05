# 🚉 train_station

A simple train station emulator built with Flutter.

## 🚀 Getting Started

### Build the Project

To build the APK for release, run:
```flutter build apk --release```

The generated APK will be located at:
```build/app/outputs/flutter-apk/app-release.apk```


## 🛠️ How It Works

- The app builds a **final chart** with calculated actual arrival and departure times based on the input CSV and the number of available platforms.
- Times exceeding 24 hours are wrapped back to 00 hours.
- Using the final chart, the app displays:
    - Currently occupied platforms
    - Trains waiting for a platform to be freed

## ✨ Features

- Real-time platform occupancy visualization
- Handles time overflow (beyond 24 hours)
- CSV-based train schedule input

## 📁 Project Structure
```
lib/
├── widgets/
│ ├── animated_train.dart # Animated trains on station platforms
│ ├── platforms_list.dart # List and state of station platforms
│ ├── start_page.dart # Input page for user data
│ └── station.dart # Displays platforms and waiting trains
│
├── model/
│ ├── platform.dart # Platform model for final chart generation
│ ├── train.dart # Input train data model
│ └── station_platform.dart # Platform model with optional train
│
├── services/
│ └── csv_service.dart # CSV fetching and parsing service
│
├── main.dart # App entry point
└── utils.dart # Chart generation, validations, exports, etc.
```
