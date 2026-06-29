import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_247/view/home/weather_controller.dart';
import 'search_cities_controller.dart';

class SearchCitiesScreen extends StatelessWidget {
  const SearchCitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchCityController());

    return Scaffold(
      backgroundColor: const Color(0xFF131313), // Atmospheric Clarity surface default
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
                filter: ImageFilter.blur(sigmaX: 60.0, sigmaY: 60.0), // 60px blur per DESIGN.md
                child: Container(
                  color: Colors.black.withOpacity(0.4), // Dim the background distraction
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // 20% white glass fill per DESIGN.md
                      borderRadius: BorderRadius.circular(9999), // Pill-shaped
                    ),
                    child: TextField(
                      controller: controller.textController,
                      focusNode: controller.searchFocusNode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                      onSubmitted: (value) async {
                        if (value.trim().isNotEmpty) {
                          final weatherCtrl = Get.find<WeatherController>();
                          bool success = await weatherCtrl.fetchWeatherByCity(value.trim());

                          if (success) {
                            // Save to Firestore and return home
                            final current = weatherCtrl.weatherData.value!.current;
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
                      // THE MISSING DECORATION:
                      decoration: InputDecoration(
                        hintText: 'Search for a city or airport',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. Recently Searched Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RECENTLY SEARCHED',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.white54,
                        ),
                      ),
                      TextButton(
                        onPressed: controller.clearRecentSearches,
                        child: const Text(
                          'Clear all',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Color(0xFFA3C9FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // THE MISSING FIRESTORE LIST:
                  Obx(() {
                    if (controller.isLoadingHistory.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: CircularProgressIndicator(color: Colors.white)),
                      );
                    }

                    if (controller.recentSearches.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'No recent searches.',
                          style: TextStyle(color: Colors.white54, fontFamily: 'Plus Jakarta Sans'),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.recentSearches.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = controller.recentSearches[index];
                        IconData iconMap = item['icon'] == 'wb_sunny' ? Icons.wb_sunny : Icons.cloud;

                        return GestureDetector(
                          onTap: () {
                            // Fetch this specific city and go back to the home screen
                            Get.find<WeatherController>().fetchWeatherByCity(item['city']);
                            Get.back();
                          },
                          child: _buildRecentSearchCard(
                            item['city'] ?? 'Unknown',
                            item['region'] ?? 'Unknown',
                            (item['temp'] ?? 0).round(),
                            iconMap,
                          ),
                        );
                      },
                    );
                  }),
                  
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
                      // Wrapped these in GestureDetectors too so they are functional!
                      GestureDetector(
                        onTap: () {
                          Get.find<WeatherController>().fetchWeatherByCity('Paris');
                          Get.back();
                        },
                        child: _buildPopularCityChip('Paris'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.find<WeatherController>().fetchWeatherByCity('Sydney');
                          Get.back();
                        },
                        child: _buildPopularCityChip('Sydney'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.find<WeatherController>().fetchWeatherByCity('Dubai');
                          Get.back();
                        },
                        child: _buildPopularCityChip('Dubai'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.find<WeatherController>().fetchWeatherByCity('Singapore');
                          Get.back();
                        },
                        child: _buildPopularCityChip('Singapore'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.find<WeatherController>().fetchWeatherByCity('Berlin');
                          Get.back();
                        },
                        child: _buildPopularCityChip('Berlin'),
                      ),
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
  Widget _buildRecentSearchCard(String city, String region, int temp, IconData icon) {
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
          Expanded(
            child: Column(
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
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  region,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
        borderRadius: BorderRadius.circular(9999), 
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