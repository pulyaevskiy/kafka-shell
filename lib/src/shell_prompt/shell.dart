part of shell_prompt;

abstract class ShellCommand {
  void execute(List<String> args, Stdout output);

  String signature();
  void writeHelp(Stdout output);

  /// Called whenever user requests autocomplete. Must return list of possible
  /// options.
  Future<List<AutocompleteOption>> autocomplete(List<String> args);
}

class Shell {
  final Map<String, ShellCommand> commands = new Map();

  ShellInput _input;

  Shell({ShellPrompt prompt}) {
    _input = new ShellInput(onSubmit, prompt: prompt);
    _input.onAutocomplete = onAutocomplete;
  }

  Future<List<AutocompleteOption>> onAutocomplete(String input) async {
    var options = new List();
    for (var command in commands.values) {
      var sublist = await command.autocomplete(_getArgs(input));
      options.addAll(sublist);
    }
    return options;
  }

  List<String> _getArgs(String input) {
    var list = input.trim().split(' ').toList();
    list.removeWhere((s) => s.isEmpty);
    return list;
  }

  onSubmit(String value) {
    if (value.isNotEmpty) {
      var list = _getArgs(value);
      var cmd = list.first.trim();
      if (commands.containsKey(cmd)) {
        return commands[cmd].execute(_getArgs(value), stdout);
      } else {
        Colorize err = new Colorize('ERR: No such command.');
        err.red();
        stdout.writeln(err);
      }
    }
  }

  void addCommand(String name, ShellCommand command) {
    commands[name] = command;
  }

  StreamSubscription<List<int>> _inputSubscription;

  Future run() {
    _inputSubscription = _input.listen();
    return _inputSubscription.asFuture();
  }

  void cancel() {
    _inputSubscription?.cancel();
  }
}
