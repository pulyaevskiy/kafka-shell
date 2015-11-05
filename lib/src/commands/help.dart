part of kafka_shell;

class HelpCommand implements ShellCommand {
  final Shell shell;

  HelpCommand(this.shell);

  @override
  void execute(List<String> args, Stdout output) {
    if (args.length == 1) {
      shell.commands.values.forEach((c) => output.writeln(c.signature()));
    } else if (args.length == 2) {
      var command = args.last;
      if (shell.commands.containsKey(command)) {
        shell.commands[command].writeHelp(output);
      } else {
        writeError(output, 'ERR: No command found to show help for.');
      }
    }
  }

  @override
  void writeHelp(Stdout output) {
    output.writeln('Usage: help');
    output.writeln('');
    output.writeln('Shows information about available commands.');
  }

  @override
  String signature() {
    return 'help - Shows information about available commands';
  }

  @override
  Future<List<AutocompleteOption>> autocomplete(List<String> args) {
    var list = new List<AutocompleteOption>();
    if (args.length == 1 && 'help'.startsWith(args.first)) {
      list.add(new AutocompleteOption('help', 'help'));
    }
    return new Future.value(list);
  }
}
