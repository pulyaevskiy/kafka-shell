part of kafka_shell;

class PartitionsCommand implements ShellCommand {
  final KafkaClient client;
  final SharedContext context;

  PartitionsCommand(this.client, this.context);

  @override
  Future execute(String input, Stdout output) async {
    if (context.topic.isEmpty) {
      writeError(output, 'ERR: Must specify or `use` topic.');
      return;
    }

    var topic = context.topic;
    var meta = await client.getMetadata();
    var table = new Table(5);
    table.columns.add('ID');
    table.columns.add('Error');
    table.columns.add('Leader');
    table.columns.add('Replicas');
    table.columns.add('ISR');
    var partitions = meta.getTopicMetadata(topic).partitionsMetadata;
    partitions.sort((a, b) => a.partitionId.compareTo(b.partitionId));
    partitions.forEach((p) {
      table.data.addAll([
        p.partitionId,
        p.partitionErrorCode,
        p.leader,
        p.replicas,
        p.inSyncReplicas
      ]);
    });
    output.write(table);
  }

  @override
  void writeHelp(Stdout output) {
    output.writeln('Usage: partitions [<topic>] [<partition>]');
    output.writeln('');
    output.writeln('Shows information about partitions of particular topic.');
    output.writeln('If you `use`d one of the topics you can omit topic name');
    output.writeln('in this command, the `use`d one will be the default.');
  }

  @override
  String signature() {
    return 'partitions - Shows information about available commands';
  }

  @override
  Future<List<AutocompleteOption>> autocomplete(String input) {
    var list = new List<AutocompleteOption>();
    if ('partitions'.startsWith(input)) {
      list.add(new AutocompleteOption('partitions', 'partitions'));
    }
    return new Future.value(list);
  }
}
