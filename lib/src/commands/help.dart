part of kafka_shell;

class HelpCommand implements ShellCommand {
  final Shell shell;

  HelpCommand(this.shell);

  @override
  void execute(String input, Stdout output) {
    var list = input.trim().split(' ');
    if (list.length == 1) {
      shell.commands.values.forEach((c) => output.writeln(c.signature()));
    } else if (list.length == 2) {
      var command = list.last;
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
  Future<List<AutocompleteOption>> autocomplete(String input) {
    var list = new List<AutocompleteOption>();
    if ('help'.startsWith(input)) {
      list.add(new AutocompleteOption('help', 'help'));
    }
    return new Future.value(list);
  }
}
