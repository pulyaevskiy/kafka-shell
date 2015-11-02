part of kafka_shell;

class TopicsCommand implements ShellCommand {
  final KafkaClient client;

  TopicsCommand(this.client);

  @override
  Future execute(String input, Stdout output) async {
    var response = await client.getMetadata();
    var table = new Table(2);
    table.columns.add('Topic name');
    table.columns.add('Partitions No');
    response.topicMetadata.forEach((t) {
      table.data.addAll([t.topicName, t.partitionsMetadata.length]);
    });
    output.write(table);
  }

  @override
  String signature() {
    return 'topics - Lists all topics in the cluster';
  }

  @override
  void writeHelp(Stdout output) {
    output.writeln('Usage: topics');
    output.writeln('');
    output.writeln('Lists all topics in the cluster.');
  }

  @override
  Future<List<AutocompleteOption>> autocomplete(String input) {
    var list = new List<AutocompleteOption>();
    if ('topics'.startsWith(input)) {
      list.add(new AutocompleteOption('topics', 'topics'));
    }
    return new Future.value(list);
  }
}
