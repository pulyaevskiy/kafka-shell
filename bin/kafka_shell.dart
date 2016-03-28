import 'dart:io';
import 'package:args/args.dart';
import 'package:kafka_shell/kafka_shell.dart';

main(List<String> arguments) async {
  var parser = new ArgParser();
  parser.addOption('host',
      abbr: 'h', help: 'Hostname or IP address of Kafka broker (required)');
  parser.addOption('port',
      abbr: 'p', help: 'Port of Kafka broker', defaultsTo: '9092');

  var results = parser.parse(arguments);
  if (results['host'] == null) {
    print(parser.usage);
    exit(1);
  }
  var config = {'host': results['host'], 'port': int.parse(results['port'])};

  var shell = new KafkaShell(config);
  shell.run().then((_) {
    exit(0);
  }, onError: (e, StackTrace trace) {
    shell.cancel();
    print(e);
    print(trace);
    exit(1);
  }).whenComplete(() {
    stdin.echoMode = true;
    stdin.lineMode = true;
  });
}
