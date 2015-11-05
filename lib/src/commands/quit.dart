part of kafka_shell;

class ExitCommand implements ShellCommand {
  final Shell shell;

  ExitCommand(this.shell);

  @override
  void execute(List<String> args, Stdout output) {
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
  Future<List<AutocompleteOption>> autocomplete(List<String> args) {
    var list = new List<AutocompleteOption>();
    if (args.length == 1 && 'exit'.startsWith(args.first)) {
      list.add(new AutocompleteOption('exit', 'exit'));
    }
    return new Future.value(list);
  }
}
