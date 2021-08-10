class ApiResponse<T> {
  Status status;
  T data;
  String message;
  String body;
  int statusCode;

  ApiResponse(ApiResponse other) {
    this.status = other.status;
    this.data = other.data;
    this.message = other.message;
    this.statusCode = other.statusCode;
  }

  ApiResponse.loading({this.message}) : status = Status.LOADING;
  ApiResponse.completed({this.data, this.statusCode})
      : status = Status.COMPLETED;
  ApiResponse.error({this.message, this.body, this.statusCode})
      : status = Status.ERROR;

  @override
  String toString() => "Status:$status\nMessage:$message\nData:$data";
}

enum Status { LOADING, COMPLETED, ERROR }
