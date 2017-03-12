# Kafka Shell

Command-line shell for Apache Kafka.

> Current status: this library is on pause and waiting for kafka client refactor to Kafka 0.10
> APIs. To follow progress on the client check out this [PR](https://github.com/dart-drivers/kafka/pull/13)
> Once, there is first public alpha of the Kafka client the shell work will be resumed.

[![asciicast](https://asciinema.org/a/d95xyhz034nmsaqjwzw6g74tt.png)](https://asciinema.org/a/d95xyhz034nmsaqjwzw6g74tt)

## Dependencies

Dart VM must be installed in order to run this application.
You can follow [official documentation](https://www.dartlang.org/downloads/) on how to get Dart VM on your machine.

For Mac OS X users it should be as easy as following (if you're using Homebrew):

```shell
$ brew tap dart-lang/dart
$ brew install dart
```

## Installation

At this point there is no "installer" for Kafka Shell.
However you can install early development preview if you want to try it out.

1. Make sure you have Dart VM installed (see Dependencies above)
2. Go to [Releases](https://github.com/pulyaevskiy/kafka-shell/releases/tag/v1.0.0-dev) section of this repository and select `Latest development version`
3. Download `kafka_shell.snapshot` to your computer.

## Usage

Running shell:

```shell
$ dart kafka_shell.snapshot --host <HOSTNAME>
```

Where `<HOSTNAME>` is a hostname or IP address of Kafka broker. It will use port `9092` by default, but you can customize it with `--port` option. Here is full list of supported options:

```shell
$ dart kafka_shell.snapshot
-h, --host    Hostname or IP address of Kafka broker (required)
-p, --port    Port of Kafka broker
              (defaults to "9092")
```
