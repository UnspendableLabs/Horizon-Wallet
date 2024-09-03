String normalizeB64(String source) {
  var current = source;
  while (current.length % 4 != 0) {
    current += '=';
  }
  return current;
}
