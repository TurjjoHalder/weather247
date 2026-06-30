import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_247/view/common widget/glass_container.dart';
import 'package:weather_247/view/common%20widget/unite_toggle.dart';
import 'package:weather_247/view/days_forcast.dart';
import 'package:weather_247/view/search/search_cities_screen.dart';
import 'weather_controller.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WeatherController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  child: Image.asset(
                    controller.backgroundAsset.value,
                    key: ValueKey(controller.backgroundAsset.value),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),

          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

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

            if (controller.weatherData.value == null) {
              return const Center(
                child: Text(
                  'No weather data available.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final current = controller.weatherData.value!.current;
            final String formattedDate = DateFormat(
              'EEEE, d MMM',
            ).format(DateTime.now());

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),

              clipBehavior: Clip.none,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16.0,
                bottom: MediaQuery.of(context).padding.bottom + 16.0,
                left: 20.0,
                right: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                controller.locationName.value,
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
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),

                          onPressed: () =>
                              Get.to(() => const SearchCitiesScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          controller.formatTemp(current.temp),
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 96,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.04,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      Obx(() => buildUnitToggle(controller)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.weatherData.value == null ||
                        controller.weatherData.value!.daily.isEmpty) {
                      return const Text(
                        '{H: --°   L: --°}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                      );
                    }

                    final today = controller.weatherData.value!.daily[0];

                    return Text(
                      'H: ${controller.formatTemp(today.temp.max)}   L: ${controller.formatTemp(today.temp.min)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                  const SizedBox(height: 32),

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
                          Obx(() {
                            if (controller.weatherData.value == null)
                              return const SizedBox();

                            final hourlyList =
                                controller.weatherData.value!.hourly;

                            return SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: hourlyList.length > 24
                                    ? 24
                                    : hourlyList.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final hourData = hourlyList[index];

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        controller.formatHour(hourData.dt),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      Image.network(
                                        'https://openweathermap.org/img/wn/${hourData.icon}@2x.png',
                                        width: 40,
                                      ),
                                      const SizedBox(height: 8),

                                      Obx(
                                        () => Text(
                                          controller.formatTemp(hourData.temp),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // forcast button
                  GestureDetector(
                    onTap: () => Get.to(() => const TenDaysScreen()),
                    child: GlassContainer(
                      blur: 20.0,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(9999),
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

                  const SizedBox(height: 16),
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

                  const SizedBox(height: 80),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
