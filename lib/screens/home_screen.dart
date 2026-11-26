import 'package:flutter/material.dart';

import '../models/air_quality.dart';
import '../services/aqi_service.dart';
import '../services/storage_service.dart';

Color aqiColor(int aqi) {
  if (aqi <= 50) return Colors.green;
  if (aqi <= 100) return Colors.yellow.shade800;
  if (aqi <= 150) return Colors.orange;
  if (aqi <= 200) return Colors.red;
  if (aqi <= 300) return Colors.purple;
  return Colors.brown;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _api = AqiService();
  final _storage = StorageService();

  Future<AirQuality>? _future;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Dipanggil saat aplikasi dibuka: muat riwayat dan kota terakhir
  Future<void> _loadInitial() async {
    final history = await _storage.getHistory();
    final last = await _storage.getLastCity();
    if (!mounted) return;
    setState(() => _history = history);
    if (last != null) {
      _controller.text = last;
      _search(last);
    }
  }

  void _search(String city) {
    final query = city.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _future = _fetchAndSave(query);
    });
  }

  // Simpan hanya jika pengambilan data berhasil
  Future<AirQuality> _fetchAndSave(String city) async {
    final data = await _api.fetchByCity(city);
    await _storage.saveLastCity(city);
    await _storage.addToHistory(city);
    final history = await _storage.getHistory();
    if (mounted) setState(() => _history = history);
    return data;
  }

  Future<void> _clearHistory() async {
    await _storage.clearHistory();
    if (mounted) setState(() => _history = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cek Kualitas Udara')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Masukkan nama kota, mis. Jakarta',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _search(_controller.text),
                ),
              ),
            ),
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat pencarian',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: _clearHistory,
                    child: const Text('Hapus'),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  children: _history
                      .map(
                        (city) => ActionChip(
                          label: Text(city),
                          onPressed: () {
                            _controller.text = city;
                            _search(city);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(child: _buildResult()),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    // Belum ada pencarian
    if (_future == null) {
      return const Center(child: Text('Cari kota untuk melihat AQI'));
    }

    return FutureBuilder<AirQuality>(
      future: _future,
      builder: (context, snapshot) {
        // 1. LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. ERROR
        if (snapshot.hasError) {
          final message =
              snapshot.error.toString().replaceFirst('Exception: ', '');
          return _ErrorView(
            message: message,
            onRetry: () => _search(_controller.text),
          );
        }

        // 3. SUCCESS
        return _AqiCard(data: snapshot.data!);
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}

class _AqiCard extends StatelessWidget {
  final AirQuality data;

  const _AqiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = aqiColor(data.aqi);

    return Align(
      alignment: Alignment.topCenter,
      child: Card(
        color: color.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.city,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                '${data.aqi}',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                data.category,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const Divider(height: 32),
              Text('Polutan dominan: ${data.dominantPol}'),
              if (data.pm25 != null) Text('PM2.5: ${data.pm25}'),
              Text('Diperbarui: ${data.time}'),
            ],
          ),
        ),
      ),
    );
  }
}