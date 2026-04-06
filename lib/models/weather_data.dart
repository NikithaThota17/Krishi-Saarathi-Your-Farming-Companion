class WeatherData {
  WeatherData({
    required this.locationName,
    required this.currentTempC,
    required this.currentHumidity,
    required this.currentWindKmh,
    required this.currentRainMm,
    required this.currentWeatherCode,
    required this.dailyForecasts,
  });

  final String locationName;
  final double currentTempC;
  final int currentHumidity;
  final double currentWindKmh;
  final double currentRainMm;
  final int currentWeatherCode;
  final List<DailyForecast> dailyForecasts;
}

class DailyForecast {
  DailyForecast({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.rainChance,
    required this.weatherCode,
  });

  final DateTime date;
  final double maxTempC;
  final double minTempC;
  final int rainChance;
  final int weatherCode;
}

class WeatherLocation {
  const WeatherLocation({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.locality,
    this.district,
    this.state,
  });

  final String displayName;
  final double latitude;
  final double longitude;
  final String? locality;
  final String? district;
  final String? state;

  String get compactLabel {
    final parts = <String>[
      if (locality != null && locality!.isNotEmpty) locality!,
      if (district != null && district!.isNotEmpty) district!,
      if (state != null && state!.isNotEmpty) state!,
    ];
    if (parts.isEmpty) return displayName;
    return parts.take(3).join(', ');
  }
}
