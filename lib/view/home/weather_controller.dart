import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:weather_247/data/models/weather_model.dart';
// Import your WeatherData model here

class WeatherController extends GetxController {
  var isLoading = true.obs;
  var weatherData = Rxn<WeatherData>();
  var errorMessage = ''.obs;
  
  // NEW: Reactive variables for UI binding
  var locationName = 'Locating...'.obs;
  var backgroundUrl = 'https://images.unsplash.com/photo-1534088568595-a066f410bcda?q=80&w=1000&auto=format&fit=crop'.obs;

  final String apiKey = dotenv.env['OPENWEATHER_API_KEY']?.trim() ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchWeatherByGps(); // Default to user's actual location on startup
  }

  // --- 1. CORE FETCH METHOD ---
  Future<void> fetchWeatherForCoordinates(double lat, double lon, String cityName) async {
    try {
      isLoading(true);
      errorMessage('');
      locationName.value = cityName;

      final String url = 'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely,alerts&units=metric&appid=$apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        weatherData.value = WeatherData.fromJson(jsonData);
        
        // Update the background based on the new weather condition
        _updateDynamicBackground(weatherData.value!.current.icon);
      } else {
        errorMessage.value = 'Failed to load weather: ${response.statusCode}';
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
      final url = 'http://api.openweathermap.org/geo/1.0/direct?q=$city&limit=1&appid=$apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = data[0]['lat'];
          final lon = data[0]['lon'];
          final name = data[0]['name'];
          // Call the core method with the found coordinates
          await fetchWeatherForCoordinates(lat, lon, name);
          return true; // Success
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
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Location denied';
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      // Reverse geocode to get the city name from coordinates
      final url = 'http://api.openweathermap.org/geo/1.0/reverse?lat=${position.latitude}&lon=${position.longitude}&limit=1&appid=$apiKey';
      final response = await http.get(Uri.parse(url));
      
      String city = 'Unknown Location';
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) city = data[0]['name'];
      }

      await fetchWeatherForCoordinates(position.latitude, position.longitude, city);
    } catch (e) {
      errorMessage.value = 'GPS error: $e';
      print(errorMessage.value);
    } finally {
      isLoading(false);
    }
  }

  // --- 4. DYNAMIC BACKGROUND MAPPER ---
  void _updateDynamicBackground(String iconCode) {
    // Mapping OpenWeather icon codes to reliable Unsplash images.
    // In production, replace these with your own local assets from the DESIGN.md
    if (iconCode.contains('01')) {
      backgroundUrl.value = 'https://images.unsplash.com/photo-1601297183314-c09d3958171a?q=80&w=1000&auto=format&fit=crop'; // Clear sky
    } else if (iconCode.contains('02') || iconCode.contains('03') || iconCode.contains('04')) {
      backgroundUrl.value = 'https://images.unsplash.com/photo-1534088568595-a066f410bcda?q=80&w=1000&auto=format&fit=crop'; // Clouds
    } else if (iconCode.contains('09') || iconCode.contains('10')) {
      backgroundUrl.value = 'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?q=80&w=1000&auto=format&fit=crop'; // Rain
    } else if (iconCode.contains('11')) {
      backgroundUrl.value = 'https://images.unsplash.com/photo-1605727216801-e27ce1d0ce49?q=80&w=1000&auto=format&fit=crop'; // Thunderstorm
    } else {
      backgroundUrl.value = 'https://images.unsplash.com/photo-1487621167305-5d248087c724?q=80&w=1000&auto=format&fit=crop'; // Default dark atmospheric
    }
  }
}