import 'dart:async';

StreamController _streamController = StreamController.broadcast(sync: false);
void fire(event) {
  _streamController.add(event);
}

Stream<T> on<T>() {
  if (T == dynamic) {
    return _streamController.stream as Stream<T>;
  } else {
    return _streamController.stream.where((event) => event is T).cast<T>();
  }
}
