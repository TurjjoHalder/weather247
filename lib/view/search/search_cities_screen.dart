import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_247/view/home/weather_controller.dart';
import 'search_cities_controller.dart';
// Import your GlassContainer and SearchCityController here

class SearchCitiesScreen extends StatelessWidget {
  const SearchCitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchCityController());

    return Scaffold(
      backgroundColor: const Color(
        0xFF131313,
      ), // Atmospheric Clarity surface default
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Weather',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.gps_fixed, color: Colors.white),
            onPressed: () {
              Get.find<WeatherController>().fetchWeatherByGps();
              Get.back(); // Go back to home screen immediately
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Dynamic intense blur overlay when searching
          Obx(
            () => AnimatedOpacity(
              opacity: controller.isSearchFocused.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 60.0,
                  sigmaY: 60.0,
                ), // 60px blur per DESIGN.md
                child: Container(
                  color: Colors.black.withOpacity(
                    0.4,
                  ), // Dim the background distraction
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        0.2,
                      ), // 20% white glass fill per DESIGN.md
                      borderRadius: BorderRadius.circular(9999), // Pill-shaped
                    ),
                    child: TextField(
                      controller: controller.textController,
                      focusNode: controller.searchFocusNode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                      // ADD THIS SECTION:
                      onSubmitted: (value) async {
                        if (value.trim().isNotEmpty) {
                          final weatherCtrl = Get.find<WeatherController>();
                          bool success = await weatherCtrl.fetchWeatherByCity(
                            value.trim(),
                          );

                          if (success) {
                            // Save to Firestore and return home
                            final current =
                                weatherCtrl.weatherData.value!.current;
                            controller.saveSearch(
                              weatherCtrl.locationName.value,
                              'Searched',
                              current.temp,
                              current.icon,
                            );
                            Get.back();
                          } else {
                            Get.snackbar(
                              'Error',
                              'City not found',
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                      // ... rest of the decoration,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. Recently Searched Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RECENTLY SEARCHED',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2, // label-caps styling
                          color: Colors.white54,
                        ),
                      ),
                      TextButton(
                        onPressed: controller.clearRecentSearches,
                        child: const Text(
                          'Clear all',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Color(0xFFA3C9FF), // secondary color
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Mocking the Recent Search Cards from Firebase
                  
                  
                  const SizedBox(height: 32),

                  // 3. Popular Cities Section
                  const Text(
                    'POPULAR CITIES',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: [
                      _buildPopularCityChip('Paris'),
                      _buildPopularCityChip('Sydney'),
                      _buildPopularCityChip('Dubai'),
                      _buildPopularCityChip('Singapore'),
                      _buildPopularCityChip('Berlin'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for Recent Search Cards
  Widget _buildRecentSearchCard(
    String city,
    String region,
    int temp,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                region,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Text(
                '$temp°',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Text(
                'C',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for Popular City Chips
  Widget _buildPopularCityChip(String city) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(9999), // pill-shaped
      ),
      child: Text(
        city,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
