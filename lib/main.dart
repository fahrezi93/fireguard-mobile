import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request Notification and Location permissions on startup
  await _requestPermissions();

  runApp(
    const ProviderScope(
      child: FireGuardApp(),
    ),
  );
}

Future<void> _requestPermissions() async {
  // Request Notifications
  await Permission.notification.request();

  // Request Location
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (serviceEnabled) {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }
}
