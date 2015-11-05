part of kafka_shell;

class TopicsView {
  final List<TopicMetadata> topics;

  TopicsView(this.topics);

  String toString() {
    var table = new Table(2);
    table.columns.add('Topic name');
    table.columns.add('Partitions No');
    topics.forEach((t) {
      table.data.addAll([t.topicName, t.partitionsMetadata.length]);
    });

    return table.toString();
  }
}
