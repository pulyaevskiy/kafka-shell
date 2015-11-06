part of kafka_shell;

class OffsetsCommand implements ShellCommand {
  final KafkaSession session;
  final SharedContext context;

  OffsetsCommand(this.session, this.context);

  @override
  Future execute(List<String> args, Stdout output) async {
    if (context.topic.isEmpty) {
      output.writeln('ERR: must select a topic with `use` command first.');
      return;
    }
    var topicsCommand = new TopicsCommand(session);
    await topicsCommand.execute(['topics', context.topic, 'offsets'], output);
  }

  void printUsage(Stdout output) {
    output.writeln('Usage: offsets');
  }

  @override
  String signature() {
    return 'offsets - Displays offset information for given topic.';
  }

  @override
  void writeHelp(Stdout output) {
    output.writeln('Usage: offsets');
    output.writeln('');
    output.writeln('Displays offset information for given topic.');
  }

  @override
  Future<List<AutocompleteOption>> autocomplete(List<String> args) async {
    var options = new List<AutocompleteOption>();
    if (args.length == 1 && 'offsets'.startsWith(args.first)) {
      options.add(new AutocompleteOption('offsets', 'offsets'));
    }

    return new Future.value(options);
  }
}
