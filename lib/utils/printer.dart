enum PRINTER_MODE { OFF, EXCEPTIONS, FULL }

class Printer {
  static final Printer _printer = Printer._internal();
  factory Printer() => _printer;
  Printer._internal();

  static PRINTER_MODE mode = PRINTER_MODE.EXCEPTIONS;

  void exception(String message) {
    if (_isPrintAllow(PRINTER_MODE.EXCEPTIONS)) _printException(message);
  }

  void info(String message) {
    if (_isPrintAllow(PRINTER_MODE.FULL)) print(message);
  }

  bool _isPrintAllow(PRINTER_MODE printerMode) =>
      PRINTER_MODE.values.indexOf(printerMode) <=
      PRINTER_MODE.values.indexOf(Printer.mode);

  void _printException(String text) {
    print('\x1B[31m$text\x1B[0m');
  }
}
