import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_data.dart';

class WeatherService {
  static const List<WeatherLocation> starterLocations = [
    WeatherLocation(
      displayName: 'Pusa, Samastipur, Bihar, India',
      locality: 'Pusa',
      district: 'Samastipur',
      state: 'Bihar',
      latitude: 25.98,
      longitude: 85.67,
    ),
    WeatherLocation(
      displayName: 'Adilabad, Telangana, India',
      locality: 'Adilabad',
      district: 'Adilabad',
      state: 'Telangana',
      latitude: 19.66,
      longitude: 78.53,
    ),
    WeatherLocation(
      displayName: 'Baramati, Pune, Maharashtra, India',
      locality: 'Baramati',
      district: 'Pune',
      state: 'Maharashtra',
      latitude: 18.15,
      longitude: 74.58,
    ),
  ];

  Future<List<WeatherLocation>> searchLocations(String query) async {
    if (query.trim().length < 2) return const [];

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query.trim(),
      'format': 'jsonv2',
      'addressdetails': '1',
      'countrycodes': 'in',
      'limit': '10',
    });

    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': 'Krishi-Saarathi/1.0 (weather-search)',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Location search failed (${response.statusCode}).');
    }

    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    return json.map((item) {
      final address = (item['address'] as Map<String, dynamic>?) ?? {};
      final locality = _firstNonEmpty([
        address['village'] as String?,
        address['town'] as String?,
        address['city'] as String?,
        address['hamlet'] as String?,
        address['suburb'] as String?,
      ]);
      final district = _firstNonEmpty([
        address['county'] as String?,
        address['state_district'] as String?,
      ]);
      final state = address['state'] as String?;

      return WeatherLocation(
        displayName: item['display_name'] as String? ?? 'Unknown',
        locality: locality,
        district: district,
        state: state,
        latitude: double.tryParse(item['lat']?.toString() ?? '') ?? 0,
        longitude: double.tryParse(item['lon']?.toString() ?? '') ?? 0,
      );
    }).toList();
  }

  Future<WeatherData> fetchWeather(WeatherLocation location) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=${location.latitude}'
      '&longitude=${location.longitude}'
      '&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,weather_code'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max'
      '&forecast_days=6'
      '&timezone=auto',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Weather service unavailable (${response.statusCode}).');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final times = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List).cast<num>();
    final rainChance = (daily['precipitation_probability_max'] as List).cast<num>();
    final codes = (daily['weather_code'] as List).cast<num>();

    final forecasts = <DailyForecast>[];
    for (int i = 0; i < times.length; i++) {
      forecasts.add(
        DailyForecast(
          date: DateTime.parse(times[i]),
          maxTempC: maxTemps[i].toDouble(),
          minTempC: minTemps[i].toDouble(),
          rainChance: rainChance[i].toInt(),
          weatherCode: codes[i].toInt(),
        ),
      );
    }

    return WeatherData(
      locationName: location.compactLabel,
      currentTempC: (current['temperature_2m'] as num).toDouble(),
      currentHumidity: (current['relative_humidity_2m'] as num).toInt(),
      currentWindKmh: (current['wind_speed_10m'] as num).toDouble(),
      currentRainMm: (current['precipitation'] as num).toDouble(),
      currentWeatherCode: (current['weather_code'] as num).toInt(),
      dailyForecasts: forecasts,
    );
  }

  static String weatherLabel(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Fog';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow / Ice';
    if (code <= 82) return 'Showers';
    if (code <= 86) return 'Snow Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}
