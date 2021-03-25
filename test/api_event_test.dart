import 'package:api_event/api_event.dart';
import 'package:api_event/provider/provider.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import '../example/lib/models/todo.dart';

void main() {
  flutter_test.TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiEvent - ', () {
    test('Get list', () async {
      Provider provider = Provider();
      IOClientMock ioClientMock = IOClientMock();

      when(ioClientMock.get('todos', headers: {})).thenAnswer((_) async =>
          Response('[{"title": "Test"}, {"title": "Test2"}]', 200));

      provider.client = ioClientMock;

      ApiEvent<List<Todo>> event = ApiEvent(
          service: "todos",
          httpMethod: HttpMethod.GET,
          parser: Todo.todosParser);

      await event.run();

      expect(event.value.data[0].title, "Test");
      expect(event.value.data.length, 2);
    });

    test('Get single object', () async {
      Provider provider = Provider();
      IOClientMock ioClientMock = IOClientMock();

      when(ioClientMock.get('todo', headers: {}))
          .thenAnswer((_) async => Response('{"title": "Test"}', 200));

      provider.client = ioClientMock;

      ApiEvent<Todo> event = ApiEvent(
          service: "todo", httpMethod: HttpMethod.GET, parser: Todo.todoParser);

      await event.run();

      expect(event.value.data.title, "Test");
    });

    test('Bad response body', () async {
      Provider provider = Provider();
      IOClientMock ioClientMock = IOClientMock();

      when(ioClientMock.get('todos', headers: {}))
          .thenAnswer((_) async => Response('fail', 200));

      provider.client = ioClientMock;

      ApiEvent<List<Todo>> event = ApiEvent(
          service: "todos",
          httpMethod: HttpMethod.GET,
          parser: Todo.todosParser);

      await event.run();

      expect(event.value.status, Status.ERROR);
    });

    test('Bad status code', () async {
      Provider provider = Provider();
      IOClientMock ioClientMock = IOClientMock();

      when(ioClientMock.get('todos', headers: {}))
          .thenAnswer((_) async => Response('', 400));

      provider.client = ioClientMock;

      ApiEvent<List<Todo>> event = ApiEvent(
          service: "todos",
          httpMethod: HttpMethod.GET,
          parser: Todo.todosParser);

      await event.run();

      expect(event.value.status, Status.ERROR);
    });

    test('Empty body', () async {
      Provider provider = Provider();
      IOClientMock ioClientMock = IOClientMock();

      when(ioClientMock.get('void', headers: {}))
          .thenAnswer((_) async => Response('', 200));

      provider.client = ioClientMock;

      ApiEvent<void> event = ApiEvent(
          service: "void", httpMethod: HttpMethod.GET, parser: (body) {});

      await event.run();

      expect(event.value.status, Status.COMPLETED);
    });

    test('Saving auth token', () async {
      Provider provider = Provider();
      IOClientMock ioClientMock = IOClientMock();

      when(ioClientMock.get('todos', headers: {})).thenAnswer((_) async =>
          Response('[{"title": "Test"}]', 200, headers: {
            "set-cookie": "session_token=testtesttesttesttesttesttest;"
          }));

      provider.client = ioClientMock;

      ApiEvent<List<Todo>> event = ApiEvent(
          service: "todos",
          httpMethod: HttpMethod.GET,
          parser: Todo.todosParser,
          saveAuthToken: true);

      await event.run();

      expect(event.value.status, Status.COMPLETED);
      expect(provider.authToken, "testtesttesttesttesttesttest");
    });

    test('Using auth token', () async {
      Provider provider = Provider();
      IOClientMock ioClientMock = IOClientMock();

      provider.authToken = "test";

      when(ioClientMock.get('todos', headers: {"Authorization": "Bearer test"}))
          .thenAnswer((_) async => Response('[{"title": "Test"}]', 200));

      provider.client = ioClientMock;

      ApiEvent<List<Todo>> event = ApiEvent(
          service: "todos",
          httpMethod: HttpMethod.GET,
          parser: Todo.todosParser,
          auth: true);

      await event.run();

      expect(event.value.status, Status.COMPLETED);
    });

    test('POST params and body', () async {
      Provider provider = Provider();
      IOClientMock ioClientMock = IOClientMock();

      when(ioClientMock.post('todos?param=true', body: "body", headers: {}))
          .thenAnswer((_) async => Response('[{"title": "Test"}]', 200));

      provider.client = ioClientMock;

      ApiEvent<List<Todo>> event = ApiEvent(
          service: "todos",
          httpMethod: HttpMethod.POST,
          parser: Todo.todosParser);

      await event.run(params: "?param=true", body: "body");

      expect(event.value.status, Status.COMPLETED);
    });
  });
}

class IOClientMock extends Mock implements IOClient {}
