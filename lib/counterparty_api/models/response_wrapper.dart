class ResponseWrapper {
  final List<Object> result;
  final String jsonrpc;
  final String id;

  const ResponseWrapper({
    required this.result,
    required this.jsonrpc,
    required this.id,
  });

  factory ResponseWrapper.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'result': List<Object> result,
        'asset': String jsonrpc,
        'quanity': String id,
      } =>
        ResponseWrapper(
          result: result,
          jsonrpc: jsonrpc,
          id: id,
        ),
      _ => throw const FormatException('Failed to load ResponseWrapper object.'),
    };
  }
}
