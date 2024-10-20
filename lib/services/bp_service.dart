import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BPReading {
  final int systolic;
  final int diastolic;
  final DateTime timestamp;

  BPReading(
      {required this.systolic,
      required this.diastolic,
      required this.timestamp});

  // State logic
  String get state {
    if (systolic >= 180 || diastolic >= 120) return 'Hypertensive Crisis';
    if (systolic >= 140 || diastolic >= 90) return 'Hypertensive';
    if (systolic >= 120 || diastolic >= 80) return 'Elevated';
    return 'Normal';
  }

  // Color logic based on state
  static Color getStateColor(String state) {
    switch (state) {
      case 'Hypertensive Crisis':
        return Colors.red;
      case 'Hypertensive':
        return Colors.orange;
      case 'Elevated':
        return Colors.yellow.shade700;
      default:
        return Colors.green;
    }
  }

  // Convert BPReading to JSON
  Map<String, dynamic> toJson() => {
        'systolic': systolic,
        'diastolic': diastolic,
        'timestamp': timestamp.toIso8601String(),
      };

  // Create BPReading from JSON
  static BPReading fromJson(Map<String, dynamic> json) => BPReading(
        systolic: json['systolic'],
        diastolic: json['diastolic'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

// class BPService {
//   static const String bpKey = 'bp_readings';

//   // Save a list of readings to SharedPreferences
//   static Future<void> saveBPReadings(List<BPReading> readings) async {
//     final prefs = await SharedPreferences.getInstance();
//     final readingsJson = readings.map((e) => jsonEncode(e.toJson())).toList();
//     await prefs.setStringList(bpKey, readingsJson);
//   }

//   // Load readings from SharedPreferences
//   static Future<List<BPReading>> loadBPReadings() async {
//     final prefs = await SharedPreferences.getInstance();
//     final readingsJson = prefs.getStringList(bpKey);
//     if (readingsJson != null) {
//       return readingsJson
//           .map((e) => BPReading.fromJson(jsonDecode(e)))
//           .toList();
//     }
//     return [];
//   }

//   // Add a new BP reading
//   static Future<void> addBPReading(BPReading reading) async {
//     final readings = await loadBPReadings();
//     readings.add(reading);
//     await saveBPReadings(readings);

//     // Trigger the callback to update the dashboard
//   }

//   // Clear all readings
//   static Future<void> clearBPReadings() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(bpKey);
//   }
// }

class BPService extends ChangeNotifier {
  static const String bpKey = 'bp_readings';

  List<BPReading> _readings = [];

  List<BPReading> get readings => _readings;

  // Save a list of readings to SharedPreferences
  static Future<void> saveBPReadings(List<BPReading> readings) async {
    final prefs = await SharedPreferences.getInstance();
    final readingsJson = readings.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(bpKey, readingsJson);
  }

  // Load readings from SharedPreferences and notify listeners
  Future<void> loadBPReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final readingsJson = prefs.getStringList(bpKey);
    if (readingsJson != null) {
      _readings =
          readingsJson.map((e) => BPReading.fromJson(jsonDecode(e))).toList();
    } else {
      _readings = [];
    }
    notifyListeners(); // Notify listeners when readings are loaded
  }

  // Add a new BP reading
  Future<void> addBPReading(BPReading reading) async {
    _readings.add(reading);
    await saveBPReadings(_readings);
    notifyListeners(); // Notify listeners when a new reading is added
  }

  // Clear all readings
  Future<void> clearBPReadings() async {
    _readings = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(bpKey);
    notifyListeners(); // Notify listeners when readings are cleared
  }
}
