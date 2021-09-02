import 'package:api_event/api_event.dart';
import 'package:api_event/utils/printer.dart';
import 'package:flutter/material.dart';

import 'ui/await.dart';
import 'ui/event.dart';

void main() {
  Provider.url = "https://jsonplaceholder.typicode.com/";
  Printer.mode = PRINTER_MODE.FULL;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(child: AwaitWidget()),
            Expanded(child: LocalWidget()),
          ],
        ),
      ),
    );
  }
}
