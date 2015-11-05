part of shell_prompt;

typedef dynamic ShellInputSubmit(String value);

typedef Future<List<AutocompleteOption>> ShellInputAutocomplete(String input);

abstract class ShellPrompt {
  void write(Stdout output);
}

class BasicShellPrompt implements ShellPrompt {
  final String text;

  BasicShellPrompt(this.text);

  @override
  void write(Stdout output) {
    output.write(text);
  }
}

/// Option for autocomplete functionality.
///
/// [label] will be shown in the list of possible options.
/// [value] must contain full command string. When user selects any options
/// `value` is used to completely replace whatever input contained at the moment.
class AutocompleteOption {
  final String label;
  final String value;

  AutocompleteOption(this.label, this.value);
}

/// ShellInput implements typical behavior for input field in CLI.
class ShellInput {
  ShellPrompt prompt;
  final ShellInputSubmit onSubmit;
  ShellInputAutocomplete onAutocomplete;
  final Cursor cursor = new Cursor();
  String _value = '';

  Map _handlers;

  bool _submitInProgress = false;

  ShellInput(this.onSubmit, {ShellPrompt prompt}) {
    if (prompt == null) {
      this.prompt = new BasicShellPrompt('\$ ');
    } else {
      this.prompt = prompt;
    }

    stdin.echoMode = false;
    stdin.lineMode = false;
    _handlers = {
      "\x1b\x5b\x43": _handleRightArrow,
      "\x1b\x5b\x44": _handleLeftArrow,
      "\x1b\x5b\x41": _handleUpArrow,
      "\x1b\x5b\x42": _handleDownArrow,
      "\x7f": _handleDelete,
      "\x09": _handleTab,
      "\n": _handleReturn
    };
  }

  Future listen() async {
    var completer = new Completer();

    _printPrompt();
    stdin.asBroadcastStream().listen((List<int> _) async {
      if (_submitInProgress) return;

      var str;
      try {
        str = ASCII.decode(_);
      } on FormatException {
        str = UTF8.decode(_);
      }

      if (_handlers.containsKey(str)) {
        var res = _handlers[str](str);
        if (res is Future) {
          await res;
        }
        return;
      } else if (str.contains("\x1b")) {
        // print(_);
      } else {
        // print(_);
        _handleInsert(str);
      }
    });

    return completer.future;
  }

  _printPrompt() {
    prompt.write(stdout);
  }

  _handleReturn(String key) async {
    stdout.write(key);
    try {
      _submitInProgress = true;
      var result = onSubmit(_value);
      if (result is Future) {
        await result;
      }
    } finally {
      _submitInProgress = false;
      _value = '';
      cursor.position = 0;
    }
    _printPrompt();
  }

  _beep() {
    stdout.write(new String.fromCharCodes([0x07]));
  }

  _handleTab(String key) async {
    if (onAutocomplete == null) {
      _beep();
      return;
    }
    var options = onAutocomplete(_value);
    if (options is Future) {
      options = await options;
    }
    if (options.isEmpty) {
      _beep();
      return;
    }

    if (options.length == 1) {
      cursor.moveLeft(_value.length);
      _value = options.first.value + ' ';
      stdout.write(_value);
      cursor.position = _value.length;
    } else {
      // TODO show options on second <tab>
      _beep();
    }
  }

  _handleInsert(String key) {
    if (cursor.position == _value.length) {
      _value += key;
      cursor.position++;
      stdout.write(key);
    } else if (cursor.position < _value.length) {
      var toWrite = key + _value.substring(cursor.position);
      _value = _value.substring(0, cursor.position) + toWrite;
      stdout.write(toWrite);
      cursor.position = _value.length;
      cursor.moveLeft(toWrite.length - 1);
    }
  }

  _handleRightArrow(String key) {
    if (cursor.position < _value.length) {
      cursor.moveRight(1);
    }
  }

  _handleLeftArrow(String key) {
    if (cursor.position > 0) {
      cursor.moveLeft(1);
    }
  }

  _handleUpArrow(String key) {}

  _handleDownArrow(String key) {}

  _handleDelete(String key) {
    if (_value.isEmpty || cursor.position == 0) {
      return;
    }

    if (cursor.position == _value.length) {
      _value = _value.substring(0, _value.length - 1);
      cursor.delete(1);
    } else if (cursor.position < _value.length) {
      var toWrite = _value.substring(cursor.position);
      _value = _value.substring(0, cursor.position - 1) + toWrite;
      cursor.moveLeft(1);
      stdout.write(toWrite + ' ');
      cursor.position = _value.length + 1;
      cursor.moveLeft(toWrite.length + 1);
    }
  }
}
