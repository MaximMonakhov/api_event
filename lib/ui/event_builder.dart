import 'package:api_event/models/api_response.dart';
import 'package:api_event/models/event.dart';
import 'package:flutter/material.dart';

class EventBuilder<T> extends StatelessWidget {
  final Event event;
  final Widget Function(BuildContext, T) builder;
  final Widget initial;
  final Widget loading;
  final Color loadingColor;
  final Function refresh;
  final Widget Function(T data) completed;
  final Widget completedEmpty;
  final Widget Function(String message) error;

  const EventBuilder(
      {Key key,
      @required this.event,
      this.builder,
      this.initial,
      this.loading,
      this.loadingColor,
      this.refresh,
      this.completed,
      this.completedEmpty,
      this.error})
      : assert(event != null && (builder != null || completed != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: event.stream,
        builder: (context, snapshot) {
          if (builder != null) return builder(context, snapshot.data);

          Widget currentLoadingWidget = loading ?? loadingWidget();

          if (!snapshot.hasData) return initial ?? currentLoadingWidget;

          if (snapshot.data is ApiResponse) {
            ApiResponse response = snapshot.data as ApiResponse;

            switch (response.status) {
              case Status.LOADING:
                return currentLoadingWidget;
                break;
              case Status.COMPLETED:
                return completedEmpty != null && response.data.isEmpty
                    ? completedEmpty
                    : completed(response.data);
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
          width: 15.0,
          height: 15.0,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            backgroundColor: Colors.transparent,
            valueColor:
                AlwaysStoppedAnimation<Color>(loadingColor ?? Colors.black),
          ),
        ),
      );

  Widget errorWidget(String message) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 30.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            refresh != null
                ? TextButton(
                    child: Text(
                      "Повторить попытку",
                      style: TextStyle(color: Colors.blue[600], fontSize: 15.0),
                    ),
                    onPressed: refresh,
                  )
                : Container(),
          ],
        ),
      );
}
