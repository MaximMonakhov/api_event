import 'package:flutter/material.dart';

class TodoWidget extends StatefulWidget {
  @override
  _TodoWidgetState createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  ApiEvent<List<Todo>> todos = ApiEvent(
    url: "todos",
    httpMethod: HttpMethod.GET,
    responseBodyParser: (map) {
      List<Todo> todos = [];
      todos.add(Todo("kek"));
      return todos;
    },
  );

  @override
  void initState() {
    todos.run();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EventBuilder(
        event: todos,
        loading: Center(
          child: Text("Loading"),
        ),
        completed: (data) {
          return Center(
            child: Text(data[0].title),
          );
        },
        error: (message) => Center(
          child: Text("Error"),
        ),
      ),
    );
  }
}
