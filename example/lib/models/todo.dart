class Todo {
  String title;

  Todo(this.title);

  Todo.fromJson(Map<String, dynamic> json) {
    title = json["title"];
  }

  static List<Todo> getParser(map) {
    List<Todo> todos = [];
    for (Map object in map) todos.add(Todo.fromJson(object));
    return todos;
  }

  static bool addParser(map) {
    return map;
  }
}
