import 'package:flutter/material.dart';
import 'dart:async';
import 'package:infrared_plugin/infrared_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Instance of the plugin.
  final _infrared = InfraredPlugin();

  // State variables to hold device information.
  String _statusMessage = 'Checking for IR Emitter...';
  bool _hasIrEmitter = false;
  List<List<int>> _frequencies = [];

  // Example Pronto HEX code for TV Power.
  static const String tvPowerHex =
      '0000 006C 0022 0002 015B 00AD 0016 0016 0016 0016 0016 0041 0016 0016 0016 0016 0016 0016 0016 0016 0016 0016 0016 0041 0016 0041 0016 0016 0016 0041 0016 0041 0016 0041 0016 0041 0016 0041 0016 0016 0016 0016 0016 0016 0016 0041 0016 0016 0016 0016 0016 0016 0016 0016 0016 0041 0016 0041 0016 0041 0016 0016 0016 0041 0016 0041 0016 0041 0016 0041 0016 05F7 015B 0057 0016 0E6C';

  // Example integer array pattern for a Samsung TV Power toggle.
  static const List<int> samsungPowerPattern = [
    4545,
    4545,
    568,
    1705,
    568,
    1705,
    568,
    1705,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    1705,
    568,
    1705,
    568,
    1705,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    1705,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    1705,
    568,
    1705,
    568,
    1705,
    568,
    568,
    568,
    568,
    568,
    568,
    568,
    42000,
  ];

  // A common frequency for remote controls.
  static const int defaultFrequency = 38028;

  @override
  void initState() {
    super.initState();
    _initInfrared();
  }

  // Initialize plugin and check for IR emitter.
  Future<void> _initInfrared() async {
    bool hasEmitter;
    try {
      hasEmitter = await _infrared.hasIrEmitter();
    } catch (e) {
      hasEmitter = false;
      debugPrint('Error checking for IR emitter: $e');
    }

    if (!mounted) return;

    setState(() {
      _hasIrEmitter = hasEmitter;
      _statusMessage = hasEmitter
          ? 'IR Emitter Found.'
          : 'No IR Emitter found on this device.';
    });

    if (hasEmitter) {
      _loadFrequencies();
    }
  }

  // Load the supported carrier frequencies.
  Future<void> _loadFrequencies() async {
    List<List<int>> freqs;
    try {
      freqs = await _infrared.getCarrierFrequencies();
    } catch (e) {
      freqs = [];
      debugPrint('Error loading frequencies: $e');
    }

    if (!mounted) return;

    setState(() {
      _frequencies = freqs;
    });
  }

  // Transmit a signal using the HEX pattern.
  Future<void> _transmitHex() async {
    setState(() {
      _statusMessage = 'Transmitting HEX code...';
    });

    try {
      await _infrared.transmitHex(
        frequency: defaultFrequency,
        hexPattern: tvPowerHex,
      );
      setState(() {
        _statusMessage = 'HEX code transmitted successfully.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error transmitting HEX code.';
      });
      debugPrint('Error transmitting HEX: $e');
    }
  }

  // Transmit a signal using the integer array pattern.
  Future<void> _transmitInts() async {
    setState(() {
      _statusMessage = 'Transmitting INT code...';
    });

    try {
      await _infrared.transmitInts(
        frequency: defaultFrequency,
        pattern: samsungPowerPattern,
      );
      setState(() {
        _statusMessage = 'INT code transmitted successfully.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error transmitting INT code.';
      });
      debugPrint('Error transmitting INTs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Infrared Plugin Example')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_hasIrEmitter && _frequencies.isNotEmpty)
                          Text(
                            'Supported Frequencies (Hz):\n${_frequencies.map((e) => '[${e[0]}-${e[1]}]').join(', ')}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('Transmit HEX Code (TV Power)'),
                  onPressed: _hasIrEmitter ? _transmitHex : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.tv),
                  label: const Text('Transmit INT Code (Samsung)'),
                  onPressed: _hasIrEmitter ? _transmitInts : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
