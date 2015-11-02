part of kafka_shell;

class BrokersCommand implements ShellCommand {
  final KafkaClient client;

  BrokersCommand(this.client);

  @override
  Future execute(String input, Stdout output) async {
    var response = await client.getMetadata();
    var table = new Table(3);
    table.columns.add('ID');
    table.columns.add('Host');
    table.columns.add('Port');
    response.brokers.forEach((b) {
      table.data.addAll([b.nodeId, b.host, b.port]);
    });
    output.write(table);
  }

  @override
  String signature() {
    return 'brokers - Lists all brokers in the cluster';
  }

  @override
  void writeHelp(Stdout output) {
    output.writeln('Usage: brokers');
    output.writeln('');
    output.writeln('Lists all brokers in the cluster.');
  }

  @override
  Future<List<AutocompleteOption>> autocomplete(String input) {
    var list = new List<AutocompleteOption>();
    if ('brokers'.startsWith(input)) {
      list.add(new AutocompleteOption('brokers', 'brokers'));
    }
    return new Future.value(list);
  }
}
