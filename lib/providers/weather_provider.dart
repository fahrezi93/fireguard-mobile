import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class WeatherData {
  final double temp;
  final String condition;
  final String icon;
  final String cityName;
  final int humidity;
  final double windSpeed;

  WeatherData({
    required this.temp,
    required this.condition,
    required this.icon,
    required this.cityName,
    required this.humidity,
    required this.windSpeed,
  });
}

final weatherProvider = FutureProvider.autoDispose<WeatherData>((ref) async {
  try {
    Position? position;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    // Minta izin lokasi agar cuacanya sesuai tempat user berada
    if (serviceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        position = await Geolocator.getCurrentPosition();
      }
    }

    // Default ke koordinat Plaju Darat, Palembang kalau Permission Lokasi tidak diberikan
    double lat = position?.latitude ?? -3.0039;
    double lon = position?.longitude ?? 104.7915;

    // TODO: Ganti ini memakai environment variable (.env) kalau aplikasinya mau dirilis.
    // Daftar apiKey cadangan di bawah ini sebaiknya jangan diunggah ke GitHub publik.
    const apiKey = const String.fromEnvironment('WEATHER_KEY', defaultValue: '4d8fde0984235a5d697f0cc68eff82c9');

    // Data cadangan/dummy jika API Key belum diubah, 
    // biar aplikasinya gak merah (error) ketika disave pertama kali.
    if (apiKey == 'YOUR_API_KEY') {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulasi loading network
      return WeatherData(
        temp: 32.5,
        condition: 'Cerah Berawan',
        icon: '02d', 
        cityName: 'Palembang',
        humidity: 68,
        windSpeed: 4.5,
      );
    }

    final dio = Dio();
    final response = await dio.get(
      'https://api.openweathermap.org/data/2.5/weather',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': apiKey,
        'units': 'metric',
        'lang': 'id', // Bahasa Indonesia
      },
    );

    final data = response.data;
    return WeatherData(
      temp: data['main']['temp'].toDouble(),
      condition: data['weather'][0]['description'].toString(),
      icon: data['weather'][0]['icon'].toString(),
      cityName: position == null ? 'Plaju Darat' : data['name'].toString(),
      humidity: data['main']['humidity'].toInt(),
      windSpeed: data['wind']['speed'].toDouble(),
    );
  } catch (e) {
    throw Exception('Gagal memuat cuaca: $e');
  }
});
