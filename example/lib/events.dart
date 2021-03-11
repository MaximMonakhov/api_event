import 'package:api_event/api_event.dart';
import 'package:example/models/todo.dart';

class TodoEvents {
  static final ApiEvent<List<Todo>> todos = ApiEvent(
      url: "todos", httpMethod: HttpMethod.GET, parser: Todo.getParser);
  static final ApiEvent<bool> addTodo =
      ApiEvent(url: "add", httpMethod: HttpMethod.POST, parser: Todo.addParser);
}
