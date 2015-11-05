# Kafka Shell Commands (design doc)

## Globally available commands

- `help` - shows help.
- `brokers` - list all brokers in the cluster
- `topics [<topic> <subcommand>]` - lists all topics and provides some more subcommands
  - `topics <topic> partitions` - list partitions of selected topic
  - `topics <topic> offsets` - provides overview of topic offsets in all partitions.
- `use <topic> [as <consumerGroup>]` - switches shell context to selected topic and (optionally) consumer group.

## Commands available when global topic context is used.

- `offsets` - shortcut for `topics <topic> offsets`
- `partitions` - shortcut for `topics <topic> partitions`
- `fetch [from <partition>] [starting at <offset|earliest>] [limit <num>]`

## Commands available when global consumerGroup context is used.

- `status` - shows overview of consumer and topic offsets
- `reset offset [on <partition>] to <offset|earliest|latest>`
