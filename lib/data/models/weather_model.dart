class WeatherData {
  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      current: CurrentWeather.fromJson(json['current']),
      hourly: (json['hourly'] as List)
          .map((item) => HourlyWeather.fromJson(item))
          .toList(),
      daily: (json['daily'] as List)
          .map((item) => DailyWeather.fromJson(item))
          .toList(),
    );
  }
}

class CurrentWeather {
  final double temp;
  final double feelsLike;
  final int humidity;
  final double uvi;
  final int visibility;
  final double windSpeed;
  final String description;
  final String icon;

  CurrentWeather({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.uvi,
    required this.visibility,
    required this.windSpeed,
    required this.description,
    required this.icon,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temp: (json['temp']).toDouble(),
      feelsLike: (json['feels_like']).toDouble(),
      humidity: json['humidity'],
      uvi: (json['uvi']).toDouble(),
      visibility: json['visibility'],
      windSpeed: (json['wind_speed']).toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}

class HourlyWeather {
  final int dt;
  final double temp;
  final String icon;

  HourlyWeather({required this.dt, required this.temp, required this.icon});

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      dt: json['dt'],
      temp: (json['temp']).toDouble(),
      icon: json['weather'][0]['icon'],
    );
  }
}

class DailyWeather {
  final int dt;
  final Temperature temp;
  final double minTemp;
  final double maxTemp;
  final String icon;

  DailyWeather({
    required this.dt,
    required this.temp,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      dt: json['dt'],
      temp: Temperature.fromJson(json['temp']),
      minTemp: (json['temp']['min']).toDouble(),
      maxTemp: (json['temp']['max']).toDouble(),
      icon: json['weather'][0]['icon'],
    );
  }
}

class Temperature {
  final double min;
  final double max;

  Temperature({required this.min, required this.max});

  factory Temperature.fromJson(Map<String, dynamic> json) {
    return Temperature(
      min: (json['min'] ?? 0.0).toDouble(),
      max: (json['max'] ?? 0.0).toDouble(),
    );
  }
}
