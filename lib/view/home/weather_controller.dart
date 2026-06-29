import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather_247/data/models/weather_model.dart';

class WeatherController extends GetxController {
  var isLoading = true.obs;
  var weatherData = Rxn<WeatherData>();
  var errorMessage = ''.obs;

  var locationName = 'Locating...'.obs;
  var backgroundAsset = 'assets/images/default.jpg'.obs;
  // Checks for both variable names just to be safe, and aggressively trims it
  final String apiKey =
      (dotenv.env['OPENWEATHER_API_KEY'] ?? dotenv.env['MY_API_KEY'] ?? '')
          .trim();

  @override
  void onInit() {
    super.onInit();
    fetchWeatherByGps();
  }

  // --- 1. CORE FETCH METHOD ---
  Future<void> fetchWeatherForCoordinates(
    double lat,
    double lon,
    String cityName,
  ) async {
    try {
      isLoading(true);
      errorMessage('');
      locationName.value = cityName;

      // 1. Aggressively clean the variables
      final cleanLat = lat.toString().trim();
      final cleanLon = lon.toString().trim();
      final cleanKey = apiKey.trim();

      // 2. Safely construct the URL
      final String urlString =
          'https://api.openweathermap.org/data/3.0/onecall?lat=$cleanLat&lon=$cleanLon&exclude=minutely,alerts&units=metric&appid=$cleanKey';

      final response = await http.get(Uri.parse(urlString));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        weatherData.value = WeatherData.fromJson(jsonData);

        _updateDynamicBackground(weatherData.value!.current.icon);
      } else {
        errorMessage.value = 'Failed to load weather: ${response.statusCode}';
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
    } finally {
      isLoading(false);
    }
  }

  // --- 2. GEOCODING (CITY NAME TO LAT/LON) ---
  Future<bool> fetchWeatherByCity(String city) async {
    try {
      isLoading(true);
      final cleanKey = apiKey.trim();
      // Ensure the city string is also URL-safe
      final cleanCity = Uri.encodeComponent(city.trim());

      final url =
          'http://api.openweathermap.org/geo/1.0/direct?q=$cleanCity&limit=1&appid=$cleanKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = data[0]['lat'];
          final lon = data[0]['lon'];
          final name = data[0]['name'];

          await fetchWeatherForCoordinates(lat, lon, name);
          return true;
        } else {
          errorMessage.value = 'City not found';
          return false;
        }
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Search error: $e';
      return false;
    }
  }

  // --- 3. REVERSE GEOCODING & GPS ---
  Future<void> fetchWeatherByGps() async {
    try {
      isLoading(true);

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Location denied';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final cleanLat = position.latitude.toString().trim();
      final cleanLon = position.longitude.toString().trim();
      final cleanKey = apiKey.trim();

      final url =
          'http://api.openweathermap.org/geo/1.0/reverse?lat=$cleanLat&lon=$cleanLon&limit=1&appid=$cleanKey';
      final response = await http.get(Uri.parse(url));

      String city = 'Unknown Location';
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) city = data[0]['name'];
      }

      await fetchWeatherForCoordinates(
        position.latitude,
        position.longitude,
        city,
      );
    } catch (e) {
      errorMessage.value = 'GPS error: $e';
      print(errorMessage.value);
    } finally {
      isLoading(false);
    }
  }

  var isCelsius = true.obs;

  // 2. Add this method to toggle
  void toggleUnits() {
    isCelsius.value = !isCelsius.value;
    // This will automatically update any UI wrapped in Obx()
  }

  // 3. Add a helper to format temperature
  String formatTemp(double tempC) {
    if (isCelsius.value) {
      return "${tempC.round()}°";
    } else {
      // Convert Celsius to Fahrenheit
      double tempF = (tempC * 9 / 5) + 32;
      return "${tempF.round()}°";
    }
  }
  String formatHour(int timestamp) {
  // Convert seconds to milliseconds, then to DateTime
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  // Returns format like "2 PM"
  return DateFormat('h a').format(date);
}

  // --- 4. DYNAMIC BACKGROUND MAPPER ---
  void _updateDynamicBackground(String iconCode) {
    if (iconCode.contains('01')) {
      backgroundAsset.value = 'assets/images/clear.jpg';
    } else if (iconCode.contains('02') ||
        iconCode.contains('03') ||
        iconCode.contains('04')) {
      backgroundAsset.value = 'assets/images/cloudy.jpg';
    } else if (iconCode.contains('09') || iconCode.contains('10')) {
      backgroundAsset.value = 'assets/images/rainy.jpg';
    } else if (iconCode.contains('11')) {
      backgroundAsset.value = 'assets/images/stormy.jpg';
    } else {
      backgroundAsset.value = 'assets/images/default.jpg';
    }
  }
}
