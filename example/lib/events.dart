import 'package:api_event/api_event.dart';
import './models/todo.dart';

class TodoEvents {
  static final ApiEvent<List<Todo>> todos = ApiEvent(
      service: "todos", httpMethod: HTTP_METHOD.GET, parser: Todo.todosParser);
  static final ApiEvent<Todo> todo = ApiEvent(
      service: "todo", httpMethod: HTTP_METHOD.GET, parser: Todo.todoParser);
}
