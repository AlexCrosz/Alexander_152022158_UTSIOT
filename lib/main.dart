import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuaca App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF2F3F5),
      ),
      home: const CuacaScreen(),
    );
  }
}

class CuacaScreen extends StatefulWidget {
  const CuacaScreen({super.key});

  @override
  State<CuacaScreen> createState() => _CuacaScreenState();
}

class _CuacaScreenState extends State<CuacaScreen> {
  final TextEditingController _ipController = TextEditingController();
  double? suhuMax;
  double? suhuMin;
  double? suhuRata;
  double? humidMax;
  double? humidMin;
  double? humidRata;
  List<dynamic>? nilaiSuhuHumidMax;
  List<dynamic>? monthYearMax;
  bool isLoading = false;

  Future<void> fetchData(String ip) async {
    final url = 'http://$ip/pem_iot/cuaca.php';

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          suhuMax = data['suhumax']?.toDouble();
          suhuMin = data['suhumin']?.toDouble();
          suhuRata = data['suhurata']?.toDouble();
          humidMax = data['humidmax']?.toDouble();
          humidMin = data['humidmin']?.toDouble();
          humidRata = data['humidrata']?.toDouble();
          nilaiSuhuHumidMax = data['nilai_suhu_max_humid_max'];
          monthYearMax = data['month_year_max'];
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Widget _buildDataCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Field untuk IP
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Masukkan IP Server',
                hintText: 'Contoh: 192.168.195.227',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cloud),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 10),
            // Tombol Fetch Data
            ElevatedButton.icon(
              onPressed: () {
                if (_ipController.text.isNotEmpty) {
                  fetchData(_ipController.text);
                }
              },
              icon: const Icon(Icons.search),
              label: const Text('Fetch Data'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: suhuMax == null
                  ? const Center(
                child: Text(
                  'Masukkan IP dan tekan tombol Fetch Data',
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView(
                children: [
                  // Menampilkan Data dalam Card
                  _buildDataCard('Suhu Max', '${suhuMax ?? '-'} °C', Icons.thermostat, Colors.red),
                  _buildDataCard('Suhu Min', '${suhuMin ?? '-'} °C', Icons.ac_unit, Colors.blue),
                  _buildDataCard('Suhu Rata-rata', '${suhuRata?.toStringAsFixed(2) ?? '-'} °C',
                      Icons.thermostat_outlined, Colors.orange),
                  _buildDataCard('Humidity Max', '${humidMax ?? '-'} %', Icons.water, Colors.blueAccent),
                  _buildDataCard('Humidity Min', '${humidMin ?? '-'} %', Icons.grain, Colors.teal),
                  _buildDataCard('Humidity Rata-rata', '${humidRata?.toStringAsFixed(2) ?? '-'} %',
                      Icons.water_drop, Colors.indigo),

                  const SizedBox(height: 20),
                  const Text(
                    'Data Suhu dan Humid Max:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ...?nilaiSuhuHumidMax?.map((item) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        title: Text('Suhu: ${item['suhu']} °C, Humid: ${item['humid']} %'),
                        subtitle: Text(
                          'Kecerahan: ${item['kecerahan']}%, Waktu: ${item['timestamp']}',
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),
                  const Text(
                    'Month Year Max:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ...?monthYearMax?.map((item) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text('Bulan-Tahun: ${item['month_year']}'),
                        leading: const Icon(Icons.calendar_today),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
