class ApiResponse<T> {
  Status status;
  T data;
  String message;

  ApiResponse(ApiResponse other) {
    this.status = other.status;
    this.data = other.data;
    this.message = other.message;
  }

  ApiResponse.loading(this.message) : status = Status.LOADING;
  ApiResponse.completed(this.data) : status = Status.COMPLETED;
  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { LOADING, COMPLETED, ERROR }
