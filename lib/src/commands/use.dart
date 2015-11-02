part of kafka_shell;

class UseCommand implements ShellCommand {
  final KafkaClient client;
  final SharedContext context;
  final Shell shell;

  MetadataResponse _metadata;

  UseCommand(this.client, this.context, this.shell);

  @override
  Future execute(String input, Stdout output) async {
    var list = _getArgs(input);
    if ([2, 4].contains(list.length) == false) {
      printUsage(output);
      return;
    }
    var topic = list.elementAt(1);
    var response = await client.getMetadata();
    var meta = response.topicMetadata
        .firstWhere((t) => t.topicName == topic, orElse: () => null);
    if (meta == null) {
      writeError(output, 'ERR: No such topic.');
      return;
    }
    context.topic = topic;
    if (list.length == 4) {
      context.consumerGroup = list.last;
    }
  }

  List<String> _getArgs(String input) {
    var list = input.trim().split(' ').toList();
    list.removeWhere((s) => s.isEmpty);
    return list;
  }

  Future<MetadataResponse> _getMetadata() async {
    if (_metadata == null) {
      _metadata = await client.getMetadata();
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
  Future<List<AutocompleteOption>> autocomplete(String input) async {
    var options = new List<AutocompleteOption>();
    if ('use'.startsWith(input)) {
      options.add(new AutocompleteOption('use', 'use'));
    } else if (input.startsWith('use ')) {
      var list = _getArgs(input);
      if (list.length == 2) {
        var meta = await _getMetadata();
        for (var topic in meta.topicMetadata) {
          if (topic.topicName.startsWith(list.last) &&
              topic.topicName != list.last) {
            options.add(new AutocompleteOption(
                topic.topicName, 'use ${topic.topicName}'));
          }
        }
      } else if (list.length == 3) {
        if ('as'.startsWith(list.last)) {
          var valuelist = list.toList();
          valuelist[2] = 'as';
          var value = valuelist.join(' ');
          options.add(new AutocompleteOption('as', value));
        }
      }
    }
    return options;
  }
}
