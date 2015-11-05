part of kafka_shell;

class FetchCommand implements ShellCommand {
  final KafkaSession session;
  final SharedContext context;

  FetchCommand(this.session, this.context);

  @override
  Future execute(List<String> args, Stdout output) async {
    // output.write(table);
  }

  void printUsage(Stdout output) {
    output.writeln('Usage: fetch <topic> [<partition>]');
  }

  @override
  String signature() {
    return 'fetch - Fetch messages from Kafka topic.';
  }

  @override
  void writeHelp(Stdout output) {
    output.writeln('Usage: fetch <topic> [<partition>]');
    output.writeln('');
    output.writeln('Fetch messages from Kafka topic.');
  }

  @override
  Future<List<AutocompleteOption>> autocomplete(List<String> args) async {
    var options = new List<AutocompleteOption>();
    if ('fetch'.startsWith(input)) {
      options.add(new AutocompleteOption('offsets', 'offsets'));
    } else if (input.startsWith('offsets ')) {
      var list = _getArgs(input);
      if (list.length == 2) {
        var meta = await session.getMetadata();
        for (var topic in meta.topicMetadata) {
          if (topic.topicName.toLowerCase().startsWith(list.last) &&
              topic.topicName != list.last) {
            options.add(new AutocompleteOption(
                topic.topicName, 'offsets ${topic.topicName}'));
          }
        }
      }
    }
    return new Future.value(options);
  }
}
