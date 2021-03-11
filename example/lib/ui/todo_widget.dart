import 'package:example/models/todo.dart';
import 'package:flutter/material.dart';
import 'package:api_event/api_event.dart';

class TodoWidget extends StatefulWidget {
  @override
  _TodoWidgetState createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  ApiEvent<List<Todo>> todos =
      ApiEvent(url: "todos", httpMethod: HttpMethod.GET, parser: Todo.parser);

  @override
  void initState() {
    todos.run();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(50),
      child: EventBuilder(
        event: todos,
        completed: (data) => Center(
            child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: data.length,
                itemBuilder: (context, index) => Text(data[index].title))),
      ),
    );
  }
}
