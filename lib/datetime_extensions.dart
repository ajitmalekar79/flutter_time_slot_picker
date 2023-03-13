extension Round on DateTime {
  DateTime roundUp({Duration delta = const Duration(minutes: 15)}) {
    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch +
        (delta.inMilliseconds - millisecondsSinceEpoch % delta.inMilliseconds));
  }

  DateTime roundDown({Duration delta = const Duration(minutes: 15)}) {
    return DateTime.fromMillisecondsSinceEpoch(
      millisecondsSinceEpoch - millisecondsSinceEpoch % delta.inMilliseconds,
    );
  }
}
