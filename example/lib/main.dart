import 'package:example/ui/event.dart';
import 'package:flutter/material.dart';
import 'ui/todo_widget.dart';

import 'package:api_event/api_event.dart';

void main() {
  Provider provider = Provider();
  provider.url = "https://jsonplaceholder.typicode.com/";

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(child: TodoWidget()),
            Expanded(child: LocalWidget()),
          ],
        ),
      ),
    );
  }
}
