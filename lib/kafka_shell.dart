library kafka_shell;

import 'dart:io';
import 'dart:async';

import 'package:kafka/kafka.dart';
import 'package:colorize/colorize.dart';
import 'package:dlog/dlog.dart';

import 'src/shell_prompt/shell_prompt.dart';

part 'src/prompt.dart';
part 'src/context.dart';

part 'src/commands/help.dart';
part 'src/commands/quit.dart';
part 'src/commands/use.dart';
part 'src/commands/brokers.dart';
part 'src/commands/topics.dart';
part 'src/commands/partitions.dart';
part 'src/commands/offsets.dart';

part 'src/view/topics.dart';
part 'src/view/partitions.dart';

void writeError(Stdout output, String text) {
  Colorize err = new Colorize(text);
  err.red();
  output.writeln(err);
}

class KafkaShell {
  final Map config;
  final SharedContext context = new SharedContext();
  Shell _shell;

  KafkaShell(this.config) {
    _shell = new Shell(prompt: new KafkaPrompt(context));
  }

  Future run() async {
    print('KafkaShell v1.0.0-dev');
    var session =
        new KafkaSession([new KafkaHost(config['host'], config['port'])]);

    var meta = await session.getMetadata();
    var info = new Colorize(
        "Connected to Kafka cluster with ${meta.brokers.length} brokers.");
    info.green();
    print(info);

    _shell
      ..addCommand('help', new HelpCommand(_shell))
      ..addCommand('exit', new ExitCommand(_shell))
      ..addCommand('use', new UseCommand(session, context, _shell))
      ..addCommand('brokers', new BrokersCommand(session))
      ..addCommand('topics', new TopicsCommand(session))
      ..addCommand('partitions', new PartitionsCommand(session, context))
      ..addCommand('offsets', new OffsetsCommand(session, context));

    _shell.run();
  }
}
