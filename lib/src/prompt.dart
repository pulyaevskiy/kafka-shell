part of kafka_shell;

class KafkaPrompt implements ShellPrompt {
  final SharedContext context;

  KafkaPrompt(this.context);

  @override
  void write(Stdout output) {
    var text = '';
    if (context.topic.isNotEmpty) {
      text = _blue('(') + _red('${context.topic}') + _blue(')');
    }

    if (context.consumerGroup.isNotEmpty) {
      text = _blue('${context.consumerGroup}:') + text;
    }
    text += text.isEmpty ? _yellow('kafka> ') : _yellow(' # ');
    output.write(text);
  }

  String _red(String text) {
    var c = new Colorize(text);
    c.red();
    c.bold();
    return c.toString();
  }

  String _blue(String text) {
    var c = new Colorize(text);
    c.blue();
    c.bold();
    return c.toString();
  }

  String _yellow(String text) {
    var c = new Colorize(text);
    c.yellow();
    c.bold();
    return c.toString();
  }
}
