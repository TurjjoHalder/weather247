import 'package:flutter/material.dart';
import 'package:weather_247/view/home/weather_controller.dart';

Widget dailyWeatherCard({
  required String dateString,
  required String iconCode,
  required double highTemp,
  required double lowTemp,
  required WeatherController controller,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            dateString,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),

        // Weather Icon
        Expanded(
          flex: 1,
          child: Icon(
            _getIconData(iconCode),
            color: _getIconColor(iconCode),
            size: 28,
          ),
        ),

        Expanded(
          flex: 1,
          child: Text(
            controller.formatTemp(highTemp),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),

        // Temperature Bar
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.6,
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF5CA0F6),
                        Color(0xFFF6CA5C),
                      ], // Blue to Orange
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: Text(
            controller.formatTemp(lowTemp),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      ],
    ),
  );
}
// --- LOGIC HELPERS ---

// Maps OpenWeatherMap string codes to exact Flutter vector icons matching the image
IconData _getIconData(String iconCode) {
  if (iconCode.contains('01')) return Icons.wb_sunny;
  if (iconCode.contains('02') ||
      iconCode.contains('03') ||
      iconCode.contains('04'))
    return Icons.cloud_queue;
  if (iconCode.contains('09') || iconCode.contains('10'))
    return Icons.grain; // Rain
  if (iconCode.contains('11')) return Icons.flash_on; // Thunderstorm
  if (iconCode.contains('13')) return Icons.ac_unit; // Snow
  return Icons.cloud;
}

Color _getIconColor(String iconCode) {
  if (iconCode.contains('01') || iconCode.contains('02'))
    return const Color(0xFFF6CA5C); // Yellow/Orange
  return Colors.white; // Default white for clouds/rain/snow
}
