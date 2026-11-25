
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

void main() {
  runApp(const CyberWifiApp());
}

const neon = Color(0xFF39FF14);
const dark = Color(0xFF080D0A);
const panel = Color(0xFF111B14);

class CyberWifiApp extends StatelessWidget {
  const CyberWifiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CYBER WIFI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: dark,
        colorScheme: const ColorScheme.dark(
          primary: neon,
          surface: panel,
        ),
      ),
      home: const ScannerPage(),
    );
  }
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  List<WiFiAccessPoint> networks = [];
  bool scanning = false;
  String status = 'SYSTEM READY';

  Future<void> scanWifi() async {
    if (scanning) return;

    setState(() {
      scanning = true;
      status = 'SCANNING NETWORKS...';
    });

    try {
      final can = await WiFiScan.instance.canStartScan(
        askPermissions: true,
      );

      if (can != CanStartScan.yes) {
        setState(() {
          status = 'CHECK WIFI / LOCATION PERMISSIONS';
        });
        return;
      }

      await WiFiScan.instance.startScan();
      await Future.delayed(const Duration(seconds: 3));

      final result =
          await WiFiScan.instance.getScannedResults();

      result.sort((a, b) => b.level.compareTo(a.level));

      if (!mounted) return;

      setState(() {
        networks = result;
        status = 'SCAN COMPLETED';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        status = 'SCAN ERROR';
      });
    } finally {
      if (mounted) {
        setState(() => scanning = false);
      }
    }
  }

  int signalPercent(int dbm) {
    return (((dbm + 100) / 50) * 100)
        .round()
        .clamp(0, 100);
  }

  Color signalColor(int dbm) {
    if (dbm >= -60) return neon;
    if (dbm >= -75) return Colors.orange;
    return Colors.redAccent;
  }

  Widget infoBox(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: neon.withOpacity(0.25),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: neon, size: 25),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: neon,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget networkCard(WiFiAccessPoint wifi) {
    final percent = signalPercent(wifi.level);
    final color = signalColor(wifi.level);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: neon.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.wifi, color: neon, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wifi.ssid.isEmpty
                          ? 'Hidden Network'
                          : wifi.ssid,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      wifi.bssid,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${wifi.level} dBm',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 7,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percent% SIGNAL',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                ),
              ),
              Text(
                '${wifi.frequency} MHz',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
              Text(
                wifi.capabilities.contains('WPA') ||
                        wifi.capabilities.contains('WEP')
                    ? 'SECURED'
                    : 'OPEN / UNKNOWN',
                style: const TextStyle(
                  color: neon,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.radar,
                    color: neon,
                    size: 38,
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CYBER WIFI',
                        style: TextStyle(
                          color: neon,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'NETWORK ANALYZER',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.security,
                    color: neon,
                    size: 27,
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: neon.withOpacity(0.4),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.wifi_tethering,
                    color: neon,
                    size: 65,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'WIRELESS SCANNER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: neon,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: scanning ? null : scanWifi,
                      icon: Icon(
                        scanning
                            ? Icons.hourglass_top
                            : Icons.radar,
                      ),
                      label: Text(
                        scanning
                            ? 'SCANNING...'
                            : 'START SCAN',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neon,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                            Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  infoBox(
                    'NETWORKS',
                    '${networks.length}',
                    Icons.router,
                  ),
                  const SizedBox(width: 10),
                  infoBox(
                    'STATUS',
                    scanning ? 'SCAN' : 'READY',
                    Icons.shield,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  const Text(
                    'DETECTED NETWORKS',
                    style: TextStyle(
                      color: neon,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${networks.length} FOUND',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: networks.isEmpty
                  ? const Center(
                      child: Text(
                        'NO NETWORKS FOUND\nPRESS START SCAN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white38,
                          height: 2,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      itemCount: networks.length,
                      itemBuilder: (context, index) =>
                          networkCard(networks[index]),
                    ),
            ),

            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'CYBER WIFI  •  ANDROID SECURITY TOOL',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
