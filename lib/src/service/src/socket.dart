import 'dart:typed_data';

import 'package:logging/logging.dart';
import '../../common/src/util/event_emitter.dart';
import 'manager.dart';
import 'on.dart' as util;
import '../../common/src/parser/parser.dart';

const List events = [
  'connect',
  'connect_error',
  'connect_timeout',
  'connecting',
  'disconnect',
  'error',
  'reconnect',
  'reconnect_attempt',
  'reconnect_failed',
  'reconnect_error',
  'reconnecting',
  'ping',
  'pong'
];

final Logger _logger = Logger('socket_io_client:Socket');

class Signaling extends EventEmitter {
  String nsp;
  Map? opts;

  Manager io;
  late Signaling json;
  num ids = 0;
  Map acks = {};
  bool connected = false;
  bool disconnected = true;
  List sendBuffer = [];
  List receiveBuffer = [];
  String? query;
  dynamic auth;
  List? subs;
  Map flags = {};
  String? id;
  String? pid;
  String? lastOffset;

  Signaling(this.io, this.nsp, this.opts) {
    json = this; // compat
    if (opts != null) {
      query = opts!['query'];
      auth = opts!['auth'];
    }
    if (io.autoConnect) open();
  }

  void subEvents() {
    if (subs?.isNotEmpty == true) return;

    var io = this.io;
    subs = [
      util.on(io, 'open', onopen),
      util.on(io, 'packet', onpacket),
      util.on(io, 'error', onerror),
      util.on(io, 'close', onclose)
    ];
  }

  bool get active {
    return subs != null;
  }

  Signaling open() => connect();

  Signaling connect() {
    if (connected) return this;
    subEvents();
    if (!io.reconnecting) {
      io.open(); // ensure open
    }
    if ('open' == io.readyState) onopen();
    return this;
  }

  Signaling send(List args) {
    emit('message', args);
    return this;
  }

  @override
  void emit(String event, [data]) {
    emitWithAck(event, data);
  }

  void emitWithAck(String event, dynamic data,
      {Function? ack, bool binary = false}) {
    if (events.contains(event)) {
      super.emit(event, data);
    } else {
      var sendData = <dynamic>[event];
      if (data is ByteBuffer || data is List<int>) {
        sendData.add(data);
      } else if (data is Iterable) {
        sendData.addAll(data);
      } else if (data != null) {
        sendData.add(data);
      }

      var packet = {
        'type': EVENT,
        'data': sendData,
        'options': {'compress': flags.isNotEmpty == true && flags['compress']}
      };

      // event ack callback
      if (ack != null) {
        _logger.fine('emitting packet with ack id $ids');
        acks['$ids'] = ack;
        packet['id'] = '${ids++}';
      }
      final isTransportWritable = io.engine != null &&
          io.engine!.transport != null &&
          io.engine!.transport!.writable == true;

      final discardPacket =
          flags['volatile'] != null && (!isTransportWritable || !connected);
      if (discardPacket) {
        _logger
            .fine('discard packet as the transport is not currently writable');
      } else if (connected) {
        this.packet(packet);
      } else {
        sendBuffer.add(packet);
      }
      flags = {};
    }
  }

  void packet(Map packet) {
    packet['nsp'] = nsp;
    io.packet(packet);
  }

  void onopen([_]) {
    _logger.fine('transport is open - connecting');

    if (auth is Function) {
      auth((data) {
        sendConnectPacket(data);
      });
    } else {
      sendConnectPacket(auth);
    }
  }

  void sendConnectPacket(Map? data) {
    packet({
      'type': CONNECT,
      'data': pid != null
          ? {
              'pid': pid,
              'offset': lastOffset,
              ...(data ?? {}),
            }
          : data,
    });
  }

  void onerror(err) {
    if (!connected) {
      emit('connect_error', err);
    }
  }

  void onclose(reason) {
    _logger.fine('close ($reason)');
    emit('disconnecting', reason);
    connected = false;
    disconnected = true;
    id = null;
    emit('disconnect', reason);
  }

