import 'package:curved_progress_bar/curved_progress_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatefulWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  DemoAppState createState() => DemoAppState();
}

class DemoAppState extends State<DemoApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const [
          SizedBox(
            height: 200,
            width: 200,
            child: CurvedCircularProgressIndicator(),
          ),
          SizedBox(
            height: 200,
            width: 200,
            child: CurvedCircularProgressIndicator(
              value: 0.5,
              animationDuration: Duration(seconds: 3),
              backgroundColor: Colors.amber,
              color: Colors.red,
              strokeWidth: 9,
            ),
          ),
          SizedBox(
            height: 200,
            width: 200,
            child: CurvedLinearProgressIndicator(),
          ),
          SizedBox(
            height: 200,
            width: 200,
            child: CurvedLinearProgressIndicator(
              value: 0.5,
              strokeWidth: 8,
              backgroundColor: Colors.amber,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
