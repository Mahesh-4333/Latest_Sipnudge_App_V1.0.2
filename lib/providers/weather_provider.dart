import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;
  final LocationService _locationService;
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  Position? _currentLocation;

  WeatherProvider(this._weatherService, this._locationService);

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentLocation => _currentLocation;

  Future<void> fetchWeatherForCurrentLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _currentLocation = await _locationService.getCurrentLocation();
      _weatherData = await _weatherService.getCurrentWeatherByCoordinates(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getWeatherDescription() {
    if (_weatherData == null) return 'Loading...';

    final condition = _weatherData!.condition.toLowerCase();

    // You can expand this as needed.
    switch (condition) {
      case 'sunny':
        return 'Sunny day';
      case 'moon stars':
      case 'clear night':
        return 'Clear night';
      case 'cloud':
      case 'cloudy':
        return 'Cloudy day';
      case 'sun cloudy':
      case 'sun & cloud':
        return 'Sun with Clouds day';
      case 'partly cloudy':
        return 'Partly cloudy';
      case 'moon cloudy':
        return 'Cloudy night';
      case 'lightning':
        return 'Lightning storm';
      case 'wet':
        return 'Moist air';
      case 'light rain':
        return 'Light drizzle';
      case 'moderate rain':
        return 'Moderate rain';
      case 'heavy rain':
        return 'Heavy rain';
      case 'rainstorm':
        return 'Rainstorm';
      case 'thunderstorm':
        return 'Thunderstorm';
      case 'heavy rainstorm':
        return 'Heavy rainstorm';
      case 'fog':
        return 'Fog';
      case 'hail':
        return 'Hail';
      case 'light snow':
        return 'Light snow';
      case 'moderate snow':
        return 'Moderate snow';
      case 'heavy snow':
        return 'Heavy snow';
      case 'snowstorm':
        return 'Snowstorm';
      case 'snow':
        return 'Snow';
      case 'windy':
        return 'Windy';
      case 'blizzard':
        return 'Blizzard';
      case 'mist':
        return 'Misty';
      case 'haze':
        return 'Hazy';
      case 'typhoon':
        return 'Typhoon';
      case 'sunrise':
        return 'Sunrise';
      case 'sunset':
        return 'Sunset';
      case 'low temperature':
        return 'Low temperature';
      case 'high temperature':
        return 'High temperature';
      case 'sparkles':
        return 'Shine bright';
      case 'full moon':
        return 'Full moon';
      case 'dry':
        return 'Dry';
      case 'blowing sand':
        return 'Blowing sand';
      case 'sandstorm':
        return 'Sandstorm';
      case 'rainbow':
        return 'Rainbow';
      default:
        // fallback
        return _weatherData!.condition;
    }
  }

  String getWeatherIcon() {
    if (_weatherData == null) {
      return 'assets/weather/01_sunny_color.png';
    }

    final iconCode = _weatherData!.iconCode;
    final condition = _weatherData!.condition.toLowerCase();

    switch (iconCode) {
      case '01d':
      case '01n':
        return 'assets/weather/01_sunny_color.png';
      case '02d':
      case '02n':
        return 'assets/weather/03_cloud_color.png';
      case '03d':
      case '03n':
        return 'assets/weather/03_cloud_color.png';
      case '04d':
      case '04n':
        return 'assets/weather/03_cloud_color.png';
      case '09d':
      case '09n':
        return 'assets/weather/09_light_rain_color.png';
      case '10d':
      case '10n':
        return 'assets/weather/10_moderate_rain_color.png';
      case '11d':
      case '11n':
        return 'assets/weather/14_thunderstorm_color.png';
      case '13d':
      case '13n':
        return 'assets/weather/22_snow_color.png';
      case '50d':
      case '50n':
        return 'assets/weather/25_mist_color.png';
      default:
        // Try matching by condition if iconCode didn’t match
        return _getIconByCondition(condition);
    }
  }

  String _getIconByCondition(String condition) {
    switch (condition) {
      case 'sunny':
        return 'assets/weather/01_sunny_color.png';
      case 'moon stars':
        return 'assets/weather/02_moon_stars_color.png';
      case 'clear night':
        return 'assets/weather/01_sunny_color.png';
      case 'cloud':
        return 'assets/weather/03_cloud_color.png';
      case 'cloudy':
        return 'assets/weather/06_cloudy_color.png';
      case 'sun cloudy':
        return 'assets/weather/04_sun_cloudy_color.png';
      case 'partly cloudy':
      case 'sun & cloud':
        return 'assets/weather/04_sun_cloudy_color.png';
      case 'moon cloudy':
        return 'assets/weather/03_cloud_color.png';
      case 'light rain':
        return 'assets/weather/09_light_rain_color.png';
      case 'moderate rain':
        return 'assets/weather/10_moderate_rain_color.png';
      case 'heavy rain':
        return 'assets/weather/11_heavy_rain_color.png';
      case 'rainstorm':
        return 'assets/weather/12_rainstorm_color.png';
      case 'heavy rainstorm':
        return 'assets/weather/13_heavy_rainstorm_color.png';
      case 'thunderstorm':
        return 'assets/weather/14_thunderstorm_color.png';
      case 'fog':
        return 'assets/weather/15_fog_color.png';
      case 'hail':
        return 'assets/weather/16_hail_color.png';
      case 'light snow':
        return 'assets/weather/16_light_snow_color.png';
      case 'snow':
        return 'assets/weather/22_snow_color.png';
      case 'moderate snow':
        return 'assets/weather/1_moderate_snow_color.png';
      case 'heavy snow':
        return 'assets/weather/19_heavy_snow_color.png';
      case 'snowstorm':
        return 'assets/weather/20_snowstorm_color.png';
      case 'windy':
        return 'assets/weather/23_windy_color.png';
      case 'blizzard':
        return 'assets/weather/24_blizzard_color.png';
      case 'mist':
        return 'assets/weather/25_mist_color.png';
      case 'haze':
        return 'assets/weather/26_haze_color.png';
      case 'typhoon':
        return 'assets/weather/27_typhoon_color.png';
      case 'sunrise':
        return 'assets/weather/29_sunrise_color.png';
      case 'sunset':
        return 'assets/weather/30_sunset_color.png';
      case 'low temperature':
        return 'assets/weather/31_low_temperature_color.png';
      case 'high temperature':
        return 'assets/weather/32_high_temperature_color.png';
      case 'sparkles':
        return 'assets/weather/33_sparkles_color.png';
      case 'full moon':
        return 'assets/weather/34_full_moon_color.png';
      case 'partly cloud day':
        return 'assets/weather/35_partly_cloudy_daytime_color.png';
      case 'partly cloud night':
        return 'assets/weather/36_partly_cloudy_night_color.png';
      case 'dry':
        return 'assets/weather/37_dry_color.png';
      case 'blowing sand':
        return 'assets/weather/38_blowing_sand_color.png';
      case 'sandstorm':
        return 'assets/weather/39_sandstorm_color.png';
      case 'rainbow':
        return 'assets/weather/40_rainbow_color.png';
      default:
        return 'assets/weather/01_sunny_color.png';
    }
  }
}

