import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/weather_data.dart';
import '../services/app_settings_service.dart';
import '../services/weather_service.dart';
import '../utils/app_text.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();
  final TextEditingController _locationController = TextEditingController();
  Timer? _searchDebounce;

  late WeatherLocation _selectedLocation;
  WeatherData? _data;
  String? _error;
  bool _isLoading = true;
  bool _isSearching = false;
  List<WeatherLocation> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _selectedLocation = WeatherService.starterLocations.first;
    _locationController.text = _selectedLocation.compactLabel;
    _loadWeather();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchWeather(_selectedLocation);
      if (!mounted) return;
      setState(() {
        _data = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () async {
      if (value.trim().length < 2) {
        if (!mounted) return;
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);
      try {
        final results = await _service.searchLocations(value);
        if (!mounted) return;
        setState(() {
          _suggestions = results;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _suggestions = [];
        });
      } finally {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  void _selectLocation(WeatherLocation location) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedLocation = location;
      _locationController.text = location.compactLabel;
      _suggestions = [];
    });
    _loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.get('weather_screen_title')),
        actions: [
          IconButton(
            onPressed: _loadWeather,
            icon: const Icon(Icons.refresh),
            tooltip: AppText.get('refresh'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/weather.jpeg'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Container(
          color: const Color(0xFFEAF5FF).withValues(alpha: 0.08),
          child: Theme(
            data: Theme.of(context).copyWith(
              cardTheme: CardThemeData(
                color: const Color(0xFFEAF5FF).withValues(alpha: 0.84),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.get('weather'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppText.get('weather_search_hint'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: AppText.get('weather_search_label'),
                hintText: AppText.get('weather_search_hint'),
                border: const OutlineInputBorder(),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchChanged,
            ),
            if (_suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDDB2)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final location = _suggestions[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined),
                      title: Text(
                        location.compactLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        location.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _selectLocation(location),
                    );
                  },
                ),
              ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 180,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      _selectedLocation.latitude,
                      _selectedLocation.longitude,
                    ),
                    initialZoom: 9.5,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.flutter_application_1',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: LatLng(
                            _selectedLocation.latitude,
                            _selectedLocation.longitude,
                          ),
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(
                    _error!.isEmpty ? AppText.get('weather_error') : _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (_data != null)
              Expanded(
                child: ListView(
                  children: [
                    _CurrentWeatherCard(data: _data!),
                    const SizedBox(height: 16),
                    Text(
                      AppText.get('forecast_5day'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    ..._data!.dailyForecasts.skip(1).map(
                          (day) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today_outlined),
                              title: Text(_formatDate(day.date)),
                              subtitle: Text(
                                _weatherLabel(day.weatherCode),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${day.maxTempC.toStringAsFixed(0)} / ${day.minTempC.toStringAsFixed(0)} C',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text('${AppText.get('rain')}: ${day.rainChance}%'),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
          ],
          ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = AppSettingsService.instance.isTelugu
        ? ['సోమ', 'మంగళ', 'బుధ', 'గురు', 'శుక్ర', 'శని', 'ఆది']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = AppSettingsService.instance.isTelugu
        ? ['జన', 'ఫిబ్ర', 'మార్', 'ఏప్రి', 'మే', 'జూన్', 'జూలై', 'ఆగ', 'సెప్', 'అక్ట్', 'నవం', 'డిసె']
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _weatherLabel(int code) {
    switch (code) {
      case 0:
        return AppText.get('weather_clear');
      case 1:
        return AppText.get('weather_mainly_clear');
      case 2:
      case 3:
        return AppText.get('weather_partly_cloudy');
      case 45:
      case 48:
        return AppText.get('weather_fog');
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return AppText.get('weather_drizzle');
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return AppText.get('weather_rain_label');
      case 71:
      case 73:
      case 75:
      case 77:
        return AppText.get('weather_snow');
      case 80:
      case 81:
      case 82:
        return AppText.get('weather_showers');
      case 95:
      case 96:
      case 99:
        return AppText.get('weather_thunderstorm');
      default:
        return code <= 3
            ? AppText.get('weather_overcast')
            : AppText.get('weather_unknown');
    }
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  const _CurrentWeatherCard({required this.data});

  final WeatherData data;

  @override
  Widget build(BuildContext context) {
    final isTelugu = AppSettingsService.instance.isTelugu;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.locationName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _labelForCode(data.currentWeatherCode, isTelugu),
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              _Metric(
                label: AppText.get('temperature_short'),
                value: '${data.currentTempC.toStringAsFixed(1)} C',
              ),
              _Metric(
                label: AppText.get('humidity'),
                value: '${data.currentHumidity}%',
              ),
              _Metric(
                label: AppText.get('wind'),
                value: '${data.currentWindKmh.toStringAsFixed(0)} km/h',
              ),
              _Metric(
                label: AppText.get('rain'),
                value: '${data.currentRainMm.toStringAsFixed(1)} mm',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelForCode(int code, bool isTelugu) {
    switch (code) {
      case 0:
        return AppText.get('weather_clear');
      case 1:
        return AppText.get('weather_mainly_clear');
      case 2:
      case 3:
        return AppText.get('weather_partly_cloudy');
      case 45:
      case 48:
        return AppText.get('weather_fog');
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return AppText.get('weather_drizzle');
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return AppText.get('weather_rain_label');
      case 71:
      case 73:
      case 75:
      case 77:
        return AppText.get('weather_snow');
      case 80:
      case 81:
      case 82:
        return AppText.get('weather_showers');
      case 95:
      case 96:
      case 99:
        return AppText.get('weather_thunderstorm');
      default:
        return AppText.get('weather_unknown');
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
