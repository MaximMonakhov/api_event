import 'package:api_event/api_event.dart';
import './models/todo.dart';

class TodoEvents {
  static final ApiEvent<List<Todo>> todos = ApiEvent(
      service: "todos", httpMethod: HttpMethod.GET, parser: Todo.getParser);
  static final ApiEvent<bool> addTodo = ApiEvent(
      service: "add", httpMethod: HttpMethod.POST, parser: Todo.addParser);
}