//===================== lib/providers/weather_provider.dart ==================//
// import 'package:flutter/material.dart';
// import '../services/weather_service.dart';
// import '../services/location_service.dart';
// import 'package:geolocator/geolocator.dart';

// class WeatherProvider extends ChangeNotifier {
//   final WeatherService _weatherService;
//   final LocationService _locationService;
//   WeatherData? _weatherData;
//   bool _isLoading = false;
//   String? _error;
//   Position? _currentLocation;

//   WeatherProvider(this._weatherService, this._locationService);

//   WeatherData? get weatherData => _weatherData;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   Position? get currentLocation => _currentLocation;

//   Future<void> fetchWeatherForCurrentLocation() async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();
//       _currentLocation = await _locationService.getCurrentLocation();
//       _weatherData = await _weatherService.getCurrentWeatherByCoordinates(
//         _currentLocation!.latitude,
//         _currentLocation!.longitude,
//       );
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   String getWeatherDescription() {
//     if (_weatherData == null) return 'Loading...';

//     switch (_weatherData!.condition.toLowerCase()) {
//       case 'clear':
//         return 'Sunny day';
//       case 'clouds':
//         return 'Cloudy day';
//       case 'rain':
//         return 'Rainy day';
//       case 'thunderstorm':
//         return 'Thunderstorm';
//       case 'smoke':
//         return 'Smoggy day';
//       case 'moon stars':
//         return 'Clear night';
//       default:
//         return _weatherData!.condition;
//     }
//   }

//   String getWeatherIcon() {
//     print('=== getWeatherIcon() called ===');

//     if (_weatherData == null) {
//       print('Weather data is null, returning sunny_ic.svg');
//       //return 'assets/images/sunny_ic.svg';
//       return 'assets/weather/01_sunny_color.png';
//     }

//     final iconCode = _weatherData!.iconCode;
//     print('Icon Code from API: "$iconCode"');
//     print('Weather Condition: "${_weatherData!.condition}"');

//     // Handle both day and night versions
//     switch (iconCode) {
//       // Clear sky
//       case '01d':
//         print('Matched case: 01d (Clear sky - day)');
//         //return 'assets/images/sunny_ic.svg';
//         return 'assets/weather/01_sunny_color.png';
//       case '01n':
//         print('Matched case: 01n (Clear sky - night)');
//         //return 'assets/images/sunny_ic.svg';
//         return 'assets/weather/01_sunny_color.png';

//       // Few clouds
//       case '02d':
//         print('Matched case: 02d (Few clouds - day)');
//         //return 'assets/images/cloudy_ic.svg';
//         return 'assets/weather/03_cloud_color.png';
//       case '02n':
//         print('Matched case: 02n (Few clouds - night)');
//         //return 'assets/images/cloudy_ic.svg';
//         return 'assets/weather/03_cloud_color.png';

//       // Scattered clouds
//       case '03d':
//         print('Matched case: 03d (Scattered clouds - day)');
//         // return 'assets/images/cloudy_ic.svg';
//         return 'assets/weather/03_cloud_color.png';
//       case '03n':
//         print('Matched case: 03n (Scattered clouds - night)');
//         // return 'assets/images/cloudy_ic.svg';
//         return 'assets/weather/03_cloud_color.png';

//       // Broken clouds
//       case '04d':
//         print('Matched case: 04d (Broken clouds - day)');
//         // return 'assets/images/cloudy_ic.svg';
//         return 'assets/weather/03_cloud_color.png';
//       case '04n':
//         print('Matched case: 04n (Broken clouds - night)');
//         // return 'assets/images/cloudy_ic.svg';
//         return 'assets/weather/03_cloud_color.png';

//       // Shower rain
//       case '09d':
//         print('Matched case: 09d (Shower rain - day)');
//         // return 'assets/images/rainy_ic.svg';
//         return 'assets/weather/09_light_rain_color.png';
//       case '09n':
//         print('Matched case: 09n (Shower rain - night)');
//         // return 'assets/images/rainy_ic.svg';
//         return 'assets/weather/09_light_rain_color.png';

//       // Rain
//       case '10d':
//         print('Matched case: 10d (Rain - day)');
//         // return 'assets/images/rainy_ic.svg';
//         return 'assets/weather/10_moderate_rain_color.png';
//       case '10n':
//         print('Matched case: 10n (Rain - night)');
//         // return 'assets/images/rainy_ic.svg';
//         return 'assets/weather/10_moderate_rain_color.png';

//       // Thunderstorm
//       case '11d':
//         print('Matched case: 11d (Thunderstorm - day)');
//         // return 'assets/images/lightning_ic.svg';
//         return 'assets/weather/14_thunderstorm_color.png';
//       case '11n':
//         print('Matched case: 11n (Thunderstorm - night)');
//         // return 'assets/images/lightning_ic.svg';
//         return 'assets/weather/14_thunderstorm_color.png';

//       // Snow
//       case '13d':
//         print('Matched case: 13d (Snow - day)');
//         // return 'assets/images/cloudy_ic.svg';
//         return 'assets/weather/22_snow_color.png';
//       case '13n':
//         print('Matched case: 13n (Snow - night)');
//         // return 'assets/images/cloudy_ic.svg';
//         return 'assets/weather/22_snow_color.png';

//       // Mist/Fog
//       case '50d':
//         print('Matched case: 50d (Mist/Fog - day)');
//         // return 'assets/images/cloudy_ic.svg';
//         return 'assets/weather/25_mist_color.png';
//       case '50n':
//         print('Matched case: 50n (Mist/Fog - night)');
//         // return 'assets/images/cloudy_ic.svg';
//         return 'assets/weather/25_mist_color.png';

//       default:
//         print(
//             'No icon code match found, falling back to condition-based logic');
//         print('Calling _getIconByCondition with: "${_weatherData!.condition}"');
//         return _getIconByCondition(_weatherData!.condition);
//     }
//   }

//   String _getIconByCondition(String condition) {
//     print('=== _getIconByCondition() called ===');
//     print('Input condition: "$condition"');
//     print('Lowercase condition: "${condition.toLowerCase()}"');

//     switch (condition.toLowerCase()) {
//       case 'clear':
//         //print('Matched condition: clear -> sunny_ic.svg');
//         // return 'assets/images/sunny_ic.svg';
//         print('Matched condition: clear -> 01_sunny_color.png');
//         return 'assets/weather/01_sunny_color.png';
//       case 'clouds':
//         //print('Matched condition: clouds -> cloudy_ic.svg');
//         // return 'assets/images/cloudy_ic.svg';
//         print('Matched condition: clouds -> 03_cloudy_color.png');
//         return 'assets/weather/03_cloud_color.png';
//       case 'rain':
//         // print('Matched condition: rain -> rainy_ic.svg');
//         // return 'assets/images/rainy_ic.svg';
//         print('Matched condition: rain -> 09_light_rain_color.png');
//         return 'assets/weather/09_light_rain_color.png';
//       case 'drizzle':
//         // print('Matched condition: drizzle -> rainy_ic.svg');
//         // return 'assets/images/rainy_ic.svg';
//         print('Matched condition: drizzle -> 24_blizzard_color.png');
//         return 'assets/weather/24_blizzard_color.png';
//       case 'thunderstorm':
//         // print('Matched condition: thunderstorm -> lightning_ic.svg');
//         // return 'assets/images/lightning_ic.svg';
//         print('Matched condition: thunderstorm ->  14_thunderstorm_color.png');
//         return 'assets/weather/14_thunderstorm_color.png';
//       case 'snow':
//         // print('Matched condition: snow -> cloudy_ic.svg');
//         // return 'assets/images/cloudy_ic.svg';
//         print('Matched condition: snow -> 22_snow_color.png');
//         return 'assets/weather/22_snow_color.png';
//       case 'mist':
//         // print('Matched condition: mist -> cloudy_ic.svg');
//         // return 'assets/images/cloudy_ic.svg';
//         print('Matched condition: mist -> 25_mist_color.png');
//         return 'assets/weather/25_mist_color.png';
//       case 'smoke':
//         // print('Matched condition: smoke -> cloudy_ic.svg');
//         // return 'assets/images/cloudy_ic.svg';
//         print('Matched condition: smoke -> 27_typhoon_color.png');
//         return 'assets/weather/27_typhoon_color.png';
//       case 'haze':
//         // print('Matched condition: haze -> cloudy_ic.svg');
//         // return 'assets/images/cloudy_ic.svg';
//         print('Matched condition: haze -> 26_haze_color.png');
//         return 'assets/weather/26_haze_color.png';
//       case 'dust':
//         // print('Matched condition: dust -> cloudy_ic.svg');
//         // return 'assets/images/cloudy_ic.svg';
//         print('Matched condition: dust -> 23_windy_color.png');
//         return 'assets/weather/23_wi                                                                                                                  zndy_color.png';
//       case 'fog':
//         // print('Matched condition: fog -> cloudy_ic.svg');
//         // return 'assets/images/cloudy_ic.svg';
//         print('Matched condition: fog -> 15_fog_color.png');
//         return 'assets/weather/15_fog_color.png';
//       default:
//         print('No condition match found, returning default: sunny_ic.svg');
//         print(
//             'Available conditions were: clear, clouds, rain, drizzle, thunderstorm, snow, mist, smoke, haze, dust, fog');
//         return 'assets/images/sunny_ic.svg';
//     }
//   }
// }
