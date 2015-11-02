part of shell_prompt;

class Cursor {
  int position = 0;
  Function _onDelete;

  void moveLeft(int count) {
    while (count > 0) {
      stdout.write("\b");
      position--;
      count--;
    }
  }

  void moveRight(int count) {
    stdout.write("\x1b\x5b\x43");
    position++;
  }

  void delete(int count) {
    stdout.write("\b \b");
    position--;
  }

  bool handleKey(List<int> input, String currentText) {
    return _handleDelete(input, currentText);
  }

  void onDelete(Function onDelete) {
    _onDelete = onDelete;
  }

  bool _handleDelete(List<int> input, String currentText) {
    if (input.length == 1 && input[0] == 127) {
      if (currentText.isEmpty) {
        return true;
      }

      stdout.write("\b \b");
      _onDelete?.call();
      return true;
    } else {
      return false;
    }
  }
}
