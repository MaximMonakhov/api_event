import 'dart:convert' as convert;

class Todo {
  String title;

  Todo(this.title);

  Todo.fromJson(Map<String, dynamic> json) {
    title = json["title"];
  }

  static List<Todo> getParser(String body) {
    List json = convert.json.decode(body);
    List<Todo> todos = [];

    for (Map object in json) todos.add(Todo.fromJson(object));

    return todos;
  }

  static bool addParser(String body) {
    return body.toLowerCase() == "true";
  }
}
