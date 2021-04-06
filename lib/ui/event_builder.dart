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
/// [builder]
class EventBuilder<T> extends StatelessWidget {
  final Event event;
  final Widget Function(BuildContext, T) builder;
  final Widget initial;
  final Widget loading;
  final Widget Function(T data) completed;
  final Widget Function(String message) error;

  const EventBuilder(
      {Key key,
      @required this.event,
      this.builder,
      this.initial,
      this.loading,
      this.completed,
      this.error})
      : assert(event != null && (builder != null || completed != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: event.stream,
        builder: (context, snapshot) {
          if (builder != null) {
            return builder(context, snapshot.data);
          }

          Widget currentLoadingWidget = loading ?? loadingWidget();

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
                return error != null
                    ? error(response.message)
                    : errorWidget(response.message);
                break;
            }
          }

          return currentLoadingWidget;
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

  Widget errorWidget(String message) => Center(
        child: Text("Произошла ошибка: " + message),
      );
}
