// Web이 아닌 플랫폼에서 사용할 stub
// dart:js_interop과 dart:js_interop_unsafe이 없는 환경에서의 fallback

// 빈 타입 정의들 (컴파일 오류 방지용)
class JSObject {}
class JSBoolean {
  bool? get toDart => null;
}

// 빈 전역 객체
final JSObject globalContext = JSObject();

// String extension stub
extension JSString on String {
  JSObject get toJS => JSObject();
}

// JSObject extension stub (dart:js_interop_unsafe 기능)
extension JSObjectExt on JSObject {
  JSObject getProperty(JSObject property) => JSObject();
}