import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_247/view/common widget/glass_container.dart';
import 'package:weather_247/core/theme/colors.dart';
import 'package:weather_247/view/days_forcast.dart';
import 'package:weather_247/view/search/search_cities_screen.dart';
import 'weather_controller.dart';
import 'package:intl/intl.dart';
// Import your custom GlassContainer, theme, and controller here

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate or find the GetX controller
    final controller = Get.put(WeatherController());

    return Scaffold(
      backgroundColor: Colors.black, // Fallback color
      body: Stack(
        children: [
          // 1. Level 0: Dynamic Weather Background
          Positioned.fill(
            child: Image.network(
              controller.backgroundUrl.value,
              fit: BoxFit.cover,
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Obx(() {
              // 1. Check if it's loading
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              // 2. NEW: Check if there's an error message
              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Text(
                    controller.errorMessage.value,

                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              // 3. NEW: Safely check if data is null before using the "!" operator
              if (controller.weatherData.value == null) {
                return const Center(
                  child: Text(
                    'No weather data available.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // 4. Now it is 100% safe to use the "!" operator
              final current = controller.weatherData.value!.current;
              final String formattedDate = DateFormat(
                'EEEE, d MMM',
              ).format(DateTime.now());

              return SingleChildScrollView(
                // ... the rest of your UI code ...(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location & Date Header
                    // Location, Date & Search Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  controller.locationName.value, // Or bind to actual location later
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.near_me,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${current.description.capitalizeFirst} • $formattedDate',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                color: Color(0xFFC4C7C8),
                              ),
                            ),
                          ],
                        ),
                        // THE NEW SEARCH BUTTON
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            // This triggers the GetX navigation to your Search Screen
                            onPressed: () =>
                                Get.to(() => const SearchCitiesScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   '${current.description.capitalizeFirst} • $formattedDate',
                    //   style: const TextStyle(
                    //     fontFamily: 'Plus Jakarta Sans',
                    //     fontSize: 16,
                    //     color: Color(0xFFC4C7C8), // on-surface-variant
                    //   ),
                    // ),
                    // const SizedBox(height: 32),

                    // Display Temp & C/F Toggle (Mocked inline)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${current.temp.round()}°',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 96,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.04,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Placeholder for your Pill-shaped Unit Toggle
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'C / F',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'H: 26°   L: 18°', // Bind to Daily model min/max
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 32),

                    // Hourly Forecast (Glass Container)
                    GlassContainer(
                      blur: 30.0,
                      opacity: 0.15,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'HOURLY FORECAST',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    controller.weatherData.value!.hourly.length,
                                itemBuilder: (context, index) {
                                  final hourData = controller
                                      .weatherData
                                      .value!
                                      .hourly[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 24.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '14:00',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ), // Format dt here
                                        const Icon(
                                          Icons.wb_sunny,
                                          color: Colors.amber,
                                        ), // Map icon code
                                        Text(
                                          '${hourData.temp.round()}°',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                
                    // THE NEW 10-DAY FORECAST BUTTON
                    GestureDetector(
                      onTap: () => Get.to(() => const TenDaysScreen()),
                      child: GlassContainer(
                        blur: 20.0,
                        opacity: 0.1,
                        borderRadius: BorderRadius.circular(
                          9999,
                        ), // Pill-shaped per DESIGN.md
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '10-Day Forecast',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16), // Space before Bento Grid
                    // Bento Grid: UV, Wind, Humidity, Visibility
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: [
                        _buildBentoCard(
                          'UV Index',
                          Icons.wb_sunny_outlined,
                          '${current.uvi}',
                          'Moderate',
                        ),
                        _buildBentoCard(
                          'Wind',
                          Icons.air,
                          '${current.windSpeed.round()}',
                          'km/h',
                        ),
                        _buildBentoCard(
                          'Humidity',
                          Icons.water_drop_outlined,
                          '${current.humidity}%',
                          'Dew point 16°',
                        ),
                        _buildBentoCard(
                          'Visibility',
                          Icons.visibility_outlined,
                          '${(current.visibility / 1000).round()}',
                          'km',
                        ),
                      ],
                    ),

                    const SizedBox(height: 80), // Safe zone for bottom nav
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Helper method for the Bento Grid modules
  Widget _buildBentoCard(
    String title,
    IconData icon,
    String value,
    String subtitle,
  ) {
    return GlassContainer(
      blur: 30.0,
      opacity: 0.15,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
