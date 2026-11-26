import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/air_quality.dart';

class AqiService {
  static const _host = 'https://api.waqi.info';

  Future<Map<String, dynamic>> _getJson(String url) async {
    final res = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 10),
        );
    if (res.statusCode != 200) {
      throw Exception('Server bermasalah (kode ${res.statusCode})');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<AirQuality> fetchByCity(String city) async {
    final keyword = Uri.encodeComponent(city);
    final token = ApiConfig.waqiToken;

    try {
      // 1. Coba langsung berdasarkan nama kota
      final feed = await _getJson('$_host/feed/$keyword/?token=$token');
      if (feed['status'] == 'ok') {
        return AirQuality.fromJson(feed['data'] as Map<String, dynamic>);
      }

      final detail = feed['data'].toString();
      if (detail.contains('Invalid key')) {
        throw Exception('API key tidak valid, periksa api_config.dart');
      }
      if (detail.contains('Over quota')) {
        throw Exception('Kuota API habis, coba lagi nanti');
      }

      // 2. Cadangan: cari stasiun berdasarkan kata kunci
      final search = await _getJson('$_host/search/?token=$token&keyword=$keyword');
      final stations = search['status'] == 'ok' ? search['data'] as List : [];
      if (stations.isEmpty) {
        throw Exception('Kota "$city" tidak ditemukan');
      }

      final uid = stations.first['uid'];
      final byUid = await _getJson('$_host/feed/@$uid/?token=$token');
      if (byUid['status'] != 'ok') {
        throw Exception('Data stasiun untuk "$city" tidak tersedia');
      }
      return AirQuality.fromJson(byUid['data'] as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on http.ClientException {
      throw Exception('Gagal terhubung ke server');
    } on TimeoutException {
      throw Exception('Koneksi terlalu lama, coba lagi');
    } on FormatException {
      throw Exception('Format data dari server tidak sesuai');
    }
  }
}