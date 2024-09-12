@JS()
library js_map;

import 'package:js/js.dart';

@JS('Array')
class JsArray {
  external factory JsArray();
  external int push(element);
  external dynamic pop();
  external int get length;
}

@JS('self')
// ignore: always_declare_return_types
external get self;
