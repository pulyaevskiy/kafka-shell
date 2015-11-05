part of kafka_shell;

class BrokersCommand implements ShellCommand {
  final KafkaSession session;

  BrokersCommand(this.session);

  @override
  Future execute(List<String> args, Stdout output) async {
    var response = await session.getMetadata();
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
  Future<List<AutocompleteOption>> autocomplete(List<String> args) {
    var list = new List<AutocompleteOption>();
    if (args.length == 1 && 'brokers'.startsWith(args.first)) {
      list.add(new AutocompleteOption('brokers', 'brokers'));
    }
    return new Future.value(list);
  }
}
