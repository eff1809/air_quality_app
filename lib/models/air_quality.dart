class AirQuality {
  final int aqi;
  final String city;
  final String dominantPol;
  final double? pm25;
  final String time;

  AirQuality({
    required this.aqi,
    required this.city,
    required this.dominantPol,
    required this.pm25,
    required this.time,
  });

  factory AirQuality.fromJson(Map<String, dynamic> data) {
    final aqi = int.tryParse(data['aqi'].toString());
    if (aqi == null) {
      throw Exception('Data AQI belum tersedia untuk lokasi ini');
    }
    return AirQuality(
      aqi: aqi,
      city: data['city']?['name'] ?? '-',
      dominantPol: data['dominentpol'] ?? '-',
      pm25: (data['iaqi']?['pm25']?['v'] as num?)?.toDouble(),
      time: data['time']?['s'] ?? '-',
    );
  }

  String get category {
    if (aqi <= 50) return 'Baik';
    if (aqi <= 100) return 'Sedang';
    if (aqi <= 150) return 'Tidak sehat bagi kelompok sensitif';
    if (aqi <= 200) return 'Tidak sehat';
    if (aqi <= 300) return 'Sangat tidak sehat';
    return 'Berbahaya';
  }
}