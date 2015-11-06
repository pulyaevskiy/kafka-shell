part of kafka_shell;

class TopicsCommand implements ShellCommand {
  final KafkaSession session;

  TopicsCommand(this.session);

  @override
  Future execute(List<String> args, Stdout output) async {
    if (args.length == 1) {
      var response = await session.getMetadata();
      output.write(new TopicsView(response.topicMetadata));
      return;
    }

    if (args.length == 2) {
      output.writeln('Usage: topics [<topic> offsets|partitions]');
      return;
    }

    if (args.length == 3 && ['offsets', 'partitions'].contains(args.last)) {
      var meta = await session.getMetadata();
      var topic = meta.topicMetadata
          .firstWhere((t) => t.topicName == args[1], orElse: () => null);
      if (topic == null) {
        output.writeln('ERR: No such topic.');
      }
      if (args.last == 'partitions') {
        output.write(new PartitionsView(topic));
      } else {
        // offsets
        var topicPartitions = new Map();
        topicPartitions[topic.topicName] =
            new List.generate(topic.partitionsMetadata.length, (i) => i);
        var master = new OffsetMaster(session);
        var earliestOffsets = await master.fetchEarliest(topicPartitions);
        var latestOffsets = await master.fetchLatest(topicPartitions);

        output.write(new OffsetsView(topic, earliestOffsets, latestOffsets));
      }
    } else {
      output.writeln('Usage: topics [<topic> offsets|partitions]');
      return;
    }
  }

  @override
  String signature() {
    return 'topics - Lists all topics in the cluster';
  }

  @override
  void writeHelp(Stdout output) {
    output.writeln('Usage: topics [<topic> offsets|partitions]');
    output.writeln('');
    output.writeln('Lists all topics in the cluster.');
  }

  @override
  Future<List<AutocompleteOption>> autocomplete(List<String> args) async {
    var options = new List<AutocompleteOption>();
    if (args.length == 1 && 'topics'.startsWith(args.first)) {
      options.add(new AutocompleteOption('topics', 'topics'));
    } else if (args.length == 2 && args.first == 'topics') {
      var meta = await session.getMetadata();
      var topics = meta.topicMetadata.map((t) => t.topicName);
      for (String topic in topics) {
        if (topic.startsWith(args.last)) {
          var value = args.toList();
          value[1] = topic;
          options.add(new AutocompleteOption(topic, value.join(' ')));
        }
      }
    } else if (args.length == 3 && args.first == 'topics') {
      for (var command in ['offsets', 'partitions']) {
        if (command.startsWith(args.last)) {
          var value = args.toList();
          value[2] = command;
          options.add(new AutocompleteOption(command, value.join(' ')));
        }
      }
    }

    return new Future.value(options);
  }
}
