part of kafka_shell;

class UseCommand implements ShellCommand {
  final KafkaSession session;
  final SharedContext context;

  MetadataResponse _metadata;

  UseCommand(this.session, this.context);

  @override
  Future execute(List<String> args, Stdout output) async {
    if ([2, 4].contains(args.length) == false) {
      printUsage(output);
      return;
    }
    var topic = args.elementAt(1);
    var response = await session.getMetadata();
    var meta = response.topicMetadata
        .firstWhere((t) => t.topicName == topic, orElse: () => null);
    if (meta == null) {
      writeError(output, 'ERR: No such topic.');
      return;
    }
    context.topic = topic;
    if (args.length == 4) {
      context.consumerGroup = args.last;
    }
  }

  Future<MetadataResponse> _getMetadata() async {
    if (_metadata == null) {
      _metadata = await session.getMetadata();
    }
    return _metadata;
  }

  void printUsage(Stdout output) {
    output.writeln('Usage: use <topic> [as <consumerGroup>]');
  }

  @override
  String signature() {
    return 'use - Switches context to particular topic for consecutive commands';
  }

  @override
  void writeHelp(Stdout output) {
    output.writeln('Usage: use <topic> [as <consumerGroup>]');
    output.writeln('');
    output.writeln('Switches context to particular topic which enables');
    output.writeln('some shortcut operations.');
  }

  @override
  Future<List<AutocompleteOption>> autocomplete(List<String> args) async {
    var options = new List<AutocompleteOption>();
    if (args.length == 1 && 'use'.startsWith(args.first)) {
      options.add(new AutocompleteOption('use', 'use'));
    } else if (args.length > 1 && args.first == 'use') {
      if (args.length == 2) {
        var meta = await _getMetadata();
        for (var topic in meta.topicMetadata) {
          if (topic.topicName.startsWith(args.last) &&
              topic.topicName != args.last) {
            options.add(new AutocompleteOption(
                topic.topicName, 'use ${topic.topicName}'));
          }
        }
      } else if (args.length == 3) {
        if ('as'.startsWith(args.last)) {
          var valuelist = args.toList();
          valuelist[2] = 'as';
          var value = valuelist.join(' ');
          options.add(new AutocompleteOption('as', value));
        }
      }
    }
    return options;
  }
}