  void onpacket(packet) {
    if (packet['nsp'] != nsp) return;

    switch (packet['type']) {
      case CONNECT:
        if (packet['data'] != null && packet['data']['sid'] != null) {
          final id = packet['data']['sid'];
          final pid = packet['data']['pid'];
          onconnect(id, pid);
        } else {
          emit('connect_error',
              'It seems you are trying to reach a Socket.IO server in v2.x with a v3.x client, but they are not compatible (more information here: https://socket.io/docs/v3/migrating-from-2-x-to-3-0/)');
        }
        break;

      case EVENT:
        onevent(packet);
        break;

      case BINARY_EVENT:
        onevent(packet);
        break;

      case ACK:
        onack(packet);
        break;

      case BINARY_ACK:
        onack(packet);
        break;

      case DISCONNECT:
        ondisconnect();
        break;

      case CONNECT_ERROR:
        emit('error', packet['data']);
        break;
    }
  }

  void onevent(Map packet) {
    List args = packet['data'] ?? [];

    if (null != packet['id']) {
      args.add(ack(packet['id']));
    }

    if (connected == true) {
      if (args.length > 2) {
        Function.apply(super.emit, [args.first, args.sublist(1)]);
        if (pid != null && args[args.length - 1] is String) {
          lastOffset = args[args.length - 1];
        }
      } else {
        Function.apply(super.emit, args);
      }
    } else {
      receiveBuffer.add(args);
    }
  }

  Function ack(id) {
    var sent = false;
    return (dynamic data) {
      if (sent) return;
      sent = true;
      _logger.fine('sending ack $data');

      var sendData = <dynamic>[];
      if (data is ByteBuffer || data is List<int>) {
        sendData.add(data);
      } else if (data is Iterable) {
        sendData.addAll(data);
      } else if (data != null) {
        sendData.add(data);
      }

      packet({'type': ACK, 'id': id, 'data': sendData});
    };
  }

  void onack(Map packet) {
    var ack = acks.remove('${packet['id']}');
    if (ack is Function) {
      _logger.fine('''calling ack ${packet['id']} with ${packet['data']}''');

      var args = packet['data'] as List;
      if (args.length > 1) {
        Function.apply(ack, [args]);
      } else {
        Function.apply(ack, args);
      }
    } else {
      _logger.fine('''bad ack ${packet['id']}''');
    }
  }

  void onconnect(id, pid) {
    this.id = id;
    this.pid = pid; // defined only if connection state recovery is enabled
    connected = true;
    disconnected = false;
    emit('connect');
    emitBuffered();
  }

  void emitBuffered() {
    int i;
    for (i = 0; i < receiveBuffer.length; i++) {
      List args = receiveBuffer[i];
      if (args.length > 2) {
        Function.apply(super.emit, [args.first, args.sublist(1)]);
      } else {
        Function.apply(super.emit, args);
      }
    }
    receiveBuffer = [];

    for (i = 0; i < sendBuffer.length; i++) {
      packet(sendBuffer[i]);
    }
    sendBuffer = [];
  }

  void ondisconnect() {
    _logger.fine('server disconnect ($nsp)');
    destroy();
    onclose('io server disconnect');
  }

  void destroy() {
    final subs0 = subs;
    if (subs0 != null && subs0.isNotEmpty) {
      // clean subscriptions to avoid reconnections

      for (var i = 0; i < subs0.length; i++) {
        subs0[i].destroy();
      }
      subs = null;
    }

    io.destroy(this);
  }

  Signaling close() => disconnect();

  Signaling disconnect() {
    if (connected == true) {
      _logger.fine('performing disconnect ($nsp)');
      packet({'type': DISCONNECT});
    }

    destroy();

    if (connected == true) {
      onclose('io client disconnect');
    }
    return this;
  }

  void dispose() {
    disconnect();
    clearListeners();
  }

  Signaling compress(compress) {
    flags['compress'] = compress;
    return this;
  }
}
