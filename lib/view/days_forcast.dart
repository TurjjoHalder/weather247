import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weather_247/view/common%20widget/glass_container.dart';
import 'package:weather_247/view/home/weather_controller.dart'; // Add 'intl' to pubspec.yaml for date formatting
// Import your WeatherController and GlassContainer here

class TenDaysScreen extends StatelessWidget {
  const TenDaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WeatherController controller = Get.find<WeatherController>();

    return Scaffold(
      backgroundColor: const Color(0xFF131313), // Base surface color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '10-Day Forecast',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Dynamic Background Image (Level 0)
          Positioned.fill(
            child: Image.network(
              'https://images.pexels.com/photos/30617942/pexels-photo-30617942/free-photo-of-contemporary-skyscrapers-in-downtown-new-york-city.jpeg', // Replace with dynamic logic
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              final dailyData = controller.weatherData.value!.daily;

              // Ensure we only show up to 10 days (API might return 8, requires OneCall 3.0/4.0 for more)
              final displayCount = dailyData.length > 10
                  ? 10
                  : dailyData.length;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: GlassContainer(
                  blur: 30.0,
                  opacity: 0.15, // 15% opacity per DESIGN.md
                  borderRadius: BorderRadius.circular(16.0), // rounded-lg
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24.0,
                      horizontal: 16.0,
                    ),
                    itemCount: displayCount,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(
                        color: Colors.white.withOpacity(0.1),
                        height: 1,
                      ),
                    ),
                    itemBuilder: (context, index) {
                      final day = dailyData[index];
                      // Convert Unix timestamp to DateTime
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        day.dt * 1000,
                      );

                      // Format: "Today" for index 0, otherwise "Mon", "Tue", etc.
                      final dayString = index == 0
                          ? 'Today'
                          : DateFormat('EEE').format(date);

                      return _buildDailyRow(
                        dayString,
                        day.icon,
                        day.minTemp,
                        day.maxTemp,
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRow(
    String day,
    String iconCode,
    double minTemp,
    double maxTemp,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Date (Left)
        SizedBox(
          width: 60,
          child: Text(
            day,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),

        // 2. Icon (Center)
        // Note: Replace with actual local asset mapping for vibrant, multi-colored icons per DESIGN.md
        const Icon(Icons.cloud, color: Colors.white70, size: 28),

        // 3. High/Low Range (Right)
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${minTemp.round()}°',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  color: Colors.white.withOpacity(
                    0.7,
                  ), // on-surface-variant equivalent
                ),
              ),
              const SizedBox(width: 8),

              // Subtle Horizontal Bar (Temperature Range Indicator)
              Container(
                width: 80,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999), // rounded-full
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.6),
                      Colors.orange.withOpacity(0.8),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),
              SizedBox(
                width: 30, // Fixed width to align temperatures neatly
                child: Text(
                  '${maxTemp.round()}°',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
