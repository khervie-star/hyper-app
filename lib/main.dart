import 'package:flutter/material.dart';
import 'package:hyper_app/app.dart';
import 'package:hyper_app/services/bp_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (_) => BPService()..loadBPReadings(), child: HypertensionApp()));
}
