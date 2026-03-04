import 'package:flutter/material.dart';
import 'package:quiz_ui_core/src/core_presentation/design_system.dart';

class CompromisedDeviceApp extends StatelessWidget {
  const CompromisedDeviceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.security_rounded,
                  color: Colors.redAccent,
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Access Denied',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This device does not meet our minimum security requirements. Access from modified or compromised devices is not permitted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () {
                    // In a real app, this might open a support URL
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  child: const Text('Contact Support'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
