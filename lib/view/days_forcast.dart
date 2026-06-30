import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weather_247/view/common%20widget/daily_weather_card.dart';
import 'package:weather_247/view/common%20widget/unite_toggle.dart';
import 'package:weather_247/view/common%20widget/weather_insight_card.dart';
import 'package:weather_247/view/home/weather_controller.dart';

class TenDaysScreen extends StatelessWidget {
  const TenDaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WeatherController>();

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.weatherData.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final dailyList = controller.weatherData.value!.daily;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // City Name
              Text(
                controller.locationName.value.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Color(0xFF8BA5CE),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '10-Day Forecast',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  buildUnitToggle(controller),
                ],
              ),
              const SizedBox(height: 24),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dailyList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final dayData = dailyList[index];

                  final date = DateTime.fromMillisecondsSinceEpoch(
                    dayData.dt * 1000,
                  );
                  final isToday = index == 0;
                  final dateString = isToday
                      ? 'Today'
                      : DateFormat('E d').format(date);

                  return dailyWeatherCard(
                    dateString: dateString,
                    iconCode: dayData.icon,
                    highTemp: dayData.maxTemp,
                    lowTemp: dayData.minTemp,
                    controller: controller,
                  );
                },
              ),
              const SizedBox(height: 24),

              weatherInsightCard(
                icon: Icons.lightbulb_outline,
                title: 'WEATHER INSIGHT',
                description: _generateWeatherInsight(dailyList),
              ),
              const SizedBox(height: 16),

              weatherInsightCard(
                icon: Icons.water_drop_outlined,
                title: 'PRECIPITATION CHANCE',
                description: _generatePrecipitationInsight(dailyList),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  String _generateWeatherInsight(List<dynamic> dailyList) {
    if (dailyList.isEmpty) return 'Weather data is currently unavailable.';

    final currentHigh = dailyList[0].temp.max;
    final futureHigh = dailyList.last.temp.max;

    if (futureHigh < currentHigh - 3) {
      return 'Temperatures will remain above average for the next few days, with a significant drop expected by next week.';
    } else if (futureHigh > currentHigh + 3) {
      return 'Expect a warming trend over the next 7 days, bringing higher than average temperatures.';
    } else {
      return 'Temperatures will remain stable and consistent over the upcoming week with no major fluctuations.';
    }
  }

  String _generatePrecipitationInsight(List<dynamic> dailyList) {
    if (dailyList.isEmpty) return 'Precipitation data is unavailable.';

    // Search for rain in the upcoming days
    List<String> rainyDays = [];
    for (int i = 1; i < dailyList.length; i++) {
      if (dailyList[i].icon.contains('09') ||
          dailyList[i].icon.contains('10') ||
          dailyList[i].icon.contains('11')) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          dailyList[i].dt * 1000,
        );
        rainyDays.add(DateFormat('EEEE').format(date));
      }
    }

    if (rainyDays.isEmpty) {
      return 'Dry conditions expected. No significant precipitation is forecasted for the next 7 days.';
    } else if (rainyDays.length == 1) {
      return 'Expect occasional showers specifically on ${rainyDays.first}.';
    } else {
      return 'Expect occasional showers on ${rainyDays[0]} and localized thunderstorms on ${rainyDays[1]} afternoon.';
    }
  }
}
