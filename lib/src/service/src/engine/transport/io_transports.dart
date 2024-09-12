import 'io_websocket_transport.dart';
import 'transport.dart';

class Transports {
  static List<String> upgradesTo(String from) {
    if ('polling' == from) {
      return ['websocket'];
    }
    return [];
  }

  static Transport newInstance(String name, options) {
    // only support websocket here.
    return IOWebSocketTransport(options);
  }
}
