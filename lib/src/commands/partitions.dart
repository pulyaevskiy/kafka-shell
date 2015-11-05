part of kafka_shell;

class PartitionsCommand implements ShellCommand {
  final KafkaSession session;
  final SharedContext context;

  PartitionsCommand(this.session, this.context);

  @override
  Future execute(List<String> args, Stdout output) async {
    if (context.topic.isEmpty) {
      writeError(output, 'ERR: Must `use` topic first.');
      return;
    }

    var topic = context.topic;
    var meta = await session.getMetadata();
    output.write(new PartitionsView(meta.getTopicMetadata(topic)));
  }

  @override
  void writeHelp(Stdout output) {
    output.writeln('Usage: partitions');
    output.writeln('');
    output.writeln('Shows information about partitions of current topic.');
  }

  @override
  String signature() {
    return 'partitions - Shows information about partitions of current topic';
  }

  @override
  Future<List<AutocompleteOption>> autocomplete(List<String> args) {
    var list = new List<AutocompleteOption>();
    if (args.length == 1 && 'partitions'.startsWith(args.first)) {
      list.add(new AutocompleteOption('partitions', 'partitions'));
    }
    return new Future.value(list);
  }
}
