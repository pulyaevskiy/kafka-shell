part of kafka_shell;

class PartitionsView {
  final TopicMetadata topicMetadata;

  PartitionsView(this.topicMetadata);

  String toString() {
    var table = new Table(5);
    table.columns.add('ID');
    table.columns.add('Error');
    table.columns.add('Leader');
    table.columns.add('Replicas');
    table.columns.add('ISR');
    var partitions = topicMetadata.partitionsMetadata;
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

    return table.toString();
  }
}
