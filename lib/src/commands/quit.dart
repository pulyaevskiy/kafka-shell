part of kafka_shell;

class ExitCommand implements ShellCommand {
  final Shell shell;

  ExitCommand(this.shell);

  @override
  void execute(String input, Stdout output) {
    output.writeln('Bye');
    exit(0);
  }

  @override
  String signature() {
    return 'exit - Exit from shell.';
  }

  @override
  void writeHelp(Stdout output) {
    output.writeln('Usage: quit|exit');
    output.writeln('');
    output.writeln('Exit from shell.');
  }

  @override
  Future<List<AutocompleteOption>> autocomplete(String input) {
    var list = new List<AutocompleteOption>();
    if ('exit'.startsWith(input)) {
      list.add(new AutocompleteOption('exit', 'exit'));
    }
    return new Future.value(list);
  }
}
