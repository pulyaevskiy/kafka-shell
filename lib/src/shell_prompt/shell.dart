part of shell_prompt;

abstract class ShellCommand {
  void execute(String input, Stdout output);

  String signature();
  void writeHelp(Stdout output);

  /// Called whenever user requests autocomplete. Must return list of possible
  /// options.
  Future<List<AutocompleteOption>> autocomplete(String input);
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
      var sublist = await command.autocomplete(input);
      options.addAll(sublist);
    }
    return options;
  }

  onSubmit(String value) {
    if (value.isNotEmpty) {
      var list = value.trim().split(' ');
      var cmd = list.first.trim();
      if (commands.containsKey(cmd)) {
        return commands[cmd].execute(value, stdout);
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

  void run() {
    _input.listen();
  }
}
