class CounterpartyResponseWrapper {
  final dynamic result;
  final String jsonrpc;
  final String id;

  const CounterpartyResponseWrapper({
    required this.result,
    required this.jsonrpc,
    required this.id,
  });
  factory CounterpartyResponseWrapper.fromJson(Map<String, dynamic> data) {
    final result = data['result'] as List<dynamic>;
    final jsonrpc = data['jsonrpc'] as String;
    final id = data['id'] as String;
    return CounterpartyResponseWrapper(result: result, jsonrpc: jsonrpc, id: id);
  }
}
