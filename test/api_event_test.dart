import 'dart:io';

import 'package:api_event/api_event.dart';
import 'package:api_event/provider/provider.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import '../example/lib/models/todo.dart';

void main() {
  flutter_test.TestWidgetsFlutterBinding.ensureInitialized();

  // group('ApiEvent - ', () {
  //   test('Get list', () async {
  //     Provider provider = Provider();
  //     HttpClientMock clientMock = HttpClientMock();

  //     when(clientMock.get(Uri.parse('todos'), headers: {})).thenAnswer((_) async => Response('[{"title": "Test"}, {"title": "Test2"}]', 200));

  //     provider.client = ioClientMock;

  //     ApiEvent<List<Todo>> event = ApiEvent(service: "todos", httpMethod: HttpMethod.GET, parser: Todo.todosParser);

  //     await event.run();

  //     expect(event.value.data[0].title, "Test");
  //     expect(event.value.data.length, 2);
  //   });

  //   test('Get single object', () async {
  //     Provider provider = Provider();
  //     IOClientMock ioClientMock = IOClientMock();

  //     when(ioClientMock.get(Uri.parse('todo'), headers: {})).thenAnswer((_) async => Response('{"title": "Test"}', 200));

  //     provider.client = ioClientMock;

  //     ApiEvent<Todo> event = ApiEvent(service: "todo", httpMethod: HttpMethod.GET, parser: Todo.todoParser);

  //     await event.run();

  //     expect(event.value.data.title, "Test");
  //   });

  //   test('Bad response body', () async {
  //     Provider provider = Provider();
  //     IOClientMock ioClientMock = IOClientMock();

  //     when(ioClientMock.get(Uri.parse('todos'), headers: {})).thenAnswer((_) async => Response('fail', 200));

  //     provider.client = ioClientMock;

  //     ApiEvent<List<Todo>> event = ApiEvent(service: "todos", httpMethod: HttpMethod.GET, parser: Todo.todosParser);

  //     await event.run();

  //     expect(event.value.status, Status.ERROR);
  //   });

  //   test('Bad status code', () async {
  //     Provider provider = Provider();
  //     IOClientMock ioClientMock = IOClientMock();

  //     when(ioClientMock.get(Uri.parse('todos'), headers: {})).thenAnswer((_) async => Response('', 400));

  //     provider.client = ioClientMock;

  //     ApiEvent<List<Todo>> event = ApiEvent(service: "todos", httpMethod: HttpMethod.GET, parser: Todo.todosParser);

  //     await event.run();

  //     expect(event.value.status, Status.ERROR);
  //   });

  //   test('Empty body', () async {
  //     Provider provider = Provider();
  //     IOClientMock ioClientMock = IOClientMock();

  //     when(ioClientMock.get(Uri.parse('void'), headers: {})).thenAnswer((_) async => Response('', 200));

  //     provider.client = ioClientMock;

  //     ApiEvent<void> event = ApiEvent(service: "void", httpMethod: HttpMethod.GET, parser: (body) {});

  //     await event.run();

  //     expect(event.value.status, Status.COMPLETED);
  //   });

  //   test('POST params and body', () async {
  //     Provider provider = Provider();
  //     IOClientMock ioClientMock = IOClientMock();

  //     when(ioClientMock.post(Uri.parse('todos/param'), body: "body", headers: {})).thenAnswer((_) async => Response('[{"title": "Test"}]', 200));

  //     provider.client = ioClientMock;

  //     ApiEvent<List<Todo>> event = ApiEvent(service: "todos", httpMethod: HttpMethod.POST, parser: Todo.todosParser);

  //     var response = await event.run(params: "param", body: "body");

  //     expect(response.status, Status.COMPLETED);
  //     expect(event.value.status, Status.COMPLETED);
  //   });

  //   test('Empty parser', () async {
  //     Provider provider = Provider();
  //     IOClientMock ioClientMock = IOClientMock();

  //     when(ioClientMock.post(Uri.parse('todos/param'), body: "body", headers: {})).thenAnswer((_) async => Response('[{"title": "Test"}]', 200));

  //     provider.client = ioClientMock;

  //     ApiEvent event = ApiEvent(service: "todos", httpMethod: HttpMethod.POST);

  //     var response = await event.run(params: "param", body: "body");

  //     expect(response.status, Status.COMPLETED);
  //     expect(event.value.status, Status.COMPLETED);
  //     expect(event.value.data, '[{"title": "Test"}]');
  //   });

  //   test('Cookies parser', () async {
  //     String rawCookies =
  //         "CN-0294B41265CA11E9BCB44B8D11E954F3=aHR0cDovLzEwLjAuMi4yOjgwODAv; path=/,JSESSIONID=kWPLSDxXFgdsostQ7-WfxL0V.node1; path=/application,RK-8fa50b40-f818-11ea-a795-2f7c9603d152=NuXpOzBX3gzZHJHQYDgHHUPWbPCRmjmD1Qylf3Qrv5E=; path=/application";
  //     Provider provider = Provider();
  //     List<Cookie> cookies = provider.parseCookie(rawCookies);

  //     expect(cookies.length, 3);
  //     expect(cookies[1].value, "kWPLSDxXFgdsostQ7-WfxL0V.node1");
  //   });
  // });
}

class HttpClientMock extends Mock implements HttpClient {}
