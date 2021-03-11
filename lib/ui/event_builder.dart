import 'package:api_event/models/api_response.dart';
import 'package:api_event/models/event.dart';
import 'package:flutter/material.dart';

/// EventBuilder
///
/// Если типом события [event] является [ApiResponse], то виджет принимает:
/// [initial]: виджет, в случае пустого [event]
/// [loading], [completed], [error]: виджеты в случае каждого [Status] этого [ApiResponse]
///
/// Если тип события локальный, то виджет принимает:
/// [child]
/// [onEvent]: callback от нового события
class EventBuilder<T> extends StatelessWidget {
  final Event event;
  final Widget child;
  final void Function(T) onEvent;
  final Widget initial;
  final Widget loading;
  final Widget Function(T data) completed;
  final Widget Function(String message) error;

  const EventBuilder(
      {Key key,
      @required this.event,
      this.child,
      this.onEvent,
      this.initial,
      this.loading,
      this.completed,
      this.error})
      : assert(event != null &&
            ((child != null && onEvent != null) || completed != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: event.stream,
        // ignore: missing_return
        builder: (context, snapshot) {
          if (child != null) {
            if (snapshot.hasData) onEvent(snapshot.data);
            return child;
          }

          Widget currentLoadingWidget = loading ?? loadingWidget;

          if (!snapshot.hasData) return initial ?? currentLoadingWidget;

          if (snapshot.data is ApiResponse) {
            ApiResponse response = snapshot.data as ApiResponse;
            switch (response.status) {
              case Status.LOADING:
                return currentLoadingWidget;
                break;
              case Status.COMPLETED:
                return completed(response.data);
                break;
              case Status.ERROR:
                return error(response.message) ?? errorWidget;
                break;
              default:
                return currentLoadingWidget;
            }
          }
        });
  }

  Widget loadingWidget() => Center(
        child: Container(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 1,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        ),
      );

  Widget errorWidget() => Center(
        child: Text("Произошла ошибка"),
      );
}
