part of kafka_shell;

class OffsetsView {
  final TopicMetadata topic;
  final List<TopicOffset> earliest;
  final List<TopicOffset> latest;

  OffsetsView(this.topic, this.earliest, this.latest);

  String toString() {
    var table = new Table(3);
    table.columns.add('Partition ID');
    table.columns.add('Earliest offset');
    table.columns.add('Latest offset');

    var sortedPartitions = topic.partitionsMetadata.toList();
    sortedPartitions.sort((a, b) => a.partitionId.compareTo(b.partitionId));
    for (var p in sortedPartitions) {
      var pid = p.partitionId.toString();
      if (p.partitionErrorCode != 0) {
        pid += ' [err: ${p.partitionErrorCode}]';
      }
      var earlistOffset =
          earliest.firstWhere((_) => _.partitionId == p.partitionId);

      var latestOffset =
          latest.firstWhere((_) => _.partitionId == p.partitionId);
      table.data.addAll([pid, earlistOffset.offset, latestOffset.offset]);
    }

    return table.toString();
  }
}
