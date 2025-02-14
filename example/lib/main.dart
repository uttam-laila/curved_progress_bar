import 'package:flutter/material.dart';

import 'package:curved_progress_bar/curved_progress_bar.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatefulWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  DemoAppState createState() => DemoAppState();
}

double _value = 0.4;

class DemoAppState extends State<DemoApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(
            height: 80,
          ),
          const Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: CurvedCircularProgressIndicator(
                strokeWidth: 12,
              ),
            ),
          ),
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: CurvedCircularProgressIndicator(
                value: _value,
                animationDuration: const Duration(seconds: 3),
                backgroundColor: Colors.amber,
                color: Colors.red,
                strokeWidth: 9,
              ),
            ),
          ),
          const SizedBox(
            height: 200,
            width: 200,
            child: Center(
                child: CurvedLinearProgressIndicator(
              strokeWidth: 12,
            )),
          ),
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: CurvedLinearProgressIndicator(
                value: _value,
                strokeWidth: 8,
                backgroundColor: Colors.amber,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: IconButton(
          onPressed: () {
            setState(() {
              if (_value >= 1.0) {
                _value = 0;
              } else {
                _value += 0.05;
              }
            });
          },
          icon: const Icon(Icons.refresh)),
    );
  }
}
