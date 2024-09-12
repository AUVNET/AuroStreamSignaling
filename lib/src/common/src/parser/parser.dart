import 'dart:convert';
import 'package:logging/logging.dart';
import '../../signaling_common.dart';
import '../../src/util/event_emitter.dart';

import 'is_binary.dart';

const int CONNECT = 0;
const int DISCONNECT = 1;
const int EVENT = 2;
const int ACK = 3;
const int CONNECT_ERROR = 4;
const int BINARY_EVENT = 5;
const int BINARY_ACK = 6;

List<String?> packetTypes = <String?>[
  'CONNECT',
  'DISCONNECT',
  'EVENT',
  'ACK',
  'CONNECT_ERROR',
  'BINARY_EVENT',
  'BINARY_ACK'
];

class Encoder {
  static final Logger _logger = Logger('signaling:parser.Encoder');

  encode(obj) {
    if (_logger.isLoggable(Level.FINE)) {
      _logger.fine('encoding packet $obj');
    }

    if (EVENT == obj['type'] || ACK == obj['type']) {
      if (hasBinary(obj)) {
        obj['type'] = obj['type'] == EVENT ? BINARY_EVENT : BINARY_ACK;
        return encodeAsBinary(obj);
      }
    }
    return [encodeAsString(obj)];
  }

  static String encodeAsString(obj) {
    // first is type
    var str = '${obj['type']}';

    // attachments if we have them
    if (BINARY_EVENT == obj['type'] || BINARY_ACK == obj['type']) {
      str += '${obj['attachments']}-';
    }

    // if we have a namespace other than `/`
    // we append it followed by a comma `,`
    if (obj['nsp'] != null && '/' != obj['nsp']) {
      str += obj['nsp'] + ',';
    }

    // immediately followed by the id
    if (null != obj['id']) {
      str += '${obj['id']}';
    }

    // json data
    if (null != obj['data']) {
      str += json.encode(obj['data']);
    }

    if (_logger.isLoggable(Level.FINE)) {
      _logger.fine('encoded $obj as $str');
    }
    return str;
  }

  static encodeAsBinary(obj) {
    final deconstruction = Binary.deconstructPacket(obj);
    final pack = encodeAsString(deconstruction['packet']);
    final buffers = deconstruction['buffers'];

    // add packet info to beginning of data list
    return <dynamic>[pack]..addAll(buffers); // write all the buffers
  }
}

class Decoder extends EventEmitter {
  dynamic reconstructor = null;

  add(obj) {
    var packet;
    if (obj is String) {
      packet = decodeString(obj);
      if (BINARY_EVENT == packet['type'] || BINARY_ACK == packet['type']) {
        // binary packet's json
        reconstructor = BinaryReconstructor(packet);

        // no attachments, labeled binary but no binary data to follow
        if (reconstructor.reconPack['attachments'] == 0) {
          emit('decoded', packet);
        }
      } else {
        // non-binary full packet
        emit('decoded', packet);
      }
    } else if (isBinary(obj) || obj is Map && obj['base64'] != null) {
      // raw binary data
      if (reconstructor == null) {
        throw UnsupportedError(
            'got binary data when not reconstructing a packet');
      } else {
        packet = reconstructor.takeBinaryData(obj);
        if (packet != null) {
          // received final buffer
          reconstructor = null;
          emit('decoded', packet);
        }
      }
    } else {
      throw UnsupportedError('Unknown type: ' + obj);
    }
  }

  static decodeString(String str) {
    var i = 0;
    var endLen = str.length - 1;
    // look up type
    var p = <String, dynamic>{'type': num.parse(str[0])};

    if (null == packetTypes[p['type']]) {
      throw UnsupportedError("unknown packet type " + p['type']);
    }

    // look up attachments if type binary
    if (BINARY_EVENT == p['type'] || BINARY_ACK == p['type']) {
      final start = i + 1;
      while (str[++i] != '-' && i != str.length) {}
      var buf = str.substring(start, i);
      if (buf != '${num.tryParse(buf) ?? -1}' || str[i] != '-') {
        throw ArgumentError('Illegal attachments');
      }
      p['attachments'] = num.parse(buf);
    }

    // look up namespace (if any)
    if (i < endLen - 1 && '/' == str[i + 1]) {
      var start = i + 1;
      while (++i > 0) {
        if (i == str.length) break;
        var c = str[i];
        if ("," == c) break;
      }
      p['nsp'] = str.substring(start, i);
    } else {
      p['nsp'] = '/';
    }

    // look up id
    var next = i < endLen - 1 ? str[i + 1] : null;
    if (next?.isNotEmpty == true && '${num.tryParse(next!)}' == next) {
      var start = i + 1;
      while (++i > 0) {
        var c = str.length > i ? str[i] : null;
        if ('${num.tryParse(c!)}' != c) {
          --i;
          break;
        }
        if (i == str.length) break;
      }
      p['id'] = int.tryParse(str.substring(start, i + 1));
    }

    // look up json data
    if (i < endLen - 1 && str[++i].isNotEmpty == true) {
      var payload = tryParse(str.substring(i));
      if (isPayloadValid(p['type'], payload)) {
        p['data'] = payload;
      } else {
        throw UnsupportedError("invalid payload");
      }
    }

//    debug('decoded %s as %j', str, p);
    return p;
  }

  static tryParse(str) {
    try {
      return json.decode(str);
    } catch (e) {
      return false;
    }
  }

  static isPayloadValid(type, payload) {
    switch (type) {
      case CONNECT:
        return payload == null || payload is Map || payload is List;
      case DISCONNECT:
        return payload == null;
      case CONNECT_ERROR:
        return payload is String ||
            payload == null ||
            payload is Map ||
            payload is List;
      case EVENT:
      case BINARY_EVENT:
        return payload is List && payload[0] is String;
      case ACK:
      case BINARY_ACK:
        return payload is List;
    }
  }

  destroy() {
    if (reconstructor != null) {
      reconstructor.finishedReconstruction();
    }
  }
}

class BinaryReconstructor {
  Map? reconPack;
  List buffers = [];

  BinaryReconstructor(packet) {
    reconPack = packet;
  }

  takeBinaryData(binData) {
    buffers.add(binData);
    if (buffers.length == reconPack!['attachments']) {
      // done with buffer list
      var packet = Binary.reconstructPacket(reconPack!, buffers);
      finishedReconstruction();
      return packet;
    }
    return null;
  }

  void finishedReconstruction() {
    reconPack = null;
    buffers = [];
  }
}
