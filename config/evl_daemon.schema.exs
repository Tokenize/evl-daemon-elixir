@moduledoc """
A schema is a keyword list which represents how to map, transform, and validate
configuration values parsed from the .conf file. The following is an explanation of
each key in the schema definition in order of appearance, and how to use them.

## Import

A list of application names (as atoms), which represent apps to load modules from
which you can then reference in your schema definition. This is how you import your
own custom Validator/Transform modules, or general utility modules for use in
validator/transform functions in the schema. For example, if you have an application
`:foo` which contains a custom Transform module, you would add it to your schema like so:

`[ import: [:foo], ..., transforms: ["myapp.some.setting": MyApp.SomeTransform]]`

## Extends

A list of application names (as atoms), which contain schemas that you want to extend
with this schema. By extending a schema, you effectively re-use definitions in the
extended schema. You may also override definitions from the extended schema by redefining them
in the extending schema. You use `:extends` like so:

`[ extends: [:foo], ... ]`

## Mappings

Mappings define how to interpret settings in the .conf when they are translated to
runtime configuration. They also define how the .conf will be generated, things like
documention, @see references, example values, etc.

See the moduledoc for `Conform.Schema.Mapping` for more details.

## Transforms

Transforms are custom functions which are executed to build the value which will be
stored at the path defined by the key. Transforms have access to the current config
state via the `Conform.Conf` module, and can use that to build complex configuration
from a combination of other config values.

See the moduledoc for `Conform.Schema.Transform` for more details and examples.

## Validators

Validators are simple functions which take two arguments, the value to be validated,
and arguments provided to the validator (used only by custom validators). A validator
checks the value, and returns `:ok` if it is valid, `{:warn, message}` if it is valid,
but should be brought to the users attention, or `{:error, message}` if it is invalid.

See the moduledoc for `Conform.Schema.Validator` for more details and examples.
"""
[
  extends: [],
  import: [],
  mappings: [
    "evl_daemon.mailer_api_key": [
      commented: false,
      datatype: :binary,
      default: "SECRET",
      doc: "The API key from our mail provider.",
      hidden: false,
      to: "evl_daemon.Elixir.EvlDaemon.Mailer.api_key"
    ],
    "evl_daemon.host": [
      commented: false,
      datatype: :charlist,
      default: [
        49,
        50,
        55,
        46,
        48,
        46,
        48,
        46,
        49
      ],
      doc: "The host IP address for the EVL module.",
      hidden: false,
      to: "evl_daemon.host"
    ],
    "evl_daemon.port": [
      commented: false,
      datatype: :integer,
      default: 4025,
      doc: "The port number for the EVL module.",
      hidden: false,
      to: "evl_daemon.port"
    ],
    "evl_daemon.password": [
      commented: false,
      datatype: :binary,
      default: "SECRET",
      doc: "The password for the EVL module's web interface.",
      hidden: false,
      to: "evl_daemon.password"
    ],
    "evl_daemon.auto_connect": [
      commented: false,
      datatype: :atom,
      default: false,
      doc: "Determines if we should connect automatically when the application starts.",
      hidden: false,
      to: "evl_daemon.auto_connect"
    ],
    "evl_daemon.event_notifiers": [
      commented: false,
      datatype: [
        list: [list: {:atom, :binary}]
      ],
      default: [
        [type: "console"],
        [type: "email", recipient: "person@example.com", sender: "noreply@example.com"]
      ],
      doc: "Enabled event notifiers and their options.",
      hidden: false,
      to: "evl_daemon.event_notifiers"
    ],
    "evl_daemon.storage_engines": [
      commented: false,
      datatype: [
        list: [list: {:atom, :binary}]
      ],
      default: [
        [type: "memory", maximum_events: "100"]
      ],
      doc: "Enabled storage engines and their options.",
      hidden: false,
      to: "evl_daemon.storage_engines"
    ],
    "evl_daemon.tasks": [
      commented: false,
      datatype: [
        list: [list: {:atom, :binary}]
      ],
      default: [
        [type: "status_report"]
      ],
      doc: "Enabled tasks and their options.",
      hidden: false,
      to: "evl_daemon.tasks"
    ],
    "evl_daemon.zones": [
      commented: true,
      datatype: [
        list: [list: :binary]
      ],
      doc: "Zone mapping in the form of [number, \"description\"].",
      hidden: false,
      to: "evl_daemon.zones"
    ],
    "evl_daemon.partitions": [
      commented: true,
      datatype: [
        list: [list: :binary]
      ],
      doc: "Partition mapping in the form of [number, \"description\"].",
      hidden: false,
      to: "evl_daemon.partitions"
    ],
    "evl_daemon.system_emails_sender": [
      commented: false,
      datatype: :binary,
      default: "noreply@example.com",
      doc: "The sender address for system emails.",
      hidden: false,
      to: "evl_daemon.system_emails_sender"
    ],
    "evl_daemon.system_emails_recipient": [
      commented: false,
      datatype: :binary,
      default: "user@example.com",
      doc: "The recipient address for system emails.",
      hidden: false,
      to: "evl_daemon.system_emails_recipient"
    ],
    "evl_daemon.log_level": [
      commented: false,
      datatype: [enum: [:debug, :info, :warn, :error]],
      default: :info,
      doc: "The logging level for the default logger.",
      hidden: false,
      to: "logger.level"
    ],
    "evl_daemon.auth_token": [
      commented: false,
      datatype: :binary,
      default: "SECRET",
      doc: "The authentication token to access EVL Daemon over HTTP.",
      hidden: false,
      to: "evl_daemon.auth_token"
    ]
  ],
  transforms: [
    "evl_daemon.zones": fn conf ->
      [{key, zones}] = Conform.Conf.get(conf, "evl_daemon.zones")

      Enum.reduce(zones, Map.new(), fn [zone | description], zone_map ->
        Map.put(
          zone_map,
          zone |> to_string |> String.pad_leading(3, "0"),
          List.to_string(description)
        )
      end)
    end,
    "evl_daemon.partitions": fn conf ->
      [{key, partitions}] = Conform.Conf.get(conf, "evl_daemon.partitions")

      Enum.reduce(partitions, Map.new(), fn [partition | description], partition_map ->
        Map.put(
          partition_map,
          partition |> to_string,
          List.to_string(description)
        )
      end)
    end
  ],
  validators: []
]
