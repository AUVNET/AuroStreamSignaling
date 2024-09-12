/// Copyright (C) 2017 Potix Corporation. All Rights Reserved
/// History: 2017-04-26 12:27
/// Author: jumperchen<jumperchen@potix.com>
import 'jsonp_transport.dart';
import 'transport.dart';
import 'websocket_transport.dart';
import 'xhr_transport.dart';

class Transports {
  static List<String> upgradesTo(String from) {
    if ('polling' == from) {
      return ['websocket'];
    }
    return [];
  }

  static Transport newInstance(String name, options) {
    if ('websocket' == name) {
      return WebSocketTransport(options);
    } else if ('polling' == name) {
      if (options['forceJSONP'] != true) {
        return XHRTransport(options);
      } else {
        if (options['jsonp'] != false) return JSONPTransport(options);
        throw StateError('JSONP disabled');
      }
    } else {
      throw UnsupportedError('Unknown transport $name');
    }
  }
}
