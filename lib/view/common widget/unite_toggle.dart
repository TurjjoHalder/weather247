import 'package:flutter/material.dart';
import 'package:weather_247/view/home/weather_controller.dart';

Widget buildUnitToggle(WeatherController controller) {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: () {
            if (!controller.isCelsius.value) controller.toggleUnits();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: controller.isCelsius.value
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'C°',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (controller.isCelsius.value) controller.toggleUnits();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: !controller.isCelsius.value
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'F°',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
