import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class WeatherApiException implements Exception {
  final String message;
  WeatherApiException(this.message);
}

class WeatherData {
  final double temperature;
  final int humidity; // ✅ Added
  final String condition;
  final String iconCode;

  WeatherData({
    required this.temperature,
    required this.humidity, // ✅ Added
    required this.condition,
    required this.iconCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['main']['temp'].toDouble(),
      humidity: json['main']['humidity'], // ✅ Extract humidity
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}

class WeatherService {
  final http.Client client;
  final String apiKey;
  static const baseUrl = 'https://api.openweathermap.org/data/2.5';

  WeatherService({
    required this.client,
    required this.apiKey,
  });

  Future<WeatherData> getCurrentWeatherByCoordinates(
      double lat, double lon) async {
    try {
      log('Fetching weather data for coordinates: $lat, $lon');

      final url = Uri.parse(
          '$baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey');

      final response = await client.get(url);

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return WeatherData.fromJson(decodedData);
      } else {
        throw WeatherApiException(
            'Failed to fetch weather data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching weather data: $e');
      throw WeatherApiException('Failed to fetch weather data: $e');
    }
  }
}

//==========================================================================

// import 'dart:convert';
// import 'dart:developer';
// import 'package:http/http.dart' as http;

// class WeatherApiException implements Exception {
//   final String message;
//   WeatherApiException(this.message);
// }

// class WeatherData {
//   final double temperature;
//   final String condition;
//   final String iconCode;

//   WeatherData({
//     required this.temperature,
//     required this.condition,
//     required this.iconCode,
//   });

//   factory WeatherData.fromJson(Map<String, dynamic> json) {
//     return WeatherData(
//       temperature: json['main']['temp'].toDouble(),
//       condition: json['weather'][0]['main'],
//       iconCode: json['weather'][0]['icon'],
//     );
//   }
// }

// class WeatherService {
//   final http.Client client;
//   final String apiKey;
//   static const baseUrl = 'https://api.openweathermap.org/data/2.5';

//   WeatherService({
//     required this.client,
//     required this.apiKey,
//   });

//   Future<WeatherData> getCurrentWeatherByCoordinates(
//       double lat, double lon) async {
//     try {
//       log('Fetching weather data for coordinates: $lat, $lon');

//       final url = Uri.parse(
//           '$baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey');

//       final response = await client.get(url);

//       log('Response status: ${response.statusCode}');
//       log('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final decodedData = json.decode(response.body);
//         return WeatherData.fromJson(decodedData);
//       } else {
//         throw WeatherApiException(
//             'Failed to fetch weather data. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       log('Error fetching weather data: $e');
//       throw WeatherApiException('Failed to fetch weather data: $e');
//     }
//   }
// }

//==========================================================================
