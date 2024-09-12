import 'dart:async';

import 'dart:convert';
import 'dart:typed_data';

import 'wtf8.dart';

// Protocol version
const protocol = 4;

enum PacketType { OPEN, CLOSE, PING, PONG, MESSAGE, UPGRADE, NOOP }

const List<String?> packetTypeList = <String?>[
  'open',
  'close',
  'ping',
  'pong',
  'message',
  'upgrade',
  'noop'
];

const Map<String, int> packetTypeMap = <String, int>{
  'open': 0,
  'close': 1,
  'ping': 2,
  'pong': 3,
  'message': 4,
  'upgrade': 5,
  'noop': 6
};

final SEPARATOR = String.fromCharCode(30);

class PacketParser {
  static const ERROR_PACKET = {'type': 'error', 'data': 'parser error'};

  static String? encodePacket(Map packet,
      {dynamic supportsBinary,
      utf8encode = false,
      required callback(_),
      bool fromClient = false}) {
    if (supportsBinary is Function) {
      callback = supportsBinary as dynamic Function(dynamic);
      supportsBinary = null;
    }

    if (utf8encode is Function) {
      callback = utf8encode as dynamic Function(dynamic);
      utf8encode = null;
    }

    if (packet['data'] != null) {
      if (packet['data'] is Uint8List) {
        return encodeBuffer(packet, supportsBinary, callback,
            fromClient: fromClient);
      } else if (packet['data'] is Map &&
          (packet['data']['buffer'] != null &&
              packet['data']['buffer'] is ByteBuffer)) {
        packet['data'] = (packet['data']['buffer'] as ByteBuffer).asUint8List();
        return encodeBuffer(packet, supportsBinary, callback,
            fromClient: fromClient);
      } else if (packet['data'] is ByteBuffer) {
        packet['data'] = (packet['data'] as ByteBuffer).asUint8List();
        return encodeBuffer(packet, supportsBinary, callback,
            fromClient: fromClient);
      }
    }

    // Sending data as a utf-8 string
    var encoded = '''${packetTypeMap[packet['type']]}''';

    // data fragment is optional
    if (packet['data'] != null) {
      encoded += utf8encode == true
          ? WTF8.encode('''${packet['data']}''')
          : '''${packet['data']}''';
    }

    return callback(encoded);
  }

  static encodeBuffer(packet, supportsBinary, callback,
      {fromClient = false /*use this to check whether is in client or not*/
      }) {
    if (!supportsBinary) {
      return encodeBase64Packet(packet, callback);
    }

    var data = packet['data'];
    // 'fromClient' is to check if the runtime is on server side or not,
    // because Dart server's websignaling cannot send data with byte buffer.
    if (fromClient) {
      return callback(data.buffer);
    } else {
      return callback(data);
    }
  }

  static encodeBase64Packet(packet, callback) {
    var message = 'b';
    message += base64.encode(packet.data.toString().codeUnits);
    return callback(message);
  }

  static dynamic mapBinary(dynamic data, String binaryType) {
    final isBuffer = data is ByteBuffer;
    if (binaryType == 'arraybuffer') {
      return isBuffer ? data.asUint8List() : data;
    }
    return data;
  }

  static decodePacket(dynamic encodedPacket, binaryType) {
    if (encodedPacket is! String) {
      return {'type': "message", 'data': mapBinary(encodedPacket, binaryType)};
    }
    var type = encodedPacket[0];

    if (type == 'b') {
      var buffer =
          base64.decode(utf8.decode(encodedPacket.substring(1).codeUnits));
      return {'type': "message", 'data': mapBinary(buffer, binaryType)};
    }

    var typeNumber = int.parse(type);
    var pt = packetTypeList[typeNumber];
    if (pt == null) {
      return ERROR_PACKET;
    }

    if (encodedPacket.length > 1) {
      return {'type': pt, 'data': encodedPacket.substring(1)};
    } else {
      return {'type': pt};
    }
  }

  static encodePayload(List packets, {required callback(_)}) {
    final length = packets.length;
    final encodedPackets = []..length = length;
    var count = 0;
    var i = 0;
    for (var packet in packets) {
      // force base64 encoding for binary packets
      encodePacket(packet, supportsBinary: false, callback: (encodedPacket) {
        encodedPackets[i++] = encodedPacket;
        if (++count == length) {
          callback(encodedPackets.join(SEPARATOR));
        }
      });
    }
  }

  static map(List ary, each(_, callback(msg)), done(results)) {
    var result = [];
    Future.wait(ary.map((e) {
      return Future.microtask(() => each(e, (msg) {
            result.add(msg);
          }));
    })).then((r) => done(result));
  }

  static decodePayload(encodedPayload, binaryType) {
    var encodedPackets = encodedPayload.split(SEPARATOR);
    var packets = [];
    for (var i = 0; i < encodedPackets.length; i++) {
      var decodedPacket = decodePacket(encodedPackets[i], binaryType);
      packets.add(decodedPacket);
      if (decodedPacket['type'] == "error") {
        break;
      }
    }
    return packets;
  }
}
