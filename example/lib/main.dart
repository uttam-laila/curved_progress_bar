import 'package:curved_progress_bar/curved_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        children: [
          SizedBox(
            height: 200.sp,
            width: 200.sp,
            child: const CurvedCircularProgressIndicator(),
          ),
          SizedBox(
            height: 200.sp,
            width: 200.sp,
            child: CurvedCircularProgressIndicator(
              value: 0.5,
              animationDuration: const Duration(seconds: 3),
              backgroundColor: Colors.amber,
              color: Colors.red,
              strokeWidth: 9.sp,
            ),
          ),
          SizedBox(
            height: 200.sp,
            width: 200.sp,
            child:
                const CurvedLinearProgressIndicator(), //Has some error for now. TODO: fix this issue.
          ),
          SizedBox(
            height: 200.sp,
            width: 200.sp,
            child: const CurvedLinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.amber,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
