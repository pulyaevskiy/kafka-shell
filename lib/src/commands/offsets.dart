part of kafka_shell;

class OffsetsCommand implements ShellCommand {
  final KafkaClient client;
  final SharedContext context;

  OffsetsCommand(this.client, this.context);

  @override
  Future execute(String input, Stdout output) async {
    var args = _getArgs(input);
    if ([2, 3].contains(args.length) == false) {
      printUsage(output);
      return;
    }

    var topic = args[1];
    var partition;
    try {
      partition = (args.length == 3) ? int.parse(args[2]) : null;
    } on FormatException {
      output.writeln('ERR: Invalid partition ID.');
      return;
    }

    var metadata = await client.getMetadata();

    var topicMeta = metadata.topicMetadata
        .firstWhere((t) => t.topicName == topic, orElse: () => null);
    if (topicMeta == null) {
      output.writeln('ERR: No such topic.');
      return;
    }

    if (partition != null &&
        (partition < 0 || partition >= topicMeta.partitionsMetadata.length)) {
      output.writeln('ERR: No such partition.');
      return;
    }

    var highWatermarkOffsets =
        await _fetchOffsets(topicMeta, partition, metadata, -1);
    List<PartitionOffsetsInfo> earliestOffsets =
        await _fetchOffsets(topicMeta, partition, metadata, -2);

    var table = new Table(2);
    table.columns.add('ID');
    table.columns.add('Leader');
    table.columns.add('Earliest offset');
    table.columns.add('HighWatermark offset');

    var sortedPartitions = topicMeta.partitionsMetadata.toList();
    sortedPartitions.sort((a, b) => a.partitionId.compareTo(b.partitionId));
    for (var p in sortedPartitions) {
      if (partition != null && partition != p.partitionId) {
        continue;
      }

      var pid = p.partitionId.toString();
      if (p.partitionErrorCode != 0) {
        pid += ' [err: ${p.partitionErrorCode}]';
      }
      var ep =
          earliestOffsets.firstWhere((_) => _.partitionId == p.partitionId);
      var earliest = ep.offsets.first.toString();
      if (ep.errorCode != 0) {
        earliest += ' [err: ${ep.errorCode}]';
      }
      var hp = highWatermarkOffsets
          .firstWhere((_) => _.partitionId == p.partitionId);
      var highWatermark = hp.offsets.first.toString();
      if (hp.errorCode != 0) {
        highWatermark += ' [err: ${hp.errorCode}]';
      }
      var broker = metadata.getBroker(p.leader);
      var leader = '${broker.host}:${broker.port} (${p.leader})';
      table.data.addAll([pid, leader, earliest, highWatermark]);
    }

    output.write(table);
  }

  Future<List<PartitionOffsetsInfo>> _fetchOffsets(TopicMetadata topic,
      int partition, MetadataResponse metadata, int time) async {
    var requests = new Map<KafkaHost, OffsetRequest>();
    for (var p in topic.partitionsMetadata) {
      if (partition != null && partition != p.partitionId) {
        continue;
      }

      var broker = metadata.getBroker(p.leader);
      var host = new KafkaHost(broker.host, broker.port);
      if (requests.containsKey(host) == false) {
        requests[host] = new OffsetRequest(client, host, broker.nodeId);
      }
      requests[host].addTopicPartition(topic.topicName, p.partitionId, time, 1);
    }

    var futures = requests.values.map((r) => r.send());
    List<OffsetResponse> responses = await Future.wait(futures);
    var result = new List();
    for (var r in responses) {
      result.addAll(r.topics[topic.topicName]);
    }

    return result;
  }

  List<String> _getArgs(String input) {
    var list = input.trim().split(' ').toList();
    list.removeWhere((s) => s.isEmpty);
    return list;
  }

  void printUsage(Stdout output) {
    output.writeln('Usage: offsets <topic> [<partition>]');
  }

  @override
  String signature() {
    return 'offsets - Displays offset information for given topic.';
  }

  @override
  void writeHelp(Stdout output) {
    output.writeln('Usage: offsets <topic> [<partition>]');
    output.writeln('');
    output.writeln('Displays offset information for given topic.');
  }

  @override
  Future<List<AutocompleteOption>> autocomplete(String input) async {
    var options = new List<AutocompleteOption>();
    if ('offsets'.startsWith(input)) {
      options.add(new AutocompleteOption('offsets', 'offsets'));
    } else if (input.startsWith('offsets ')) {
      var list = _getArgs(input);
      if (list.length == 2) {
        var meta = await client.getMetadata();
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
