import 'package:flutter/material.dart';
import 'ui/todo_widget.dart';

void main() {
  Provider provider = Provider();
  provider.url = "https://jsonplaceholder.typicode.com/";

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoWidget(),
    );
  }
}
