import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/air_quality.dart';

class AqiService {
  static const _baseUrl = 'https://api.waqi.info/feed';

  Future<AirQuality> fetchByCity(String city) async {
    final uri = Uri.parse(
      '$_baseUrl/${Uri.encodeComponent(city)}/?token=${ApiConfig.waqiToken}',
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception('Server bermasalah (kode ${res.statusCode})');
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (body['status'] != 'ok') {
        final detail = body['data'].toString();
        if (detail.contains('Invalid key')) {
          throw Exception('API key tidak valid, periksa api_config.dart');
        }
        throw Exception('Kota "$city" tidak ditemukan');
      }

      return AirQuality.fromJson(body['data'] as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on TimeoutException {
      throw Exception('Koneksi terlalu lama, coba lagi');
    } on FormatException {
      throw Exception('Format data dari server tidak sesuai');
    }
  }
}