import 'package:logging/logging.dart';
import 'src/socket.dart';
import '../common/src/engine/parser/parser.dart' as parser;
import 'src/engine/parseqs.dart';
import 'src/manager.dart';

export 'src/socket.dart';
export 'src/darty.dart';

// Protocol version
const protocol = parser.protocol;

final Map<String, dynamic> cache = {};

final Logger _logger = Logger('socket_io_client');

Signaling io(uri, [opts]) => _lookup(uri, opts);

Signaling _lookup(uri, opts) {
  opts = opts ?? <dynamic, dynamic>{};

  var parsed = Uri.parse(uri);
  var id = '${parsed.scheme}://${parsed.host}:${parsed.port}';
  var path = parsed.path;
  var sameNamespace = cache.containsKey(id) && cache[id].nsps.containsKey(path);
  var newConnection = opts['forceNew'] == true ||
      opts['force new connection'] == true ||
      false == opts['multiplex'] ||
      sameNamespace;

  late Manager io;

  if (newConnection) {
    _logger.fine('ignoring socket cache for $uri');
    io = Manager(uri: uri, options: opts);
  } else {
    io = cache[id] ??= Manager(uri: uri, options: opts);
  }
  if (parsed.query.isNotEmpty && opts['query'] == null) {
    opts['query'] = parsed.query;
  } else if (opts != null && opts['query'] is Map) {
    opts['query'] = encode(opts['query']);
  }
  return io.socket(parsed.path.isEmpty ? '/' : parsed.path, opts);
}
